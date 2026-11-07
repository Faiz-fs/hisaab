import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/enums.dart';
import '../../providers/settings_provider.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  ConsumerState<PersonalDetailsScreen> createState() =>
      _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  RoastLevel _roastLevel = RoastLevel.honest;
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    try {
      final settings = await ref.read(settingsRepoProvider).load();
      if (!mounted) return;

      _nameController.text = settings.displayName;
      _emailController.text = settings.email;

      setState(() {
        _roastLevel = settings.roastLevel;
        _loaded = true;
      });
    } catch (error) {
      debugPrint('Unable to load profile: $error');
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
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
      color: color ?? AppColors.textSecondary,
    );
  }

  Future<void> _finish() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      final repo = ref.read(settingsRepoProvider);
      final current = await repo.load();

      await repo.save(
        current.copyWith(
          displayName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          roastLevel: _roastLevel,
          onboardingDone: true,
        ),
      );

      ref.invalidate(settingsProvider);

      if (!mounted) return;
      context.go('/today');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save profile: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _personalityOption(
    RoastLevel level,
    String title,
    String subtitle,
    String example,
    IconData icon,
  ) {
    final selected = _roastLevel == level;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _saving ? null : () => setState(() => _roastLevel = level),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.nested : AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _heading(15)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: _body(12)),
                    const SizedBox(height: 10),
                    Text(
                      '"$example"',
                      style: _body(
                        12,
                        color: selected
                            ? AppColors.mint
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
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
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: _saving
                            ? null
                            : () => context.go('/onboarding/sms-permission'),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'STEP 05 / 05',
                        style: _heading(11, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: List.generate(5, (index) {
                      return Expanded(
                        child: Container(
                          height: 5,
                          margin: EdgeInsets.only(right: index == 4 ? 0 : 7),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                    size: 54,
                  ),
                  const SizedBox(height: 20),
                  Text('MAKE IT\nPERSONAL.', style: _heading(35)),
                  const SizedBox(height: 12),
                  Text(
                    'Tell Hisaab what to call you and how '
                    'you want your money reality checks delivered.',
                    style: _body(13),
                  ),
                  const SizedBox(height: 30),
                  if (!_loaded)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  else
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('YOUR DETAILS', style: _heading(14)),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _nameController,
                            maxLength: 40,
                            textCapitalization: TextCapitalization.words,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(
                                RegExp(r'[\r\n]'),
                              ),
                            ],
                            style: _heading(15),
                            decoration: InputDecoration(
                              labelText: 'DISPLAY NAME',
                              hintText: 'What should we call you?',
                              filled: true,
                              fillColor: AppColors.card,
                              prefixIcon: const Icon(
                                Icons.person_outline,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (value) {
                              final name = value?.trim() ?? '';
                              if (name.isEmpty) {
                                return 'Please enter your name';
                              }
                              if (name.length < 2) {
                                return 'Enter at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            maxLength: 254,
                            style: _heading(15),
                            decoration: InputDecoration(
                              labelText: 'EMAIL (OPTIONAL)',
                              hintText: 'you@example.com',
                              filled: true,
                              fillColor: AppColors.card,
                              prefixIcon: const Icon(
                                Icons.mail_outline,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty) return null;
                              if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch(email)) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Text('CHOOSE YOUR PERSONALITY', style: _heading(14)),
                          const SizedBox(height: 8),
                          Text(
                            'How should Hisaab talk about '
                            'your spending?',
                            style: _body(12),
                          ),
                          const SizedBox(height: 18),
                          _personalityOption(
                            RoastLevel.gentle,
                            'GENTLE',
                            'Supportive and encouraging',
                            'You can get back on track tomorrow.',
                            Icons.favorite_border,
                          ),
                          _personalityOption(
                            RoastLevel.honest,
                            'HONEST',
                            'Straightforward and practical',
                            'You crossed your daily budget.',
                            Icons.balance_outlined,
                          ),
                          _personalityOption(
                            RoastLevel.savage,
                            'SAVAGE',
                            'Playful, cheeky reality checks',
                            'Your wallet just filed a complaint.',
                            Icons.local_fire_department_outlined,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your profile stays on this phone. '
                            'Email is not used for login or recovery.',
                            style: _body(11),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 18),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: !_loaded || _saving ? null : _finish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    _saving ? 'SAVING...' : 'START MY HISAAB →',
                    style: _heading(15, color: AppColors.onPrimary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
