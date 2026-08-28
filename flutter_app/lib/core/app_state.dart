// App state management for ScameGo
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scam_event.dart';
import '../models/campaign.dart';
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
  
  // Today's stats
  int _callsScanned = 0;
  int _messagesChecked = 0;
  int _scamsDetected = 0;
  double _currentExposure = 0.0;
  
  // History
  final List<ScamEvent> _scamHistory = [];
  final List<Campaign> _campaigns = [];
  final List<TrustedContact> _trustedContacts = [];
  
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
  
  // Getters
  bool get isProtectionEnabled => _isProtectionEnabled;
  bool get isCallProtectionEnabled => _isCallProtectionEnabled;
  bool get isSmsProtectionEnabled => _isSmsProtectionEnabled;
  bool get isSocialProtectionEnabled => _isSocialProtectionEnabled;
  bool get isPaymentProtectionEnabled => _isPaymentProtectionEnabled;
  
  int get callsScanned => _callsScanned;
  int get messagesChecked => _messagesChecked;
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
}