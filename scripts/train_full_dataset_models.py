import csv
import json
import os
import re
import sys
import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split
from scipy.sparse import csr_matrix
import joblib

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if _ROOT not in sys.path:
    sys.path.insert(0, _ROOT)

from firewall.edge_model import N_FEATURES, _features, _hash, WEIGHTS_PATH

# 1. Load spam_ham_india.csv
def load_spam_ham():
    path = os.path.join(_ROOT, "dataset", "spam_ham_india.csv")
    rows = []
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8", errors="replace") as fh:
            reader = csv.DictReader(fh)
            for row in reader:
                text = (row.get("Msg") or "").strip()
                label = (row.get("Label") or "").strip().lower()
                if not text:
                    continue
                # label: spam or ham
                rows.append({
                    "text": text,
                    "label_binary": 1 if label == "spam" else 0,
                    "label_category": "SPAM" if label == "spam" else "SAFE"
                })
    return rows

# 2. Load fraud_call.file
def load_fraud_call():
    path = os.path.join(_ROOT, "dataset", "fraud_call.file")
    rows = []
    if os.path.exists(path):
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
                is_fraud = 1 if label == "fraud" else 0
                rows.append({
                    "text": text,
                    "label_binary": is_fraud,
                    "label_category": "SCAM" if is_fraud else "SAFE"
                })
    return rows

# 3. Load India_Cyber_Scam_Hinglish_Dataset.csv
def load_hinglish():
    path = os.path.join(_ROOT, "dataset", "India_Cyber_Scam_Hinglish_Dataset.csv")
    rows = []
    if os.path.exists(path):
        with open(path, "r", encoding="utf-8", errors="replace") as fh:
            reader = csv.DictReader(fh)
            for row in reader:
                text = (row.get("text") or row.get("Text") or "").strip()
                label = row.get("label", "0").strip()
                category = (row.get("scam_category") or "none").strip()
                if not text:
                    continue
                try:
                    lbl = int(float(label))
                except Exception:
                    lbl = 0
                is_scam = 1 if lbl != 0 else 0
                rows.append({
                    "text": text,
                    "label_binary": is_scam,
                    "label_category": "SCAM" if is_scam else "SAFE"
                })
    return rows

