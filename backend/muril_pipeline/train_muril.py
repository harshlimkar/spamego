"""
train_muril.py
══════════════
Full fine-tuning pipeline for google/muril-base-cased.

Loads multilingual scam transcripts (Tamil, Hindi, Hinglish, English)
from dataset/scam_transcripts.csv, fine-tunes MuRIL for binary sequence
classification (0=SAFE, 1=SCAM), and saves the model to saved_model/.

Usage:
    python train_muril.py
    python train_muril.py --epochs 5 --batch_size 16 --lr 3e-5
"""

import os
import sys
import argparse
import logging
import re
import unicodedata
from pathlib import Path

import numpy as np
import pandas as pd
import torch
from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    accuracy_score,
    f1_score,
    precision_score,
    recall_score,
    classification_report,
)
from torch.utils.data import Dataset
from transformers import (
    AutoTokenizer,
    AutoModelForSequenceClassification,
    TrainingArguments,
    Trainer,
    EarlyStoppingCallback,
    DataCollatorWithPadding,
)

# ── Constants ─────────────────────────────────────────────────────────────────
BASE_MODEL_NAME = "google/muril-base-cased"
DATASET_DIR = Path(__file__).parent / "dataset"
SAVE_DIR = Path(__file__).parent / "saved_model"
LABEL2ID = {"SAFE": 0, "SCAM": 1}
ID2LABEL = {0: "SAFE", 1: "SCAM"}
MAX_TOKEN_LEN = 256

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger(__name__)


# ── Text Preprocessing ────────────────────────────────────────────────────────
def clean_text(text: str) -> str:
    """
    Normalise multilingual text (Tamil / Hindi / Hinglish / English).
    - Normalise Unicode (NFC)
    - Collapse repeated punctuation & whitespace
    - Remove URLs, emojis, and control characters
    - Preserve Devanagari, Tamil, and Latin scripts
    """
    if not isinstance(text, str):
        return ""

    # Unicode normalise
    text = unicodedata.normalize("NFC", text)

    # Remove URLs
    text = re.sub(r"http\S+|www\.\S+", " ", text)

    # Remove emojis / symbols (keep letters, digits, punctuation from Tamil+Hindi+Latin)
    text = re.sub(
        r"[^\w\s\u0900-\u097F\u0B80-\u0BFF\u0A00-\u0A7F.,!?;:\-']",
        " ",
        text,
        flags=re.UNICODE,
    )

    # Collapse whitespace
    text = re.sub(r"\s+", " ", text).strip()

    # Collapse repeated punctuation
    text = re.sub(r"([!?.]){2,}", r"\1", text)

    return text


# ── Dataset Class ─────────────────────────────────────────────────────────────
class ScamDataset(Dataset):
    """PyTorch Dataset for tokenised scam transcript records."""

    def __init__(self, encodings: dict, labels: list[int]):
        self.encodings = encodings
        self.labels = labels

    def __len__(self) -> int:
        return len(self.labels)

    def __getitem__(self, idx: int) -> dict:
        item = {key: torch.tensor(val[idx]) for key, val in self.encodings.items()}
        item["labels"] = torch.tensor(self.labels[idx], dtype=torch.long)
        return item


# ── Data Loading ──────────────────────────────────────────────────────────────
def load_all_csvs(dataset_dir: Path) -> pd.DataFrame:
    """
    Load all CSV files from dataset_dir.
    Each CSV must contain 'text' and 'label_is_scam' columns.
    Concatenates and deduplicates.
    """
    csv_files = list(dataset_dir.glob("*.csv"))
    if not csv_files:
        raise FileNotFoundError(
            f"No CSV files found in {dataset_dir}. "
            "Add a scam_transcripts.csv with 'text' and 'label_is_scam' columns."
        )

    frames = []
    for csv_file in csv_files:
        logger.info(f"Loading {csv_file.name}...")
        df = pd.read_csv(csv_file)

        required_cols = {"text", "label_is_scam"}
        if not required_cols.issubset(df.columns):
            logger.warning(
                f"Skipping {csv_file.name}: missing columns {required_cols - set(df.columns)}"
            )
            continue

        df = df[["text", "label_is_scam"]].dropna()
        df["label_is_scam"] = df["label_is_scam"].astype(int)
        frames.append(df)

    if not frames:
        raise ValueError("No valid CSV files with required columns found.")

    combined = pd.concat(frames, ignore_index=True).drop_duplicates(subset="text")
    logger.info(
        f"Loaded {len(combined)} total samples  "
        f"(SCAM={combined['label_is_scam'].sum()}, "
        f"SAFE={(combined['label_is_scam'] == 0).sum()})"
    )
    return combined


# ── Metrics ───────────────────────────────────────────────────────────────────
def compute_metrics(eval_pred) -> dict:
    """Compute accuracy, F1, precision and recall for the HuggingFace Trainer."""
    logits, labels = eval_pred
    predictions = np.argmax(logits, axis=-1)
    return {
        "accuracy":  accuracy_score(labels, predictions),
        "f1":        f1_score(labels, predictions, average="binary"),
        "precision": precision_score(labels, predictions, average="binary", zero_division=0),
        "recall":    recall_score(labels, predictions, average="binary", zero_division=0),
    }


