import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/repo_providers.dart';

/// Step 4 of onboarding.
///
/// Requests SMS permission only after the user explicitly
/// taps Enable. Permission state is managed by Android.
class SmsPermissionScreen extends ConsumerStatefulWidget {
  const SmsPermissionScreen({super.key});

  @override
  ConsumerState<SmsPermissionScreen> createState() =>
      _SmsPermissionScreenState();
}

class _SmsPermissionScreenState extends ConsumerState<SmsPermissionScreen>
    with WidgetsBindingObserver {
  bool _loading = true;
  bool _requesting = false;
  bool _granted = false;
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    try {
      final status = await Permission.sms.status;
      if (!mounted) return;

      setState(() {
        _granted = status.isGranted;
        _permanentlyDenied = status.isPermanentlyDenied;
        _loading = false;
      });
    } catch (error) {
      debugPrint('SMS permission check failed: $error');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _requestPermission() async {
    if (_requesting) return;

    setState(() => _requesting = true);

    try {
      final status = await Permission.sms.request();
      if (!mounted) return;

      setState(() {
        _granted = status.isGranted;
        _permanentlyDenied = status.isPermanentlyDenied;
      });

      if (status.isGranted) {
        final repo = ref.read(settingsRepoProvider);
        final current = await repo.load();
        await repo.save(current.copyWith(smsEnabled: true));
        ref.invalidate(settingsProvider);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SMS permission enabled.')),
        );
      } else if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission is blocked. Enable it in app settings.'),
          ),
        );
      }
    } catch (error) {
      debugPrint('SMS permission request failed: $error');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not request SMS permission.')),
      );
    } finally {
      if (mounted) {
        setState(() => _requesting = false);
      }
    }
  }

  void _continue() {
    if (_requesting) return;
    context.go('/onboarding/personal-details');
  }

  TextStyle _heading(double size, {Color? color}) {
    return GoogleFonts.spaceGrotesk(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.textPrimary,
    );
  }

  TextStyle _body(double size, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: size,
      height: 1.5,
      color: color ?? AppColors.textSecondary,
    );
  }

  Widget _progress() {
    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: Container(
            height: 5,
            margin: EdgeInsets.only(right: index == 4 ? 0 : 7),
            decoration: BoxDecoration(
              color: index <= 3 ? AppColors.primary : AppColors.nested,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }

  Widget _feature(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.nested,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _heading(14)),
                const SizedBox(height: 5),
                Text(description, style: _body(12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.mint,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text('YOUR PRIVACY MATTERS', style: _heading(13)),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Hisaab is designed to process bank alerts '
            'on your phone and save only extracted '
            'transaction details in local SQLite.',
            style: _body(12),
          ),
          const SizedBox(height: 12),
          Text(
            'No server upload. No bank login. '
            'No OTP or PIN required.',
            style: _body(12, color: AppColors.mint),
          ),
        ],
      ),
    );
  }

  Widget _statusCard() {
    final message = _granted
        ? 'SMS permission is enabled'
        : _permanentlyDenied
        ? 'Permission blocked in Android settings'
        : 'SMS permission is not enabled';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            _granted ? Icons.check_circle_outline : Icons.info_outline,
            color: _granted ? AppColors.mint : AppColors.amber,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: _body(12, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.go('/onboarding/add-bank'),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'STEP 04 / 05',
                        style: _heading(11, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _progress(),
                  const SizedBox(height: 32),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.sms_outlined,
                      color: AppColors.primary,
                      size: 37,
                    ),
                  ),
                  const SizedBox(height: 27),
                  Text('LET YOUR\nMONEY TALK.', style: _heading(36)),
                  const SizedBox(height: 13),
                  Text(
                    'Your bank already sends transaction '
                    'alerts. Hisaab can use them to help '
                    'track your spending automatically.',
                    style: _body(14),
                  ),
                  const SizedBox(height: 33),
                  _feature(
                    Icons.bolt_outlined,
                    'LESS MANUAL ENTRY',
                    'Detect eligible bank transaction '
                        'alerts after SMS processing is enabled.',
                  ),
                  _feature(
                    Icons.account_balance_wallet_outlined,
                    'SEE WHERE MONEY GOES',
                    'Turn detected expenses into '
                        'useful spending insights.',
                  ),
                  _feature(
                    Icons.phonelink_lock_outlined,
                    'LOCAL-FIRST BY DESIGN',
                    'Keep extracted transaction records '
                        'on your own device.',
                  ),
                  const SizedBox(height: 8),
                  _privacyCard(),
                  const SizedBox(height: 20),
                  if (!_loading) _statusCard(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
              child: Column(
                children: [
                  if (!_granted)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _loading || _requesting
                            ? null
                            : _permanentlyDenied
                            ? openAppSettings
                            : _requestPermission,
                        icon: const Icon(Icons.sms_outlined),
                        label: Text(
                          _requesting
                              ? 'REQUESTING...'
                              : _permanentlyDenied
                              ? 'OPEN APP SETTINGS'
                              : 'ENABLE SMS ACCESS',
                          style: _heading(13, color: AppColors.onPrimary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  if (_granted)
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: _continue,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(
                          'CONTINUE',
                          style: _heading(14, color: AppColors.onPrimary),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  if (!_granted) ...[
                    const SizedBox(height: 13),
                    TextButton(
                      onPressed: _requesting ? null : _continue,
                      child: Text(
                        'NOT NOW — CONTINUE MANUALLY',
                        style: _heading(12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'You can change this permission '
                    'later in Android settings.',
                    textAlign: TextAlign.center,
                    style: _body(11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