# 4. User provided extra dataset samples
USER_SAMPLES = [
    ("Dear 901969xxxx, Rs.38,OOO/- is Added t0 your wallet account XXX6 0n 29 Aug. Directly Withdraw N0w OI1.in/2vclen!8cpr814", 1, "SCAM"),
    ("Enjoy big savings. Get up to Rs.5 Lakh Olyv (formerly SmartCoin) loan at an insane 50% off on proc. fees! Apply now - u3.mnge.co/2gvlno2 T&C", 1, "SPAM"),
    ("Hi there, you are successfully registered on KreditBee. Submit your loan application for quick funds from KBNBFC. T&Cs apply. https://a.krdt.be/02Je/crm", 1, "SPAM"),
    ("Hurry! Recharge Jio no 9019695140 with Rs.299 plan (1.5 GB/day, Voice Unlimited, 28 Days) on Google Pay & get upto Rs.100 Rewards. T&CA. https://gpay.app.goo.gl/zyXNHg", 1, "SPAM"),
    ("3787 is the OTP to access Tipplr eQ/zPj8f0h3", 1, "SPAM"),
    ("Hi 901969xxxx, Rs.56,6OO/- Bonus is credited t0 your wallet N0 XX32 0n 28 Aug. Directly move to your Bank A/c N0w OI1.in/2uabg2!8cpr814", 1, "SCAM"),
    ("Your plan for Jio no 9019695140 expires on 30-08-2024 .Avoid STOPPAGE of services, RECHARGE Now Click www.jio.com/r/PVzNJWecV .For other plans, call 1991.", 1, "SPAM"),
    ("YOUR WINNING PARCEL FROM FROM APPLE USA WILL ARRIVE INDIA ON THURSDAY 29TH AUGUST 2024 BY INDIAN 10 AM", 1, "SCAM"),
    ("YOUR WINNING FUND 1 CRORE RUPEES AND iPHONE 15 PROMAX WILL BE ARRIING INDIA FOR DELIVERY TO YOUR LOCATION ON THURSDAY,29TH AUGUST 2024 BY 10 AM INDIAN STANDARD", 1, "SCAM"),
    ("50% Daily Data quota used as on 27-Aug-24 16:52 Hrs. Jio Number : 9019695140 Daily Data quota as per plan : 1.5 GB", 1, "SPAM"),
    ("Don't miss! Recharge now your Jio 9019695140 with Rs.299 plan on PhonePe. Get Flat Rs.100 Cashback for New User. https://phon.pe/jionew", 1, "SPAM"),
    ("Congratulations, Amount of Rs.44,OOO/- is credited t0 your wallet Acc XX7O 0n 27 Aug. Instantly Withdraw N0w OI1.in/2sk0ko!8cpr814", 1, "SCAM"),
    ("Y0u have receive a B0nus of Rs.51OOO/- in Y0ur wallet A/count no XX11 0n 26-O8-2O24. M0ve to Y0ur Bank A/c OI1.in/2rn2ds!8cpr814", 1, "SCAM"),
    ("KIND ATTENTION PLEASE PLEASE CHECK YOUR MAILBOX AS WE HAVE SENT YOU RE-VERIFICATION FORM KINDLY FILL THEM AND SEND BACK FOR YOUR PAYMENT REGARDS, APPLE USA", 1, "SCAM"),
    ("Winning Alert! get upto Rs. 11,001* bonus in your Rummy wallet. Play more and earn more. Click - http://gmg.im/d6l0T2 Sports League", 1, "SCAM"),
    ("Hi 9019XXXX40, Rs.15,OOO/- is Credited on your wallet account. Join Now to withdrawal directly: SR3.in/N44CD-2199DA024", 1, "SCAM"),
    ("Rs. 11,350 Welcome Bonus is waiting for you on Junglee Rummy. Unlock it now by making your first deposit. Claim http://Kx6.in/U8oBZo T&CA*-Sports League", 1, "SCAM"),
    ("Dear Customer, Get SBI Credit Card with up to Rs.1,50,000 limit! Instant approval & doorstep delivery. Apply now! http://gmg.im/bUNw7Q Smart Cardon", 1, "SPAM"),
    ("Dear User, Receive Rs.10,000 to Wallet Now - http://gmg.im/cvztd4 Finance Guru", 1, "SCAM"),
    ("Apply for your Olyv (formerly SmartCoin) loan through CreditLinks within 3 days and get 50% off processing fees! 0kb.in/s/DRDgYQc", 1, "SPAM"),
    ("Hi 9019XXXX40, Rs.15,OOO/- is Credited on your wallet account. Join Now to withdrawal directly: SR3.in/N439B-2199DA024", 1, "SCAM"),
    ("Dear User, Vistor Id - 7538XXX. Loan Application is ready to be Processed for Rs.2,50,000. Direct Transfer to Bank A/C. Click - http://gmg.im/bgzjS5 Fast Loans", 1, "SCAM"),
    ("Congrats, Y0UR Received Rs.592000 L0AN is Approve on 15-O8-2O24. Zero documentation. Withdraw directly to Y0UR bank A/c. SR3.in/O15E-2i19i9DA02i4", 1, "SCAM"),
    ("Congrats User, Rs.15OOO Bonus is Credited to your wallet No Xxxx95582. Direct y0ur ac - SR3.in/O13D-2i19i9DA02i4", 1, "SCAM"),
    ("Dear we can offer you to work online & earn 8000-20000/day according to your performance, no time limit, contact: https://wa.me/919678462191 BBKUMR", 1, "SCAM"),
    ("(Kartik) Amazon urgently recruiting for part-time jobs, daily salary 1000-7000rs CLICK JOINING: wa.me/917993184064", 1, "SCAM"),
    ("Online part-time job, you can earn 500-10000 rubles per day, if you are interested, please click the Whatsapp link to contact: 1vp.cc/DFE4DSMOI3cN", 1, "SCAM"),
    ("You can work online without investment, earn 200-3000 rs a day, click the link to contact: https://wa.me/917870889577 Y2ql", 1, "SCAM"),
]

