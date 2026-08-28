from core.models import NormalizedMessage

class ContextAnalyzer:
    """
    Analyzes multi-message conversations to detect escalating scams.
    """
    def __init__(self):
        # In-memory store for demo. In production, this would be backed by Redis or DB.
        self.active_conversations = {}

    def update_and_get_context(self, message: NormalizedMessage) -> dict:
        if not message.conversation_id:
            # Generate a temporary pseudo-ID based on sender if none provided
            conv_id = f"pseudo_{message.source}_{message.sender}"
        else:
            conv_id = message.conversation_id

        if conv_id not in self.active_conversations:
            self.active_conversations[conv_id] = {
                "message_count": 0,
                "previous_categories": set(),
                "escalation_score": 0,
                "history": []
            }
            
        ctx = self.active_conversations[conv_id]
        ctx["message_count"] += 1
        ctx["history"].append(message.message)
        
        # Keep last 10 messages only to prevent memory leak
        if len(ctx["history"]) > 10:
            ctx["history"] = ctx["history"][-10:]
            
        return ctx
        
    def add_categories_to_context(self, conv_id: str, categories: list):
        if conv_id in self.active_conversations:
            self.active_conversations[conv_id]["previous_categories"].update(categories)
