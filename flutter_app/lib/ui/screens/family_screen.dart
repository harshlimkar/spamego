// Family Screen — Trusted contacts & family alert management
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/trusted_contact.dart';
import '../theme/app_theme.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Family Alerts'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddContact(context, appState),
                tooltip: 'Add Trusted Contact',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Explanation card
                Card(
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.family_restroom, color: Colors.blue.shade700, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              'Family Alerts',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'When ScameGo detects a critical scam, it can automatically alert your trusted family members so they can help you.',
                          style: TextStyle(color: Colors.blue.shade800, fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '🔒 Only minimum necessary information is shared. Your full messages are never sent.',
                          style: TextStyle(color: Colors.blue.shade700, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Alert settings
                Text('Alert Settings', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                _AlertSettingsTile(appState: appState),
                const SizedBox(height: 24),

                // Trusted contacts
                Row(
                  children: [
                    Text(
                      'Trusted Contacts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${appState.trustedContacts.length}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (appState.trustedContacts.isEmpty)
                  _EmptyContactsState(onAdd: () => _showAddContact(context, appState))
                else
                  ...appState.trustedContacts.map((c) => _ContactCard(
                    contact: c,
                    onRemove: () => appState.removeTrustedContact(c.id),
                    onEdit: () => _showAddContact(context, appState, editing: c),
                  )),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddContact(context, appState),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Trusted Contact'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Demo alert button
                if (appState.trustedContacts.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 12),
                  Text('Demo', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showDemoAlert(context, appState),
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('Simulate Family Alert'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.orange.shade700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDemoAlert(BuildContext context, AppState appState) {
    final contact = appState.trustedContacts.first;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Family Alert Sent'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alert sent to: ${contact.name} (${contact.phoneNumber})'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Text(
                '🚨 ScameGo ALERT\nA critical scam campaign has been detected. Please check on ${contact.name == contact.phoneNumber ? "your family member" : "your family member"}. Estimated financial risk: ₹50,000.',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showAddContact(BuildContext context, AppState appState, {TrustedContact? editing}) {
    final nameCtrl = TextEditingController(text: editing?.name);
    final phoneCtrl = TextEditingController(text: editing?.phoneNumber);
    String relationship = editing?.relationship ?? 'family';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBS) => Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                editing == null ? 'Add Trusted Contact' : 'Edit Contact',
                style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+91 98765 43210',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: relationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  prefixIcon: Icon(Icons.people_outline),
                ),
                items: const [
                  DropdownMenuItem(value: 'family', child: Text('Family Member')),
                  DropdownMenuItem(value: 'spouse', child: Text('Spouse / Partner')),
                  DropdownMenuItem(value: 'child', child: Text('Son / Daughter')),
                  DropdownMenuItem(value: 'friend', child: Text('Trusted Friend')),
                  DropdownMenuItem(value: 'caregiver', child: Text('Caregiver')),
                ],
                onChanged: (v) => setBS(() => relationship = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                    final contact = TrustedContact(
                      id: editing?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}',
                      name: nameCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim(),
                      relationship: relationship,
                      priority: 1,
                      consent: true,
                      isPrimary: appState.trustedContacts.isEmpty,
                      addedAt: DateTime.now(),
                    );
                    if (editing != null) {
                      appState.updateTrustedContact(contact);
                    } else {
                      appState.addTrustedContact(contact);
                    }
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.check),
                  label: Text(editing == null ? 'Add Contact' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertSettingsTile extends StatelessWidget {
  final AppState appState;

  const _AlertSettingsTile({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Alert on Critical Scams'),
            subtitle: const Text('Notify family when a critical scam is detected'),
            value: appState.familyAlertOnCritical,
            onChanged: appState.setFamilyAlertOnCritical,
          ),
          const Divider(height: 1, indent: 16),
          SwitchListTile(
            title: const Text('Alert on Payment Risk'),
            subtitle: const Text('Notify family when a suspicious payment is detected'),
            value: appState.familyAlertOnPaymentRisk,
            onChanged: appState.setFamilyAlertOnPaymentRisk,
          ),
          const Divider(height: 1, indent: 16),
          SwitchListTile(
            title: const Text('Alert on OTP Request'),
            subtitle: const Text('Notify family when someone asks for OTP'),
            value: appState.familyAlertOnOtpRequest,
            onChanged: appState.setFamilyAlertOnOtpRequest,
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final TrustedContact contact;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  const _ContactCard({
    required this.contact,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        contact.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (contact.isPrimary) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('PRIMARY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                  Text(contact.phoneNumber, style: theme.textTheme.bodyMedium),
                  Text(
                    contact.relationship.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                  onPressed: () => _confirmRemove(context),
                  tooltip: 'Remove',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Contact?'),
        content: Text('Remove ${contact.name} from trusted contacts? They will no longer receive scam alerts.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); onRemove(); },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _EmptyContactsState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyContactsState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.family_restroom, size: 56, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('No Trusted Contacts Yet', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Add a family member or trusted person who should be alerted if a scam is detected.',
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.person_add),
            label: const Text('Add First Contact'),
          ),
        ],
      ),
    );
  }
}