def main():
    print("Loading all datasets...")
    spam_ham = load_spam_ham()
    fraud_call = load_fraud_call()
    hinglish = load_hinglish()
    
    user_rows = [{"text": t, "label_binary": b, "label_category": c} for t, b, c in USER_SAMPLES]
    
    all_data = spam_ham + fraud_call + hinglish + user_rows
    print(f"Total unified samples: {len(all_data)}")
    print(f"  - spam_ham: {len(spam_ham)}")
    print(f"  - fraud_call: {len(fraud_call)}")
    print(f"  - hinglish: {len(hinglish)}")
    print(f"  - user_samples: {len(user_rows)}")
    
    # ── 1. Train Edge Hashed Model (for instant pure-Python runtime) ──
    print("\n--- Training Edge Hashed Model ---")
    texts = [d["text"] for d in all_data]
    ys_binary = [d["label_binary"] for d in all_data]
    
    X_train_t, X_test_t, y_train_b, y_test_b = train_test_split(
        texts, ys_binary, test_size=0.2, random_state=42, stratify=ys_binary
    )
    
    def build_hashed_matrix(text_list):
        rows, cols, vals = [], [], []
        for i, text in enumerate(text_list):
            counts = {}
            for f in _features(text):
                h = _hash(f)
                counts[h] = counts.get(h, 0) + 1
            for h, c in counts.items():
                rows.append(i)
                cols.append(h)
                vals.append(c)
        return csr_matrix((np.array(vals, dtype=np.float64), (rows, cols)), shape=(len(text_list), N_FEATURES))
        
    X_train_h = build_hashed_matrix(X_train_t)
    X_test_h = build_hashed_matrix(X_test_t)
    
    edge_model = LogisticRegression(C=4.0, max_iter=2000, class_weight="balanced")
    edge_model.fit(X_train_h, y_train_b)
    edge_preds = edge_model.predict(X_test_h)
    
    rep_edge = classification_report(y_test_b, edge_preds, output_dict=True, zero_division=0)
    print(f"Edge Model Accuracy: {rep_edge['accuracy']:.4f}")
    print(f"Edge Model Scam F1: {rep_edge['1']['f1-score']:.4f}")
    
    weights = {}
    for h, w in enumerate(edge_model.coef_[0]):
        if abs(w) > 1e-9:
            weights[str(h)] = round(float(w), 5)
            
    edge_meta = {
        "model": "hashed_word_ngram_logistic",
        "feature_buckets": N_FEATURES,
        "training_rows": len(all_data),
        "train_accuracy": round(rep_edge["accuracy"], 4),
        "scam_f1": round(rep_edge["1"]["f1-score"], 4),
        "benign_f1": round(rep_edge["0"]["f1-score"], 4),
        "languages": ["English", "Hinglish", "Hindi", "Tamil", "Obfuscated-SMS", "mixed"],
    }
    
    os.makedirs(os.path.dirname(WEIGHTS_PATH), exist_ok=True)
    with open(WEIGHTS_PATH, "w", encoding="utf-8") as fh:
        json.dump({"bias": float(edge_model.intercept_[0]), "weights": weights, "meta": edge_meta}, fh)
    print(f"Saved updated edge weights to {WEIGHTS_PATH} ({len(weights)} non-zero weights)")

    # ── 2. Train TF-IDF Multi-Class / Scam Classifier (for Backend ML Analysis Service) ──
    print("\n--- Training Backend TF-IDF Model ---")
    ys_cat = [d["label_category"] for d in all_data]
    label2id = {"SAFE": 0, "SPAM": 1, "SCAM": 2}
    id2label = {0: "SAFE", 1: "SPAM", 2: "SCAM"}
    y_cat_ids = [label2id[c] for c in ys_cat]
    
    X_train_raw, X_test_raw, y_train_c, y_test_c = train_test_split(
        texts, y_cat_ids, test_size=0.2, random_state=42, stratify=y_cat_ids
    )
    
    vectorizer = TfidfVectorizer(
        max_features=25000,
        ngram_range=(1, 3),
        sublinear_tf=True,
        token_pattern=r"(?u)\b\w+\b|https?://\S+|[₹£$]\d+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+"
    )
    
    X_train_tfidf = vectorizer.fit_transform(X_train_raw)
    X_test_tfidf = vectorizer.transform(X_test_raw)
    
    clf = LogisticRegression(C=5.0, max_iter=2000, class_weight="balanced")
    clf.fit(X_train_tfidf, y_train_c)
    
    preds_c = clf.predict(X_test_tfidf)
    rep_c = classification_report(y_test_c, preds_c, target_names=["SAFE", "SPAM", "SCAM"], output_dict=True)
    
    print(f"Backend TF-IDF Accuracy: {rep_c['accuracy']:.4f}")
    print(f"SCAM Recall: {rep_c['SCAM']['recall']:.4f} | F1: {rep_c['SCAM']['f1-score']:.4f}")
    print(f"SPAM Recall: {rep_c['SPAM']['recall']:.4f} | F1: {rep_c['SPAM']['f1-score']:.4f}")
    print(f"SAFE Recall: {rep_c['SAFE']['recall']:.4f} | F1: {rep_c['SAFE']['f1-score']:.4f}")
    
    model_dir = os.path.join(_ROOT, "backend", "models", "scam_classifier")
    os.makedirs(model_dir, exist_ok=True)
    
    joblib.dump(clf, os.path.join(model_dir, "sklearn_model.joblib"))
    joblib.dump(vectorizer, os.path.join(model_dir, "vectorizer.joblib"))
    
    with open(os.path.join(model_dir, "label_mapping.json"), "w") as f:
        json.dump({
            "label2id": label2id,
            "id2label": {str(k): v for k, v in id2label.items()},
            "model_type": "tfidf_ngram_logistic_regression",
            "val_scam_recall": rep_c["SCAM"]["recall"],
            "val_scam_f1": rep_c["SCAM"]["f1-score"],
            "val_macro_f1": rep_c["macro avg"]["f1-score"],
            "total_samples": len(all_data)
        }, f, indent=2)
        
    print(f"Saved upgraded backend models to {model_dir}")

if __name__ == "__main__":
    main()
