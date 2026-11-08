import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/feedback_config.dart';
import '../../core/theme/app_colors.dart';

/// Profile -> Send feedback.
/// Opens the Google Form in the browser.
/// If no browser can open it, copies the link instead.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String? _appVersion;
  String? _androidVersion;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final p = await PackageInfo.fromPlatform();
      _appVersion = '${p.version}+${p.buildNumber}';
    } catch (_) {}

    try {
      final a = await DeviceInfoPlugin().androidInfo;
      _androidVersion =
          'Android ${a.version.release} (SDK ${a.version.sdkInt})';
    } catch (_) {}

    if (mounted) {
      setState(() {});
    }
  }

  void _snack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Builds the Google Form URL with optional device information.
  Uri _buildUri() {
    final base = Uri.parse(kFeedbackFormUrl);
    final params = <String, String>{...base.queryParameters};

    void put(String entry, String? value) {
      if (entry.isNotEmpty && value != null && value.isNotEmpty) {
        params['usp'] = 'pp_url';
        params[entry] = value;
      }
    }

    put(kFeedbackVersionEntry, _appVersion);
    put(kFeedbackAndroidEntry, _androidVersion);

    return params.isEmpty ? base : base.replace(queryParameters: params);
  }

  Future<void> _copyLink() async {
    if (!kFeedbackConfigured) {
      _snack('Feedback form link is not configured.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: _buildUri().toString()));

    _snack('Feedback form link copied');
  }

  Future<void> _openForm() async {
    if (!kFeedbackConfigured) {
      _snack('Feedback form link is not configured.');
      return;
    }

    final uri = _buildUri();

    bool opened = false;

    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}

    if (!opened) {
      await Clipboard.setData(ClipboardData(text: uri.toString()));

      _snack('Could not open browser. Link copied.');
    }
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value ?? 'Loading...',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Text(
          'Send feedback',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Found a bug, an incorrect transaction, '
            'or have an idea to improve Hisaab? '
            'Share your feedback through our Google Form.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _infoRow('App version', _appVersion),
                _infoRow('Android', _androidVersion),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _openForm,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.open_in_new),
              label: Text(
                'Open feedback form',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          TextButton.icon(
            onPressed: _copyLink,
            icon: const Icon(Icons.link, size: 18),
            label: const Text('Copy form link'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
