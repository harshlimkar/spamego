import sys
import os
from database.db_setup import init_db, seed_db
from database.repository import UserRepository
from trusted.trusted_manager import TrustedManager
from main import ScameGoApp

def run_automated_demo():
    print("--- STARTING AUTOMATED DEMO TEST ---\n")
    
    # Initialize fresh DB
    init_db()
    seed_db()
    
    # Force profile creation without input()
    user_repo = UserRepository()
    trusted_mgr = TrustedManager()
    
    user_repo.create_profile("Alice", "English", "+911111111111")
    trusted_mgr.add_contact("Bob", "+912222222222", "Son")
    
    # Instantiate app and start server
    app = ScameGoApp()
    app.start_server()
    
    try:
        # Instead of calling run_demo which might have setup prompt, we run it directly
        # Wait, run_demo checks profile. Since we created it, it won't prompt.
        app.run_demo()
        
        # Also test the sync feature
        print("\n>>> TESTING DATA SYNC")
        app.remote_client.sync_threat_intelligence()
    finally:
        if app.server_process:
            app.server_process.terminate()
            
    print("\n--- AUTOMATED DEMO TEST COMPLETE ---")

if __name__ == "__main__":
    run_automated_demo()
