import os
import sqlite3
import pandas as pd
from datasets import load_dataset

def main():
    # Setup paths
    base_dir = os.path.dirname(os.path.abspath(__file__))
    dataset_dir = os.path.join(base_dir, "spam_dataset")
    os.makedirs(dataset_dir, exist_ok=True)
    
    db_path = os.path.join(dataset_dir, "india_spam_sms.db")
    
    print("Downloading CloveAI/india-spam-sms dataset...")
    # Load dataset
    ds = load_dataset("CloveAI/india-spam-sms")
    
    # Connect to SQLite
    conn = sqlite3.connect(db_path)
    
    # Iterate over splits (e.g., 'train', 'test', 'validation') if any exist
    for split_name in ds.keys():
        print(f"Processing split: {split_name}")
        
        # Convert to pandas DataFrame
        df = ds[split_name].to_pandas()
        
        # Save to SQLite table named after the split (or just "messages")
        table_name = f"messages_{split_name}" if len(ds.keys()) > 1 else "messages"
        
        df.to_sql(table_name, conn, if_exists="replace", index=False)
        print(f"Stored {len(df)} records in table '{table_name}'.")
        
        # Also save a CSV version for convenience in ML training
        csv_path = os.path.join(dataset_dir, f"{table_name}.csv")
        df.to_csv(csv_path, index=False)
        print(f"Saved CSV to {csv_path}")
        
    conn.close()
    print(f"Database successfully created at {db_path}")

if __name__ == "__main__":
    main()
