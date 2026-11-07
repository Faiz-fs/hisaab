import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

/// First screen of the Hisaab onboarding flow.
///
/// Introduces automatic expense tracking and navigates
/// to the monthly income setup screen.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            children: [
              _buildHeader(),
              const Spacer(),
              _buildHero(),
              const SizedBox(height: 36),
              _buildFeatures(),
              const Spacer(),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.onPrimary,
            size: 23,
          ),
        ),
        const SizedBox(width: 11),
        Text(
          'HISAAB',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            'STEP 01 / 05',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.05),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.20),
              width: 2,
            ),
          ),
          child: Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.09),
              ),
              child: const Icon(
                Icons.currency_rupee_rounded,
                color: AppColors.primary,
                size: 83,
              ),
            ),
          ),
        ),
        const SizedBox(height: 34),
        Text(
          'YOUR MONEY.\nYOUR REALITY.',
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 37,
            fontWeight: FontWeight.w800,
            height: 1.12,
            letterSpacing: -1.3,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 17),
        Text(
          'Stop wondering where your salary went.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          'Hisaab tracks your spending automatically\n'
          'and tells you the truth every night.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _feature(
            Icons.sms_outlined,
            'Automatic Tracking',
            'Bank SMS alerts become expenses.',
          ),
          const SizedBox(height: 17),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 17),
          _feature(
            Icons.donut_large_outlined,
            'Daily Budget',
            'Know your daily spending limit.',
          ),
          const SizedBox(height: 17),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 17),
          _feature(
            Icons.local_fire_department_outlined,
            'Night Verdict',
            'A daily review with personality.',
          ),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: AppColors.nested,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.check_circle_outline, color: AppColors.mint, size: 19),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 57,
          child: ElevatedButton(
            onPressed: () {
              context.go('/onboarding/income');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'LET\'S GET STARTED',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_rounded, size: 21),
              ],
            ),
          ),
        ),
        const SizedBox(height: 17),
        Text(
          'No manual entries. No subscriptions.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 13, color: AppColors.mint),
            const SizedBox(width: 5),
            Text(
              'Your transaction data stays on your device.',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
