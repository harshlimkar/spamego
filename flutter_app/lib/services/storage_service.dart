// Local storage service using SQLite
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/scam_event.dart';
import '../models/campaign.dart';
import '../models/trusted_contact.dart';

class StorageService {
  static Database? _database;
  static const String _dbName = 'scamego.db';
  static const int _dbVersion = 1;
  
  Future<void> initialize() async {
    if (_database != null) return;
    
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);
    
    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Scam events table
    await db.execute('''
      CREATE TABLE scam_events (
        id TEXT PRIMARY KEY,
        channel TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        sender TEXT NOT NULL,
        text TEXT NOT NULL,
        normalized TEXT,
        language TEXT,
        verdict TEXT,
        headline TEXT,
        risk_json TEXT NOT NULL,
        campaign_json TEXT,
        intervention_json TEXT,
        family_alert_json TEXT,
        recovery_json TEXT,
        support_sms TEXT,
        entities_json TEXT,
        intents_json TEXT,
        stage_json TEXT,
        link_findings_json TEXT,
        otp_json TEXT,
        verification_json TEXT,
        ml_json TEXT
      )
    ''');
    
    // Campaigns table
    await db.execute('''
      CREATE TABLE campaigns (
        id TEXT PRIMARY KEY,
        risk_score INTEGER NOT NULL,
        risk_level TEXT NOT NULL,
        categories TEXT,
        stage_history TEXT,
        velocity_seconds REAL,
        exposure_json TEXT,
        event_count INTEGER DEFAULT 0,
        channels TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_active INTEGER DEFAULT 1
      )
    ''');
    
    // Trusted contacts table
    await db.execute('''
      CREATE TABLE trusted_contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        relationship TEXT NOT NULL,
        priority INTEGER DEFAULT 1,
        consent INTEGER DEFAULT 1,
        is_primary INTEGER DEFAULT 0,
        added_at INTEGER
      )
    ''');
    
