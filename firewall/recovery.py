VERIFIED_CONTACTS = [
    {"name": "National Cyber Crime Reporting Portal (India)", "channel": "web", "value": "cybercrime.gov.in", "note": "Official government portal"},
    {"name": "Cyber fraud helpline", "channel": "phone", "value": "1930", "note": "National Do-Not-Disturb / cyber fraud helpline"},
    {"name": "RBI Ombudsman", "channel": "phone", "value": "14440", "note": "Reserve Bank of India grievance helpline"},
    {"name": "RBI complaint portal", "channel": "web", "value": "cms.rbi.org.in", "note": "Reserve Bank of India CMS"},
    {"name": "Your bank's published customer care", "channel": "phone", "value": "Use the number printed on your bank card or official website", "note": "Never call a number given by the caller"},
]

RECOVERY_STEPS = [
    {"order": 1, "title": "Do not send any more money or information", "text": "Stop all communication with the caller or sender right now."},
    {"order": 2, "title": "Contact your bank immediately", "text": "Use the number on the back of your debit card or your bank's official app. Ask them to freeze your account or cards."},
    {"order": 3, "title": "Call 1930", "text": "Report the fraud to the national cyber fraud helpline. This increases the chance of blocking a same-day transfer."},
    {"order": 4, "title": "Report on cybercrime.gov.in", "text": "File a complaint on the official National Cyber Crime Reporting Portal."},
    {"order": 5, "title": "Change your passwords and PINs", "text": "Change internet-banking, email and app passwords. Do it on a secure device."},
    {"order": 6, "title": "Revoke suspicious app access", "text": "Uninstall any remote-control app you were asked to install. Remove app access in Google account settings and from your phone."},
    {"order": 7, "title": "Tell a trusted family member", "text": "Do not handle this alone. A family member can help you act quickly."},
    {"order": 8, "title": "Save the evidence", "text": "Keep the message, the number, screenshots and transaction references. Do not delete anything yet."},
]

REPORTING_STEPS = [
    {"order": 1, "title": "National Cyber Crime Helpline", "text": "Dial 1930 as soon as possible, especially for same-day UPI transfers."},
    {"order": 2, "title": "National Cyber Crime Portal", "text": "Visit cybercrime.gov.in and file a complaint. Keep the complaint number."},
    {"order": 3, "title": "Inform your bank", "text": "Report the transaction and request a charge-back/freeze if still possible."},
]


def recovery_plan(scam_type=""):
    return {
        "title": "What should I do now?",
        "intro": "You may have been targeted by a scam. Follow these steps to protect yourself.",
        "verified_contacts": VERIFIED_CONTACTS,
        "recovery_steps": RECOVERY_STEPS,
        "reporting_steps": REPORTING_STEPS,
    }


def reporting_plan():
    return REPORTING_STEPS