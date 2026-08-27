class DTMFHandler:
    @staticmethod
    def get_action(key):
        key = str(key).strip()
        if key == '1':
            return "CONTINUE"
        elif key == '2':
            return "END_CALL"
        elif key == '3':
            return "TRUSTED_CONTACT"
        elif key == '4':
            return "REPEAT"
        elif key == '5':
            return "REASON"
        return "UNKNOWN"
