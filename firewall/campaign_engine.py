import json
import os
import re
import sys
from datetime import datetime, timezone

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from .schema import CampaignInfo, Exposure

STAGE_ORDER = ["delivery", "pretexting", "urgency", "isolation", "credential_harvesting", "exploitation", "objective_completion"]


def now_iso():
    return datetime.now(timezone.utc).isoformat()


def _existing_campaigns():
    try:
        from database.db_setup import get_db_connection
        conn = get_db_connection()
        rows = conn.execute("SELECT campaign_id, exposure FROM campaigns").fetchall()
        conn.close()
        out = {}
        for r in rows:
            meta = {}
            try:
                meta = json.loads(r[1] or "{}")
            except Exception:
                meta = {}
            out[r[0]] = meta
        return out
    except Exception:
        return {}


class CampaignManager:
    def __init__(self):
        self._state = {}
        for cid, meta in _existing_campaigns().items():
            self._state[cid] = self._from_meta(meta)

    def _from_meta(self, meta):
        return {
            "event_count": meta.get("event_count", 0),
            "channels": set(meta.get("channels", [])),
            "correlation_keys": set(meta.get("correlation_keys", [])),
            "velocity": meta.get("velocity_seconds"),
            "progression_labels": list(meta.get("progression_labels", [])),
            "stage_times": meta.get("stage_times", {}),
            "money": float(meta.get("exposure", {}).get("money_inr", 0) or 0),
            "otp_requested": meta.get("exposure", {}).get("otp_requested", False),
            "device_access_requested": meta.get("exposure", {}).get("device_access_requested", False),
            "account_access_possible": meta.get("exposure", {}).get("account_access_possible", False),
        }

    def _next_id(self):
        n = 1
        while ("SCAM-%03d" % n) in self._state:
            n += 1
        return "SCAM-%03d" % n

    def _correlation_keys(self, event, extraction):
        keys = set()
        sender = event.get("sender") or event.get("number") or ""
        if sender:
            keys.add("num:" + re.sub(r"\D", "", sender))
        for phone in extraction.phone_numbers:
            keys.add("num:" + re.sub(r"\D", "", phone))
        for upi in extraction.upi_ids:
            keys.add("upi:" + upi.lower())
        for url in extraction.urls:
            keys.add("url:" + url)
        return keys

    def process(self, event, stage, risk_score, channel, extraction, count_money=True):
        keys = self._correlation_keys(event, extraction)
        target = None
        for cid in self._state:
            if self._state[cid]["correlation_keys"] & keys:
                target = cid
                break
        is_new = target is None
        if is_new:
            target = self._next_id()
            self._state[target] = {
                "event_count": 0,
                "channels": set(),
                "correlation_keys": set(),
                "velocity": None,
                "progression_labels": [],
                "stage_times": {},
                "money": 0.0,
                "otp_requested": False,
                "device_access_requested": False,
                "account_access_possible": False,
            }
        st = self._state[target]
        st["correlation_keys"] |= keys
        st["channels"].add(channel.lower())
        st["event_count"] += 1
        if extraction.amounts_inr and count_money:
            st["money"] = max(st["money"], max(extraction.amounts_inr))
        if extraction.apps:
            st["device_access_requested"] = True
        if stage.stage in ("credential_harvesting", "exploitation"):
            st["account_access_possible"] = True
            st["otp_requested"] = True
        if stage.stage == "credential_harvesting":
            st["otp_requested"] = True

        ts = now_iso()
        if stage.stage != "benign" and stage.stage not in st["progression_labels"]:
            st["stage_times"][stage.stage] = ts
            st["progression_labels"].append(stage.stage)
        if len(st["progression_labels"]) >= 2:
            first = st["stage_times"].get(st["progression_labels"][0])
            if first:
                try:
                    f = datetime.fromisoformat(first)
                    t = datetime.fromisoformat(ts)
                    st["velocity"] = max(0.0, (t - f).total_seconds())
                except Exception:
                    st["velocity"] = None

        from .risk import level_for_score
        campaign_score = risk_score
        if len(st["channels"]) > 1:
            campaign_score += 8
        if st["event_count"] > 2:
            campaign_score += min(10, (st["event_count"] - 2) * 3)
        if st["velocity"] is not None and st["velocity"] < 90:
            campaign_score += 8
        elif st["velocity"] is not None and st["velocity"] < 300:
            campaign_score += 5
        campaign_score = max(0, min(100, campaign_score))

        exposure = self._build_exposure(st, stage, extraction)
        telemetry = {
            "stage_times": st["stage_times"],
            "progression_labels": list(st["progression_labels"]),
            "velocity_seconds": st["velocity"],
            "channels": sorted(st["channels"]),
            "event_count": st["event_count"],
            "correlation_keys": sorted(st["correlation_keys"]),
        }
        self._persist(target, ts, campaign_score, level_for_score(campaign_score), st, exposure, telemetry, event, risk_score, stage, channel)

        order = sorted(st["stage_times"].items(), key=lambda kv: kv[1])
        return CampaignInfo(
            campaign_id=target,
            risk_score=campaign_score,
            risk_level=level_for_score(campaign_score),
            categories=list(st["progression_labels"]),
            stage_history=order,
            velocity_seconds=st["velocity"],
            progression_labels=list(st["progression_labels"]),
            exposure=exposure,
            event_count=st["event_count"],
            channels=sorted(st["channels"]),
            created_at=order[0][1] if order else ts,
            updated_at=ts,
            is_new=is_new,
        )

    def _build_exposure(self, st, stage, extraction):
        credential = "high" if stage.stage == "credential_harvesting" else ("medium" if stage.stage in ("pretexting", "urgency") else "none")
        if "credential_harvesting" in st["progression_labels"]:
            credential = "high"
        money = st["money"]
        desc = "₹%s at risk" % int(money)
        if not money and st["otp_requested"]:
            desc = "OTP and account credentials at risk; no direct money requested yet"
        if not money and not st["otp_requested"]:
            desc = "No direct money exposure yet"
        if money and st["account_access_possible"]:
            desc = "₹%s plus banking credentials at risk" % int(money)
        return Exposure(
            money_inr=float(money),
            credential_risk=credential,
            otp_requested=st["otp_requested"],
            device_access_requested=st["device_access_requested"],
            account_access_possible=st["account_access_possible"],
            description=desc,
        )

    def _persist(self, target, ts, campaign_score, level, st, exposure, telemetry, event, risk_score, stage, channel):
        try:
            from database.repository import CampaignRepository, EventRepository
            CampaignRepository.create_or_update(target, ts, campaign_score, level, ",".join(list(st["progression_labels"]) + [channel]))
            EventRepository.log_event(channel, event.get("sender") or "", ts, (event.get("text") or event.get("content") or "")[:400], risk_score, target)
            from database.db_setup import get_db_connection
            conn = get_db_connection()
            conn.execute("UPDATE campaigns SET exposure = ? WHERE campaign_id = ?", (json.dumps({"ledger": telemetry, "exposure": _exposure_dict(exposure)}), target))
            conn.commit()
            conn.close()
        except Exception:
            pass

    def get(self, campaign_id):
        return self._state.get(campaign_id)

    def all_ids(self):
        return sorted(self._state.keys())


def _exposure_dict(exposure):
    return {
        "money_inr": exposure.money_inr,
        "credential_risk": exposure.credential_risk,
        "otp_requested": exposure.otp_requested,
        "device_access_requested": exposure.device_access_requested,
        "account_access_possible": exposure.account_access_possible,
        "description": exposure.description,
    }


def load_history():
    try:
        from database.db_setup import get_db_connection
        conn = get_db_connection()
        campaigns = conn.execute("SELECT * FROM campaigns ORDER BY last_updated DESC").fetchall()
        events = conn.execute("SELECT event_type, sender_number, timestamp, risk_score, campaign_id FROM events_log ORDER BY timestamp DESC").fetchall()
        conn.close()
        return [dict(c) for c in campaigns], [dict(e) for e in events]
    except Exception:
        return [], []


campaign_manager = CampaignManager()