# ── Main Training Function ────────────────────────────────────────────────────
def train(epochs: int = 4, batch_size: int = 8, learning_rate: float = 2e-5):
    logger.info(f"Device: {'CUDA' if torch.cuda.is_available() else 'CPU'}")
    device = "cuda" if torch.cuda.is_available() else "cpu"

    # ── 1. Load & clean data ────────────────────────────────────────────────
    df = load_all_csvs(DATASET_DIR)
    df["text"] = df["text"].apply(clean_text)
    df = df[df["text"].str.len() > 5]           # drop near-empty rows
    texts  = df["text"].tolist()
    labels = df["label_is_scam"].tolist()

    # ── 2. Train / validation split ─────────────────────────────────────────
    X_train, X_val, y_train, y_val = train_test_split(
        texts, labels,
        test_size=0.2,
        random_state=42,
        stratify=labels,
    )
    logger.info(f"Train={len(X_train)}  Val={len(X_val)}")

    # ── 3. Tokeniser ────────────────────────────────────────────────────────
    logger.info(f"Loading tokeniser from {BASE_MODEL_NAME} …")
    tokenizer = AutoTokenizer.from_pretrained(BASE_MODEL_NAME)

    def tokenise(texts_list: list[str]) -> dict:
        return tokenizer(
            texts_list,
            max_length=MAX_TOKEN_LEN,
            truncation=True,
            padding=True,          # DataCollatorWithPadding will re-pad per batch
        )

    train_enc = tokenise(X_train)
    val_enc   = tokenise(X_val)

    train_dataset = ScamDataset(train_enc, y_train)
    val_dataset   = ScamDataset(val_enc,   y_val)

    # ── 4. Model ────────────────────────────────────────────────────────────
    logger.info(f"Loading model {BASE_MODEL_NAME} …")
    model = AutoModelForSequenceClassification.from_pretrained(
        BASE_MODEL_NAME,
        num_labels=2,
        id2label=ID2LABEL,
        label2id=LABEL2ID,
        ignore_mismatched_sizes=True,
    )
    model.to(device)

    # ── 5. Training arguments ────────────────────────────────────────────────
    SAVE_DIR.mkdir(exist_ok=True)

    training_args = TrainingArguments(
        output_dir=str(SAVE_DIR / "checkpoints"),
        num_train_epochs=epochs,
        per_device_train_batch_size=batch_size,
        per_device_eval_batch_size=batch_size * 2,
        learning_rate=learning_rate,
        weight_decay=0.01,
        warmup_ratio=0.1,
        lr_scheduler_type="cosine",
        evaluation_strategy="epoch",
        save_strategy="epoch",
        load_best_model_at_end=True,
        metric_for_best_model="f1",
        greater_is_better=True,
        logging_strategy="steps",
        logging_steps=10,
        save_total_limit=2,
        fp16=torch.cuda.is_available(),   # mixed precision on GPU
        report_to="none",                  # disable W&B/TensorBoard
        dataloader_num_workers=0,          # Windows-safe
    )

    # ── 6. Trainer ───────────────────────────────────────────────────────────
    data_collator = DataCollatorWithPadding(tokenizer=tokenizer)

    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=val_dataset,
        tokenizer=tokenizer,
        data_collator=data_collator,
        compute_metrics=compute_metrics,
        callbacks=[EarlyStoppingCallback(early_stopping_patience=2)],
    )

    logger.info("══════════════════════════════════════════")
    logger.info("  Starting MuRIL fine-tuning …")
    logger.info("══════════════════════════════════════════")
    trainer.train()

    # ── 7. Final evaluation ─────────────────────────────────────────────────
    logger.info("Running final evaluation …")
    eval_results = trainer.evaluate()
    logger.info(f"Eval results: {eval_results}")

    # Detailed classification report
    preds_output = trainer.predict(val_dataset)
    preds = np.argmax(preds_output.predictions, axis=-1)
    logger.info("\n" + classification_report(y_val, preds, target_names=["SAFE", "SCAM"]))

    # ── 8. Save model + tokeniser ────────────────────────────────────────────
    logger.info(f"Saving fine-tuned model to {SAVE_DIR} …")
    trainer.save_model(str(SAVE_DIR))
    tokenizer.save_pretrained(str(SAVE_DIR))

    # Write label mapping
    import json
    with open(SAVE_DIR / "label_config.json", "w") as f:
        json.dump({"id2label": ID2LABEL, "label2id": LABEL2ID}, f)

    logger.info("✅ Training complete!")
    logger.info(f"   Model saved to: {SAVE_DIR.resolve()}")


# ── CLI Entry Point ───────────────────────────────────────────────────────────
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Fine-tune MuRIL for scam detection")
    parser.add_argument("--epochs",     type=int,   default=4,    help="Training epochs")
    parser.add_argument("--batch_size", type=int,   default=8,    help="Batch size per device")
    parser.add_argument("--lr",         type=float, default=2e-5, help="Learning rate")
    args = parser.parse_args()

    train(
        epochs=args.epochs,
        batch_size=args.batch_size,
        learning_rate=args.lr,
    )
