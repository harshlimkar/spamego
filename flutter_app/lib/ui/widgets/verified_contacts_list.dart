// Verified contacts list widget
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../models/trusted_contact.dart';
import '../../ui/theme/app_theme.dart';

class VerifiedContactsList extends StatelessWidget {
  const VerifiedContactsList({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final trustedContacts = appState.trustedContacts;
        final officialContacts = _getOfficialContacts();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trusted Family Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trusted Family', style: Theme.of(context).textTheme.titleLarge),
                  TextButton.icon(
                    onPressed: () => _showAddContactDialog(context, appState),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              if (trustedContacts.isEmpty)
                _EmptyTrustedState(onAdd: () => _showAddContactDialog(context, appState))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: trustedContacts.length,
                  itemBuilder: (context, index) => _TrustedContactTile(
                    contact: trustedContacts[index],
                    onEdit: () => _showEditContactDialog(context, appState, trustedContacts[index]),
                    onDelete: () => _confirmDelete(context, appState, trustedContacts[index]),
                    onSetPrimary: () => _setPrimary(context, appState, trustedContacts[index]),
                  ),
                ),
              
              const SizedBox(height: AppSpacing.xl),
              
              // Official Contacts Section
              Text('Official Verified Numbers', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              ...officialContacts.map((contact) => _OfficialContactTile(contact: contact)).toList(),
            ],
          ),
        );
      },
    );
  }
  
  void _showAddContactDialog(BuildContext context, AppState appState) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String relationship = 'Family';
    int priority = appState.trustedContacts.length + 1;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Trusted Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+91 98765 43210',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: relationship,
                decoration: const InputDecoration(labelText: 'Relationship'),
                items: ['Family', 'Spouse', 'Child', 'Parent', 'Sibling', 'Caregiver', 'Friend', 'Other']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => relationship = v ?? 'Family',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                appState.addTrustedContact(TrustedContact(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  phoneNumber: phoneController.text,
                  relationship: relationship,
                  priority: priority,
                  consent: true,
                  isPrimary: appState.trustedContacts.isEmpty,
                  addedAt: DateTime.now(),
                ));
                Navigator.pop(context);
              }
            },
            child: const Text('Add Contact'),
          ),
        ],
      ),
    );
  }
  
  void _showEditContactDialog(BuildContext context, AppState appState, TrustedContact contact) {
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(text: contact.phoneNumber);
    String relationship = contact.relationship;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Contact'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                value: relationship,
                decoration: const InputDecoration(labelText: 'Relationship'),
                items: ['Family', 'Spouse', 'Child', 'Parent', 'Sibling', 'Caregiver', 'Friend', 'Other']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => relationship = v ?? 'Family',
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                title: const Text('Consent for Alerts'),
                value: contact.consent,
                onChanged: (v) => appState.updateTrustedContact(contact.copyWith(consent: v)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              appState.updateTrustedContact(contact.copyWith(
                name: nameController.text,
                phoneNumber: phoneController.text,
                relationship: relationship,
              ));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _confirmDelete(BuildContext context, AppState appState, TrustedContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Contact'),
        content: Text('Remove ${contact.name} from trusted contacts?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              appState.removeTrustedContact(contact.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
  
  void _setPrimary(BuildContext context, AppState appState, TrustedContact contact) {
    // Update all contacts to not primary, then set this one
    for (final c in appState.trustedContacts) {
      if (c.id == contact.id) {
        appState.updateTrustedContact(c.copyWith(isPrimary: true));
      } else if (c.isPrimary) {
        appState.updateTrustedContact(c.copyWith(isPrimary: false));
      }
    }
  }
  
  List<_OfficialContact> _getOfficialContacts() {
    return [
      _OfficialContact('National Cyber Crime Helpline', '1930', 'Government', Icons.security),
      _OfficialContact('RBI Ombudsman', '14440', 'Banking', Icons.account_balance),
      _OfficialContact('State Bank of India', '1800 1234 567', 'Banking', Icons.account_balance_wallet),
      _OfficialContact('HDFC Bank', '1800 202 6161', 'Banking', Icons.account_balance_wallet),
      _OfficialContact('ICICI Bank', '1800 200 3344', 'Banking', Icons.account_balance_wallet),
      _OfficialContact('Aadhaar Helpline', '1947', 'Government', Icons.verified_user),
      _OfficialContact('Income Tax Dept', '1800 103 0025', 'Government', Icons.receipt_long),
      _OfficialContact('Consumer Helpline', '1800 11 4000', 'Government', Icons.shopping_cart),
    ];
  }
}

class _OfficialContact {
  final String name;
  final String number;
  final String category;
  final IconData icon;
  
  _OfficialContact(this.name, this.number, this.category, this.icon);
}

class _TrustedContactTile extends StatelessWidget {
  final TrustedContact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;
  
  const _TrustedContactTile({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onSetPrimary,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                contact.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            if (contact.isPrimary)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppSpacing.xl),
                ),
                child: Text(
                  'PRIMARY',
                  style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xs),
            Text(contact.formattedPhone, style: theme.textTheme.bodyMedium),
            Text(
              contact.relationship,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (!contact.consent)
              Text(
                '⚠ Alerts disabled',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurfaceVariant),
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
            if (value == 'primary') onSetPrimary();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            const PopupMenuItem(value: 'primary', child: Text('Set as Primary')),
            const PopupMenuItem(value: 'delete', child: Text('Remove')),
          ],
        ),
      ),
    );
  }
}

class _OfficialContactTile extends StatelessWidget {
  final _OfficialContact contact;
  
  const _OfficialContactTile({required this.contact});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.15),
          child: Icon(contact.icon, color: Colors.green),
        ),
        title: Text(contact.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(contact.category, style: theme.textTheme.bodySmall),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              contact.number,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'VERIFIED',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 9),
              ),
            ),
          ],
        ),
        onTap: () {
          // Could show more details or initiate call
        },
      ),
    );
  }
}

class _EmptyTrustedState extends StatelessWidget {
  final VoidCallback onAdd;
  
  const _EmptyTrustedState({required this.onAdd});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.family_restroom_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No trusted contacts yet',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add family members who can be alerted in case of a scam',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add),
              label: const Text('Add First Contact'),
            ),
          ],
        ),
      ),
    );
  }
}