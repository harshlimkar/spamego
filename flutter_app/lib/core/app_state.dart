// App state management for ScameGo
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scam_event.dart';
import '../models/campaign.dart';
import '../models/campaign_alert.dart';
import '../models/trusted_contact.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  
  // Protection status
  bool _isProtectionEnabled = true;
  bool _isCallProtectionEnabled = true;
  bool _isSmsProtectionEnabled = true;
  bool _isSocialProtectionEnabled = false;
  bool _isPaymentProtectionEnabled = true;
  bool _isNotificationProtectionEnabled = true;
  bool _isMessagingProtectionEnabled = true;
  bool _isBankingProtectionEnabled = true;
  
  // Today's stats
  int _callsScanned = 0;
  int _messagesChecked = 0;
  int _notificationsScanned = 0;
  int _scamsDetected = 0;
  double _currentExposure = 0.0;
  
  // History
  final List<ScamEvent> _scamHistory = [];
  final List<Campaign> _campaigns = [];
  final List<TrustedContact> _trustedContacts = [];
  
  // Campaign Alerts
  CampaignAlert? _latestCampaignAlert;
  final Set<String> _processedCampaignAlertIds = {};
  
  // Temporarily reported spam numbers
  final Set<String> _reportedSpamNumbers = {};
  
  CampaignAlert? get latestCampaignAlert => _latestCampaignAlert;
  Set<String> get reportedSpamNumbers => _reportedSpamNumbers;
  
  void reportSpamNumber(String number) {
    if (number.isNotEmpty) {
      _reportedSpamNumbers.add(number);
      notifyListeners();
    }
  }
  
  bool isNumberReportedSpam(String number) => _reportedSpamNumbers.contains(number);
  
  // Settings
  bool _alertLowRisk = false;
  bool _alertHighRisk = true;
  bool _alertCritical = true;
  String _selectedLanguage = 'en';
  bool _cloudAnalysisEnabled = true;
  bool _localAnalysisEnabled = true;
  int _dataRetentionDays = 90;
  
  // Family alerts
  bool _familyAlertOnCritical = true;
  bool _familyAlertOnPaymentRisk = true;
  bool _familyAlertOnRepeatAttempts = false;
  bool _familyAlertOnOtpRequest = false;
  bool _familyAlertOnRemoteAccess = false;
  bool _automaticCriticalAlerts = false; // New preference for Campaign Alerts
  
  bool get automaticCriticalAlerts => _automaticCriticalAlerts;
  bool get isProtectionEnabled => _isProtectionEnabled;
  bool get isCallProtectionEnabled => _isCallProtectionEnabled;
  bool get isSmsProtectionEnabled => _isSmsProtectionEnabled;
  bool get isSocialProtectionEnabled => _isSocialProtectionEnabled;
  bool get isPaymentProtectionEnabled => _isPaymentProtectionEnabled;
  bool get isNotificationProtectionEnabled => _isNotificationProtectionEnabled;
  bool get isMessagingProtectionEnabled => _isMessagingProtectionEnabled;
  bool get isBankingProtectionEnabled => _isBankingProtectionEnabled;
  
  int get callsScanned => _callsScanned;
  int get messagesChecked => _messagesChecked;
  int get notificationsScanned => _notificationsScanned;
  int get scamsDetected => _scamsDetected;
  double get currentExposure => _currentExposure;
  
  List<ScamEvent> get scamHistory => List.unmodifiable(_scamHistory);
  List<Campaign> get campaigns => List.unmodifiable(_campaigns);
  List<TrustedContact> get trustedContacts => List.unmodifiable(_trustedContacts);
  
  bool get alertLowRisk => _alertLowRisk;
  bool get alertHighRisk => _alertHighRisk;
  bool get alertCritical => _alertCritical;
  String get selectedLanguage => _selectedLanguage;
  bool get cloudAnalysisEnabled => _cloudAnalysisEnabled;
  bool get localAnalysisEnabled => _localAnalysisEnabled;
  int get dataRetentionDays => _dataRetentionDays;
  
  bool get familyAlertOnCritical => _familyAlertOnCritical;
  bool get familyAlertOnPaymentRisk => _familyAlertOnPaymentRisk;
  bool get familyAlertOnRepeatAttempts => _familyAlertOnRepeatAttempts;
  bool get familyAlertOnOtpRequest => _familyAlertOnOtpRequest;
  bool get familyAlertOnRemoteAccess => _familyAlertOnRemoteAccess;
  
  // Overall protection status
  String get protectionStatus {
    if (!_isProtectionEnabled) return 'disabled';
    if (_scamsDetected > 0) return 'warning';
    return 'protected';
  }
  
  Future<void> initialize() async {
    await _storage.initialize();
    await _loadFromStorage();
  }
  
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    
    _isProtectionEnabled = prefs.getBool('protection_enabled') ?? true;
    _isCallProtectionEnabled = prefs.getBool('call_protection_enabled') ?? true;
    _isSmsProtectionEnabled = prefs.getBool('sms_protection_enabled') ?? true;
    _isSocialProtectionEnabled = prefs.getBool('social_protection_enabled') ?? false;
    _isPaymentProtectionEnabled = prefs.getBool('payment_protection_enabled') ?? true;
    _isNotificationProtectionEnabled = prefs.getBool('notification_protection_enabled') ?? true;
    _isMessagingProtectionEnabled = prefs.getBool('messaging_protection_enabled') ?? true;
    _isBankingProtectionEnabled = prefs.getBool('banking_protection_enabled') ?? true;
    
    _alertLowRisk = prefs.getBool('alert_low_risk') ?? false;
    _alertHighRisk = prefs.getBool('alert_high_risk') ?? true;
    _alertCritical = prefs.getBool('alert_critical') ?? true;
    _selectedLanguage = prefs.getString('selected_language') ?? 'en';
    _cloudAnalysisEnabled = prefs.getBool('cloud_analysis_enabled') ?? true;
    _localAnalysisEnabled = prefs.getBool('local_analysis_enabled') ?? true;
    _dataRetentionDays = prefs.getInt('data_retention_days') ?? 90;
    
    _familyAlertOnCritical = prefs.getBool('family_alert_critical') ?? true;
    _familyAlertOnPaymentRisk = prefs.getBool('family_alert_payment') ?? true;
    _familyAlertOnRepeatAttempts = prefs.getBool('family_alert_repeat') ?? false;
    _familyAlertOnOtpRequest = prefs.getBool('family_alert_otp') ?? false;
    _familyAlertOnRemoteAccess = prefs.getBool('family_alert_remote') ?? false;
    
    // Load history from database
    _scamHistory.addAll(await _storage.getScamHistory());
    _campaigns.addAll(await _storage.getCampaigns());
    _trustedContacts.addAll(await _storage.getTrustedContacts());
    
    // Calculate today's stats
    _calculateTodaysStats();
    notifyListeners();
  }
  
  void _calculateTodaysStats() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    _callsScanned = _scamHistory
        .where((e) => e.channel == 'call' && e.timestamp.isAfter(todayStart))
        .length;
    _messagesChecked = _scamHistory
        .where((e) => e.channel == 'sms' && e.timestamp.isAfter(todayStart))
        .length;
    _notificationsScanned = _scamHistory
        .where((e) => e.channel != 'sms' && e.channel != 'call' && e.timestamp.isAfter(todayStart))
        .length;
    _scamsDetected = _scamHistory
        .where((e) => e.risk.level != 'safe' && e.timestamp.isAfter(todayStart))
        .length;
    _currentExposure = _campaigns
        .where((c) => c.exposure.moneyInr > 0)
        .fold(0.0, (sum, c) => sum + c.exposure.moneyInr);
  }
  
  // Protection toggles
  Future<void> setProtectionEnabled(bool enabled) async {
    _isProtectionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('protection_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setCallProtectionEnabled(bool enabled) async {
    _isCallProtectionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('call_protection_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setSmsProtectionEnabled(bool enabled) async {
    _isSmsProtectionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sms_protection_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setSocialProtectionEnabled(bool enabled) async {
    _isSocialProtectionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('social_protection_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setPaymentProtectionEnabled(bool enabled) async {
    _isPaymentProtectionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('payment_protection_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setNotificationProtectionEnabled(bool enabled) async {
    _isNotificationProtectionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_protection_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setMessagingProtectionEnabled(bool enabled) async {
    _isMessagingProtectionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('messaging_protection_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setBankingProtectionEnabled(bool enabled) async {
    _isBankingProtectionEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('banking_protection_enabled', enabled);
    notifyListeners();
  }
  
  // Alert preferences
  Future<void> setAlertLowRisk(bool enabled) async {
    _alertLowRisk = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alert_low_risk', enabled);
    notifyListeners();
  }
  
  Future<void> setAlertHighRisk(bool enabled) async {
    _alertHighRisk = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alert_high_risk', enabled);
    notifyListeners();
  }
  
  Future<void> setAlertCritical(bool enabled) async {
    _alertCritical = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alert_critical', enabled);
    notifyListeners();
  }
  
  // Language
  Future<void> setLanguage(String language) async {
    _selectedLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
    notifyListeners();
  }
  
  // Privacy settings
  Future<void> setCloudAnalysisEnabled(bool enabled) async {
    _cloudAnalysisEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('cloud_analysis_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setLocalAnalysisEnabled(bool enabled) async {
    _localAnalysisEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('local_analysis_enabled', enabled);
    notifyListeners();
  }
  
  Future<void> setDataRetentionDays(int days) async {
    _dataRetentionDays = days;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('data_retention_days', days);
    notifyListeners();
  }
  
  // Family alerts
  Future<void> setFamilyAlertOnCritical(bool enabled) async {
    _familyAlertOnCritical = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('family_alert_critical', enabled);
    notifyListeners();
  }
  
  Future<void> setFamilyAlertOnPaymentRisk(bool enabled) async {
    _familyAlertOnPaymentRisk = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('family_alert_payment', enabled);
    notifyListeners();
  }
  
  Future<void> setFamilyAlertOnRepeatAttempts(bool enabled) async {
    _familyAlertOnRepeatAttempts = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('family_alert_repeat', enabled);
    notifyListeners();
  }
  
  Future<void> setFamilyAlertOnOtpRequest(bool enabled) async {
    _familyAlertOnOtpRequest = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('family_alert_otp', enabled);
    notifyListeners();
  }
  
  Future<void> setFamilyAlertOnRemoteAccess(bool enabled) async {
    _familyAlertOnRemoteAccess = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('family_alert_remote', enabled);
    notifyListeners();
  }
  
  // Trusted contacts
  Future<void> addTrustedContact(TrustedContact contact) async {
    await _storage.addTrustedContact(contact);
    _trustedContacts.add(contact);
    notifyListeners();
  }
  
  Future<void> removeTrustedContact(String id) async {
    await _storage.removeTrustedContact(id);
    _trustedContacts.removeWhere((c) => c.id == id);
    notifyListeners();
  }
  
  Future<void> updateTrustedContact(TrustedContact contact) async {
    await _storage.updateTrustedContact(contact);
    final index = _trustedContacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _trustedContacts[index] = contact;
      notifyListeners();
    }
  }
  
  // Scam history
  Future<void> addScamEvent(ScamEvent event) async {
    await _storage.addScamEvent(event);
    _scamHistory.insert(0, event);
    _calculateTodaysStats();
    notifyListeners();
  }
  
  Future<void> addCampaign(Campaign campaign) async {
    await _storage.addCampaign(campaign);
    _campaigns.add(campaign);
    _calculateTodaysStats();
    notifyListeners();
  }
  
  Future<void> updateCampaign(Campaign campaign) async {
    await _storage.updateCampaign(campaign);
    final index = _campaigns.indexWhere((c) => c.id == campaign.id);
    if (index != -1) {
      _campaigns[index] = campaign;
      _calculateTodaysStats();
      notifyListeners();
    }
  }
  
  Future<void> clearHistory() async {
    await _storage.clearHistory();
    _scamHistory.clear();
    _campaigns.clear();
    _calculateTodaysStats();
    notifyListeners();
  }
  
  // Get campaign by ID
  Campaign? getCampaignById(String id) {
    try {
      return _campaigns.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
  
  // Get events for a campaign
  List<ScamEvent> getEventsForCampaign(String campaignId) {
    return _scamHistory.where((e) => e.campaign.campaignId == campaignId).toList();
  }

  // ── Demo Scenario ─────────────────────────────────────────────────────────────
  // Injects a realistic 5-event hackathon demo: SMS → Call → OTP → Link → Payment
  Future<void> runDemoScenario() async {
    const campaignId = 'CAMP-DEMO-2024';
    final now = DateTime.now();

    // Clear previous demo data
    _scamHistory.removeWhere((e) => e.campaign.campaignId == campaignId);
    _campaigns.removeWhere((c) => c.id == campaignId);

    // Demo campaign
    final demoCampaign = Campaign(
      id: campaignId,
      riskScore: 95,
      riskLevel: 'critical',
      categories: ['bank_impersonation', 'otp_theft', 'payment_fraud'],
      stageHistory: [],
      velocitySeconds: 480,
      exposure: const Exposure(
        moneyInr: 50000,
        credentialRisk: 'high',
        otpRequested: true,
        deviceAccessRequested: false,
        accountAccessPossible: true,
        description: '₹50,000 payment attempted after credential harvesting',
      ),
      eventCount: 5,
      channels: ['sms', 'call', 'payment'],
      createdAt: now.subtract(const Duration(minutes: 40)),
      updatedAt: now,
      isActive: true,
    );

    final campaignInfo = CampaignInfo(
      campaignId: campaignId,
      riskScore: 95,
      riskLevel: 'critical',
      categories: ['bank_impersonation', 'otp_theft'],
      eventCount: 5,
      channels: ['sms', 'call', 'payment'],
      exposure: const Exposure(
        moneyInr: 50000,
        credentialRisk: 'high',
        otpRequested: true,
        accountAccessPossible: true,
        description: '₹50,000 payment attempted after credential harvesting',
      ),
      createdAt: now.subtract(const Duration(minutes: 40)).toIso8601String(),
      updatedAt: now.toIso8601String(),
    );

    final events = [
      // Event 1: Bank KYC SMS (30 mins ago)
      ScamEvent(
        id: 'demo_sms_1',
        channel: 'sms',
        timestamp: now.subtract(const Duration(minutes: 35)),
        sender: '+918800123456',
        text: 'URGENT: Your SBI account KYC has expired. Your account will be blocked today. Click http://sbi-kyc-secure.xyz to update now.',
        normalized: 'urgent your sbi account kyc has expired your account will be blocked today click to update now',
        language: 'en',
        verdict: 'SCAM',
        headline: 'Bank KYC Impersonation — SBI lookalike link detected',
        risk: const RiskResult(
          score: 82,
          level: 'high',
          confidence: 0.94,
          explanations: [
            'Sender is an unknown mobile number, not a bank DLT header',
            'Urgency language: "will be blocked today"',
            'Suspicious link: sbi-kyc-secure.xyz is a lookalike of sbi.co.in',
            'KYC theme is the #1 bank impersonation pattern in India',
          ],
        ),
        campaign: campaignInfo,
        intervention: const Intervention(
          action: 'WARN',
          title: 'Suspicious Message',
          message: 'This looks like a bank impersonation scam. Do not click the link or share any details.',
          buttons: ['IGNORE', 'REPORT'],
        ),
        familyAlert: const FamilyAlertDecision(alertSent: false, risk: 'high'),
        intents: const [
          Intent(name: 'kyc_fraud', label: 'KYC Fraud / Bank Impersonation', confidence: 0.96),
        ],
        stage: const ScamStage(stage: 'delivery', label: 'Scam Delivered', confidence: 0.95),
        linkFindings: const [
          LinkFinding(
            url: 'http://sbi-kyc-secure.xyz',
            normalizedUrl: 'sbi-kyc-secure.xyz',
            domain: 'sbi-kyc-secure.xyz',
            registrableDomain: 'sbi-kyc-secure.xyz',
            isSuspicious: true,
            reason: 'Lookalike of sbi.co.in — scam domain',
            verdict: 'dangerous',
          ),
        ],
      ),

      // Event 2: Scam Call pretexting (20 mins ago)
      ScamEvent(
        id: 'demo_call_1',
        channel: 'call',
        timestamp: now.subtract(const Duration(minutes: 22)),
        sender: '+918800123457',
        text: 'Hello I am calling from SBI bank. Your KYC is not updated. Your account will be blocked. Please verify yourself.',
        normalized: 'hello calling from sbi bank kyc not updated account will be blocked please verify',
        language: 'en',
        verdict: 'SCAM',
        headline: 'Vishing Call — SBI impersonation with account threat',
        risk: const RiskResult(
          score: 88,
          level: 'high',
          confidence: 0.91,
          explanations: [
            'Caller claims to be from SBI bank but uses an unknown mobile number',
            'Matches known vishing script: KYC + block threat + verification request',
            'Correlated with SMS scam from same campaign 13 minutes earlier',
            'Classic pretexting stage of scam kill-chain',
          ],
        ),
        campaign: campaignInfo,
        intervention: const Intervention(
          action: 'WARN',
          title: 'Suspicious Call in Progress',
          message: 'This caller is likely impersonating SBI bank. Real banks NEVER call to verify KYC. Do not share any information.',
          buttons: ['HANG UP', 'CALL REAL BANK'],
        ),
        familyAlert: const FamilyAlertDecision(alertSent: false, risk: 'high'),
        stage: const ScamStage(stage: 'pretexting', label: 'Establishing False Context', confidence: 0.92),
        intents: const [
          Intent(name: 'vishing_bank', label: 'Voice Phishing — Bank Impersonation', confidence: 0.91),
        ],
      ),

      // Event 3: OTP request call (15 mins ago)
      ScamEvent(
        id: 'demo_call_2',
        channel: 'call',
        timestamp: now.subtract(const Duration(minutes: 15)),
        sender: '+918800123457',
        text: 'Sir please tell me the OTP you just received on your registered mobile number to verify your account.',
        normalized: 'sir please tell me the otp you just received on your registered mobile number to verify your account',
        language: 'en',
        verdict: 'CRITICAL SCAM',
        headline: '🚨 OTP Theft Attempt — Do NOT share your OTP',
        risk: const RiskResult(
          score: 96,
          level: 'critical',
          confidence: 0.98,
          explanations: [
            'CRITICAL: Scammer is directly asking for OTP — this is OTP theft',
            'Real banks will NEVER ask for OTP over the phone',
            'OTP request escalates campaign to credential harvesting stage',
            'Combined with previous call and SMS from same number',
          ],
        ),
        campaign: campaignInfo,
        intervention: const Intervention(
          action: 'STOP',
          title: '🚨 DO NOT SHARE YOUR OTP',
          message: 'This is an OTP theft scam. Sharing your OTP will give this person full access to your bank account. HANG UP NOW.',
          buttons: ['HANG UP NOW', 'CALL 1930', 'ALERT FAMILY'],
        ),
        familyAlert: const FamilyAlertDecision(alertSent: true, recipient: 'Family', risk: 'critical', messagePreview: 'OTP theft attempt detected'),
        otp: const OtpFinding(
          context: 'theft_request',
          label: 'Scammer requesting OTP from victim',
          isRisky: true,
          reason: 'Caller is asking for OTP over phone — classic OTP theft pattern',
        ),
        stage: const ScamStage(stage: 'credential_harvesting', label: 'OTP Theft Attempt', confidence: 0.98),
        intents: const [
          Intent(name: 'otp_theft', label: 'OTP Theft — Credential Harvesting', confidence: 0.98),
        ],
      ),

      // Event 4: Payment attempt (8 mins ago)
      ScamEvent(
        id: 'demo_payment_1',
        channel: 'payment',
        timestamp: now.subtract(const Duration(minutes: 8)),
        sender: 'scammer@upi',
        text: 'UPI Payment Request: ₹50,000 to scammer@upi — "KYC Verification Fee"',
        normalized: 'upi payment request 50000 kyc verification fee',
        language: 'en',
        verdict: 'CRITICAL SCAM',
        headline: '🚨 CRITICAL: ₹50,000 payment to scammer after KYC scam call',
        risk: const RiskResult(
          score: 98,
          level: 'critical',
          confidence: 0.99,
          explanations: [
            'Payment requested immediately after confirmed OTP theft attempt',
            '₹50,000 is far above normal transaction for this pattern',
            '"KYC verification fee" is a known fraud tactic — banks charge no fees',
            'UPI ID format is suspicious — not associated with any bank',
            'Campaign correlation: 4th event in CAMP-DEMO-2024 with escalating risk',
          ],
        ),
        campaign: campaignInfo,
        intervention: const Intervention(
          action: 'STOP',
          title: '🚨 DO NOT MAKE THIS PAYMENT',
          message: 'Banks do NOT charge KYC fees via UPI. This is a payment fraud attempt following the scam call from earlier. You must NOT proceed.',
          buttons: ['CANCEL PAYMENT', 'CALL BANK', 'CALL 1930'],
        ),
        familyAlert: const FamilyAlertDecision(alertSent: true, recipient: 'Family', risk: 'critical', messagePreview: '₹50,000 payment fraud attempt detected'),
        stage: const ScamStage(stage: 'exploitation', label: 'Financial Exploitation Attempt', confidence: 0.99),
      ),

      // Event 5: Recovery advisory (now)
      ScamEvent(
        id: 'demo_recovery_1',
        channel: 'sms',
        timestamp: now.subtract(const Duration(minutes: 1)),
        sender: 'ScameGo',
        text: 'ScameGo has blocked a ₹50,000 fraud attempt. Your family has been notified. Tap to see recovery steps.',
        normalized: 'scamego blocked 50000 fraud attempt family notified recovery steps',
        language: 'en',
        verdict: 'PROTECTED',
        headline: '✅ Scam Blocked — Recovery guidance available',
        risk: const RiskResult(
          score: 0,
          level: 'safe',
          confidence: 1.0,
        ),
        campaign: campaignInfo,
        intervention: const Intervention(
          action: 'INFORM',
          title: 'Scam Attempt Blocked',
          message: 'ScameGo has protected you. Review the recovery steps to secure your account.',
          buttons: ['VIEW RECOVERY STEPS'],
        ),
        familyAlert: const FamilyAlertDecision(alertSent: true, recipient: 'Family', risk: 'critical'),
        recovery: const RecoveryPlan(
          title: 'Bank KYC Scam Recovery',
          intro: 'You were targeted by a sophisticated bank impersonation scam. Here is what to do next.',
          recoverySteps: [
            RecoveryStep(order: 1, title: 'Do NOT share OTP', text: 'If you received an OTP, do not share it with anyone'),
            RecoveryStep(order: 2, title: 'Call your bank', text: 'Call SBI on 1800-11-2211 to report the contact'),
            RecoveryStep(order: 3, title: 'Call 1930', text: 'Report to national cyber fraud helpline'),
            RecoveryStep(order: 4, title: 'Change your password', text: 'Update your net banking password immediately'),
          ],
        ),
      ),
    ];

    // Add all demo events (reverse order so newest appears first)
    for (final event in events.reversed) {
      _scamHistory.insert(0, event);
      await _storage.addScamEvent(event);
    }

    // Add the demo campaign
    _campaigns.insert(0, demoCampaign);
    await _storage.addCampaign(demoCampaign);

    _calculateTodaysStats();
    notifyListeners();
  void toggleAutomaticCriticalAlerts(bool value) {
    _automaticCriticalAlerts = value;
    _storage.savePreferences({'automatic_critical_alerts': value});
    notifyListeners();
  }

  bool processCampaignAlert(CampaignAlert alert) {
    // Duplicate Protection logic
    final String dedupeKey = '${alert.campaignId}_${alert.threatLevel}_${alert.cumulativeRisk}';
    
    if (_processedCampaignAlertIds.contains(dedupeKey)) {
      return false; // Already processed this exact alert state
    }
    
    _processedCampaignAlertIds.add(dedupeKey);
    _latestCampaignAlert = alert;
    notifyListeners();
    
    // Only return true if it is a critical threat (triggers navigation/notification)
    if (alert.cumulativeRisk >= 85 || alert.threatLevel == 'CRITICAL_ATTACK') {
      return true;
    }
    
    return false;
  }
}