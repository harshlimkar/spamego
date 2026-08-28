import csv
import json
import os
import sys

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report, f1_score
from sklearn.model_selection import train_test_split

from firewall.edge_model import N_FEATURES, _features, _hash, WEIGHTS_PATH


def _load_spam_ham():
    path = os.path.join(_ROOT, "backend", "models", "spam_ham_india.csv")
    rows = []
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            text = (row.get("Msg") or "").strip()
            label = (row.get("Label") or "").strip().lower()
            if not text:
                continue
            rows.append((text, 1 if label == "spam" else 0))
    return rows


def _load_fraud_call():
    path = os.path.join(_ROOT, "backend", "models", "fraud_call.file")
    rows = []
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.rstrip("\n")
            if not line:
                continue
            parts = line.split("\t")
            if len(parts) < 2:
                continue
            label, text = parts[0].strip().lower(), parts[-1].strip()
            if not text:
                continue
            rows.append((text, 1 if label == "fraud" else 0))
    return rows


def _load_hinglish():
    path = os.path.join(_ROOT, "backend", "models", "India_Cyber_Scam_Hinglish_Dataset.csv")
    rows = []
    with open(path, "r", encoding="utf-8", errors="replace") as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            text = (row.get("text") or row.get("Text") or "").strip()
            label = row.get("label", "0").strip()
            if not text:
                continue
            try:
                lbl = int(float(label))
            except Exception:
                lbl = 0
            rows.append((text, 1 if lbl != 0 else 0))
    return rows


def main():
    spam_ham = _load_spam_ham()
    fraud = _load_fraud_call()
    hinglish = _load_hinglish()
    print("spam_ham rows: %d (spam %d / ham %d)" % (len(spam_ham), sum(1 for _, y in spam_ham if y), sum(1 for _, y in spam_ham if not y)))
    print("fraud_call rows: %d (fraud %d / normal %d)" % (len(fraud), sum(1 for _, y in fraud if y), sum(1 for _, y in fraud if not y)))
    print("hinglish rows: %d (scam %d / benign %d)" % (len(hinglish), sum(1 for _, y in hinglish if y), sum(1 for _, y in hinglish if not y)))
    all_rows = spam_ham + fraud + hinglish
    texts = [t for t, _ in all_rows]
    ys = [y for _, y in all_rows]
    X_train, X_test, y_train, y_test = train_test_split(texts, ys, test_size=0.2, random_state=42, stratify=ys)

    from scipy.sparse import csr_matrix
    import numpy as np

    def build_matrix(texts):
        rows, cols, vals = [], [], []
        for i, text in enumerate(texts):
            counts = {}
            for f in _features(text):
                h = _hash(f)
                counts[h] = counts.get(h, 0) + 1
            for h, c in counts.items():
                rows.append(i)
                cols.append(h)
                vals.append(c)
        return csr_matrix((np.array(vals, dtype=np.float64), (rows, cols)), shape=(len(texts), N_FEATURES))

    X_train = build_matrix(X_train)
    X_test = build_matrix(X_test)
    model = LogisticRegression(C=4.0, max_iter=2000, class_weight="balanced")
    model.fit(X_train, y_train)
    y_pred = model.predict(X_test)
    report = classification_report(y_test, y_pred, output_dict=True, zero_division=0)
    print("\nHoldout 20%% metrics (binary: 1 = scam/suspicious):")
    print("accuracy: %.4f" % report["accuracy"])
    print("benign  precision %.3f recall %.3f f1 %.3f" % (report["0"]["precision"], report["0"]["recall"], report["0"]["f1-score"]))
    print("scam    precision %.3f recall %.3f f1 %.3f" % (report["1"]["precision"], report["1"]["recall"], report["1"]["f1-score"]))

    vec = None
    clf = model
    weights = {}
    for h, w in enumerate(clf.coef_[0]):
        if abs(w) > 1e-9:
            weights[str(h)] = round(float(w), 5)

    meta = {
        "model": "hashed_word_ngram_logistic",
        "feature_buckets": N_FEATURES,
        "training_rows": len(all_rows),
        "train_accuracy": round(report["accuracy"], 4),
        "scam_f1": round(report["1"]["f1-score"], 4),
        "benign_f1": round(report["0"]["f1-score"], 4),
        "languages": ["English", "Hinglish", "Hindi", "Tamil", "mixed"],
        "note": "Pure-Python runtime, sklearn needed only for training.",
    }
    os.makedirs(os.path.dirname(WEIGHTS_PATH), exist_ok=True)
    with open(WEIGHTS_PATH, "w", encoding="utf-8") as fh:
        json.dump({"bias": float(clf.intercept_[0]), "weights": weights, "meta": meta}, fh)
    print("\nSaved edge weights to %s (%d non-zero entries)" % (WEIGHTS_PATH, len(weights)))


if __name__ == "__main__":
    main()