    // Indexes for performance
    await db.execute('CREATE INDEX idx_scam_events_timestamp ON scam_events(timestamp)');
    await db.execute('CREATE INDEX idx_scam_events_channel ON scam_events(channel)');
    await db.execute('CREATE INDEX idx_scam_events_campaign ON scam_events(campaign_json)');
    await db.execute('CREATE INDEX idx_campaigns_updated ON campaigns(updated_at)');
  }
  
  Database get database {
    if (_database == null) {
      throw StateError('StorageService not initialized. Call initialize() first.');
    }
    return _database!;
  }
  
  // Scam Events
  Future<void> addScamEvent(ScamEvent event) async {
    final db = database;
    await db.insert('scam_events', {
      'id': event.id,
      'channel': event.channel,
      'timestamp': event.timestamp.millisecondsSinceEpoch,
      'sender': event.sender,
      'text': event.text,
      'normalized': event.normalized,
      'language': event.language,
      'verdict': event.verdict,
      'headline': event.headline,
      'risk_json': event.risk.toJson(),
      'campaign_json': event.campaign.toJson(),
      'intervention_json': event.intervention.toJson(),
      'family_alert_json': event.familyAlert.toJson(),
      'recovery_json': event.recovery?.toJson(),
      'support_sms': event.supportSms,
      'entities_json': event.entities,
      'intents_json': event.intents?.map((e) => e.toJson()).toList(),
      'stage_json': event.stage?.toJson(),
      'link_findings_json': event.linkFindings?.map((e) => e.toJson()).toList(),
      'otp_json': event.otp?.toJson(),
      'verification_json': event.verification?.toJson(),
      'ml_json': event.ml,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<List<ScamEvent>> getScamHistory({int limit = 100, int offset = 0}) async {
    final db = database;
    final maps = await db.query(
      'scam_events',
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
    
    return maps.map((map) => _mapToScamEvent(map)).toList();
  }
  
  ScamEvent _mapToScamEvent(Map<String, dynamic> map) {
    return ScamEvent(
      id: map['id'] as String,
      channel: map['channel'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      sender: map['sender'] as String,
      text: map['text'] as String,
      normalized: map['normalized'] as String? ?? '',
      language: map['language'] as String? ?? 'en',
      verdict: map['verdict'] as String? ?? 'UNKNOWN',
      headline: map['headline'] as String? ?? '',
      risk: RiskResult.fromJson(map['risk_json'] as Map<String, dynamic>),
      campaign: CampaignInfo.fromJson(map['campaign_json'] as Map<String, dynamic>? ?? {}),
      intervention: Intervention.fromJson(map['intervention_json'] as Map<String, dynamic>),
      familyAlert: FamilyAlertDecision.fromJson(map['family_alert_json'] as Map<String, dynamic>),
      recovery: map['recovery_json'] != null 
          ? RecoveryPlan.fromJson(map['recovery_json'] as Map<String, dynamic>)
          : null,
      supportSms: map['support_sms'] as String?,
      entities: map['entities_json'] as Map<String, dynamic>?,
      intents: (map['intents_json'] as List<dynamic>?)?.map((e) => Intent.fromJson(e as Map<String, dynamic>)).toList(),
      stage: map['stage_json'] != null 
          ? ScamStage.fromJson(map['stage_json'] as Map<String, dynamic>)
          : null,
      linkFindings: (map['link_findings_json'] as List<dynamic>?)?.map((e) => LinkFinding.fromJson(e as Map<String, dynamic>)).toList(),
      otp: map['otp_json'] != null 
          ? OtpFinding.fromJson(map['otp_json'] as Map<String, dynamic>)
          : null,
      verification: map['verification_json'] != null
          ? Verification.fromJson(map['verification_json'] as Map<String, dynamic>)
          : null,
      ml: map['ml_json'] as Map<String, dynamic>?,
    );
  }
  
  // Campaigns
  Future<void> addCampaign(Campaign campaign) async {
    final db = database;
    await db.insert('campaigns', {
      'id': campaign.id,
      'risk_score': campaign.riskScore,
      'risk_level': campaign.riskLevel,
      'categories': campaign.categories.join(','),
      'stage_history': campaign.stageHistory.map((s) => s.toJson()).toList().toString(),
      'velocity_seconds': campaign.velocitySeconds,
      'exposure_json': campaign.exposure.toJson(),
      'event_count': campaign.eventCount,
      'channels': campaign.channels.join(','),
      'created_at': campaign.createdAt.millisecondsSinceEpoch,
      'updated_at': campaign.updatedAt.millisecondsSinceEpoch,
      'is_active': campaign.isActive ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<void> updateCampaign(Campaign campaign) async {
    await addCampaign(campaign); // Uses replace
  }
  
  Future<List<Campaign>> getCampaigns() async {
    final db = database;
    final maps = await db.query('campaigns', orderBy: 'updated_at DESC');
    
    return maps.map((map) => _mapToCampaign(map)).toList();
  }
  
  Campaign _mapToCampaign(Map<String, dynamic> map) {
    return Campaign(
      id: map['id'] as String,
      riskScore: map['risk_score'] as int,
      riskLevel: map['risk_level'] as String,
      categories: (map['categories'] as String).split(',').where((s) => s.isNotEmpty).toList(),
      stageHistory: [], // Simplified for now
      velocitySeconds: map['velocity_seconds'] as double?,
      exposure: Exposure.fromJson(map['exposure_json'] as Map<String, dynamic>? ?? {}),
      eventCount: map['event_count'] as int? ?? 0,
      channels: (map['channels'] as String).split(',').where((s) => s.isNotEmpty).toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isActive: (map['is_active'] as int) == 1,
    );
  }
  
  // Trusted Contacts
  Future<void> addTrustedContact(TrustedContact contact) async {
    final db = database;
    await db.insert('trusted_contacts', {
      'id': contact.id,
      'name': contact.name,
      'phone_number': contact.phoneNumber,
      'relationship': contact.relationship,
      'priority': contact.priority,
      'consent': contact.consent ? 1 : 0,
      'is_primary': contact.isPrimary ? 1 : 0,
      'added_at': contact.addedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  Future<void> removeTrustedContact(String id) async {
    final db = database;
    await db.delete('trusted_contacts', where: 'id = ?', whereArgs: [id]);
  }
  
  Future<void> updateTrustedContact(TrustedContact contact) async {
    await addTrustedContact(contact);
  }
  
  Future<List<TrustedContact>> getTrustedContacts() async {
    final db = database;
    final maps = await db.query('trusted_contacts', orderBy: 'priority ASC');
    
    return maps.map((map) => TrustedContact(
      id: map['id'] as String,
      name: map['name'] as String,
      phoneNumber: map['phone_number'] as String,
      relationship: map['relationship'] as String,
      priority: map['priority'] as int? ?? 1,
      consent: (map['consent'] as int) == 1,
      isPrimary: (map['is_primary'] as int) == 1,
      addedAt: map['added_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['added_at'] as int)
          : null,
    )).toList();
  }
  
  Future<void> clearHistory() async {
    final db = database;
    await db.delete('scam_events');
    await db.delete('campaigns');
  }
  
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}