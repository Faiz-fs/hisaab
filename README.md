# Hisaab 💚

**Know where your money goes. Own your budget.**

Hisaab is an Android-first personal expense tracker built with Flutter, designed to help Indian users understand their spending habits through automatic bank SMS tracking, smart categorization, and daily or weekly budgeting.

Instead of requiring users to manually enter every expense, Hisaab detects supported bank transaction SMS messages and turns them into meaningful spending insights.

**Version:** 1.1.0  
**Platform:** Android  
**Developed by:** Zynapse  
**Status:** Beta / Release Candidate

---

## Features

### 1. Automatic SMS Expense Tracking
- Detects supported bank transaction SMS messages.
- Imports eligible transaction messages from the previous 15 days.
- Extracts transaction amounts, dates, and available merchant information.
- Identifies debit and credit transactions.
- Uses deduplication to reduce duplicate entries.
- Stores transaction records locally using SQLite.

### 2. UPI Transaction Tracking
- Tracks supported UPI transactions from bank SMS alerts.
- Displays transaction history.
- Extracts available payee and transaction details.
- Helps users understand UPI spending patterns.

### 3. Smart Transaction Categorization
- Automatically categorizes supported transactions.
- Allows users to correct transaction categories.
- Supports saved payee categorization rules.
- Designed to preserve manually selected categories when automatic rules are applied.

### 4. Budget Cadence
Choose between two budgeting experiences:

**Daily Mode**
- Today dashboard.
- Daily spending quota.
- Today's expenses and remaining budget.
- Daily spending insights.

**Weekly Mode**
- Week dashboard.
- Weekly spending quota.
- Current-week spending and remaining budget.
- Weekly spending insights.

The dashboard and bottom navigation adapt to the selected mode.

### 5. Personality Engine
Choose how Hisaab talks about your spending:

- **Gentle:** Supportive and encouraging.
- **Honest:** Direct and practical.
- **Savage:** Playful, witty spending commentary.

The selected personality influences spending feedback and verdict messages.

### 6. Money Map
- Visualize spending distribution.
- Explore expenses by category.
- Identify major spending areas.

### 7. Calendar
- Explore transactions by date.
- Review daily spending activity.
- Identify spending patterns.

### 8. Bank Accounts
- Add bank accounts during onboarding.
- Maintain account details and balances.
- Review linked account information.

### 9. Feedback & Bug Reporting
Users can report issues and suggest improvements directly through the app.

**Feedback form:** https://forms.gle/nW7GMcETG2za99519

### 10. Local-First Storage
Hisaab uses SQLite for local persistence.

- No mandatory cloud backend.
- Transaction data is stored on the device.
- Core expense tracking does not require a paid subscription.

---

## Technology Stack

| Component | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Platform | Android |
| Local database | SQLite |
| State management | Riverpod |
| Navigation | GoRouter |
| SMS integration | Android native APIs / Kotlin |
| Feedback | Google Forms |
| Device information | device_info_plus |
| App version information | package_info_plus |
| External links | url_launcher |

---

## Getting Started

### Requirements

- Flutter SDK
- Dart SDK
- Android SDK
- Java 17
- Android Studio or VS Code
- Android device or emulator

### Installation

Clone the project:

```bash
git clone <repository-url>
cd hisaab
```

Install dependencies:

```bash
flutter pub get
```

Check the development environment:

```bash
flutter doctor
```

Run the application:

```bash
flutter run
```

### Build Android APK

```bash
flutter build apk --release
```

The generated APK is normally located at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Android Permissions

Hisaab uses Android permissions for supported app functionality.

| Permission | Purpose |
|---|---|
| READ_SMS | Import supported bank transaction SMS history |
| RECEIVE_SMS | Detect new incoming transaction messages |
| POST_NOTIFICATIONS | Display supported notifications |
| RECEIVE_BOOT_COMPLETED | Support background initialization |
| VIBRATE | Notification feedback |
| WAKE_LOCK | Support background processing |

SMS access is used for expense tracking. Users should review permissions before enabling automatic tracking.

---

## Privacy & Data

Hisaab follows a local-first approach.

- Expense and transaction data are stored locally.
- SMS processing is intended for financial transaction detection.
- Users should never share OTPs, passwords, or complete bank account numbers through the feedback form.
- Feedback submitted through Google Forms is handled separately from local transaction storage.

A formal privacy policy should be finalized before public distribution.

---

## Version History

### v1.1.0 — Budget & Experience Update
- Daily and Weekly Budget Cadence.
- Dynamic Today/Week navigation.
- Weekly spending dashboard.
- Personality Engine settings synchronization.
- Dynamic profile initials.
- Google Forms feedback integration.
- Dashboard and usability improvements.

### v1.0.0 — Initial Development
- Flutter application foundation.
- Onboarding.
- Bank account management.
- SMS transaction tracking.
- Local SQLite persistence.
- Today dashboard.
- Money Map and Calendar.
- UPI tracking foundation.

---

## Known Limitations

- SMS detection accuracy depends on supported bank message formats.
- Some transaction messages may not contain sufficient merchant information for categorization.
- SMS-based automatic tracking is Android-specific.
- Cloud synchronization and cross-device backup are not currently provided.
- Features should be validated on physical Android devices before public release.

---

## Roadmap

- Improve multi-bank SMS parsing accuracy.
- Expand automatic merchant categorization.
- Improve UPI transaction identification.
- Enhance transaction search and filtering.
- Improve budgeting insights and reports.
- Expand testing across Android devices.

---

## Feedback

Found a bug or have an idea?

[Submit Hisaab Feedback](https://forms.gle/nW7GMcETG2za99519)

---

**Hisaab — Spend smarter. Live better.**

© 2026 Zynapse. All rights reserved.
