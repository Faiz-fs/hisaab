/// Hisaab Feedback & Bug Report Google Form.
///
/// Opens the form in the user's default browser.
const String kFeedbackFormUrl = 'https://forms.gle/nW7GMcETG2za99519';

/// Optional Google Forms prefill field IDs.
///
/// To configure these later:
/// 1. Open Google Forms.
/// 2. Select "Get pre-filled link".
/// 3. Enter sample values.
/// 4. Copy the generated link.
/// 5. Extract the entry.XXXXXXXX identifiers.
///
/// Leave empty to disable automatic prefill.
const String kFeedbackMessageEntry = '';

const String kFeedbackVersionEntry = '';

const String kFeedbackAndroidEntry = '';

/// Returns true when a valid feedback URL is configured.
bool get kFeedbackConfigured =>
    kFeedbackFormUrl.trim().isNotEmpty &&
    Uri.tryParse(kFeedbackFormUrl)?.hasAbsolutePath == true &&
    kFeedbackFormUrl.startsWith('https://');
