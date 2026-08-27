# Initialize services module
from app.services.ml_analysis_service import ml_service
from app.services.database_service import DatabaseService
from app.services.scam_analysis_pipeline import analyze_content
from app.services.instagram_collector import start_monitoring, stop_monitoring, is_session_expired
