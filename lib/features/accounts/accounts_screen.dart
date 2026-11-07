import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/format/inr_format.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/account.dart';
import '../../providers/repo_providers.dart';

/// Saved bank accounts. Balances follow bank SMS automatically (credits,
/// debits and "Avl Bal" figures) and can be corrected by hand at any time.
class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  Future<void> _editBalance(BuildContext context, WidgetRef ref, AccountModel a) async {
    final controller = TextEditingController(text: (a.balancePaise / 100).toStringAsFixed(2));
    final newPaise = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Update ${a.bankName} •••• ${a.last4}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the balance your bank app shows right now.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
              decoration: const InputDecoration(prefixText: '₹ ', labelText: 'Current balance'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final v = double.tryParse(controller.text.replaceAll(',', '').trim());
              if (v == null || v < 0 || v > 1e9) return;
              Navigator.pop(dialogContext, (v * 100).round());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newPaise == null) return;
    await ref.read(accountRepoProvider).updateBalance(a.id, newPaise);
    ref.invalidate(accountsProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Balance updated')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Bank Accounts')),
      body: accounts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unable to load accounts: $e')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('No accounts added yet'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length + 1,
                itemBuilder: (context, i) {
                  if (i == items.length) {
                    return const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Balances update from bank SMS. If one looks wrong, tap the account to correct it.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    );
                  }
                  final a = items[i];
                  return Card(
                    child: ListTile(
                      onTap: () => _editBalance(context, ref, a),
                      leading: const Icon(Icons.account_balance_outlined, color: AppColors.primary),
                      title: Text(a.bankName),
                      subtitle: Text('•••• ${a.last4} · Updated ${DateFormat('d MMM, h:mm a').format(a.updatedAt)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(inr(a.balancePaise / 100)),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}