CMD-only • Android-first Flutter app • Updated 09 November 2026

Purpose: Set up a clean Windows development machine to build, run, test, and optionally sign Hisaab. Commands below are for cmd.exe (Command Prompt), not PowerShell. E: paths reproduce the prior project setup; change the drive consistently if needed.

# 1. Required software and project baseline

- Windows 10/11 x64, internet access, and sufficient free disk space (Android SDK and Gradle caches can consume multiple GB).

- Oracle JDK 17 (requested distribution); install to E:\SoftwareInstalled\Java17.

- Flutter SDK 3.47.9 (Dart 3.13.7), installed at E:\SoftwareInstalled\Flutter\flutter.

- Android SDK command-line tools, platform-tools, Android API 36 platform and Build Tools 36.0.0; Android Studio is not required.

- Git for Windows (to clone the repository), a code editor, and an Android device with USB debugging for device testing.

- Hisaab project: E:\GitProg\hisaab; Android package: com.zynapse.hisaab; project version last recorded: 1.1.0+2.

# 2. Create directories in CMD

mkdir E:\SoftwareInstalled\Java17  
mkdir E:\SoftwareInstalled\Flutter\PubCache  
mkdir E:\SoftwareInstalled\Flutter\Temp  
mkdir E:\SoftwareInstalled\Android\Sdk  
mkdir E:\SoftwareInstalled\Android\GradleCache  
mkdir E:\GitProg

Existing folders are fine; CMD may report that a directory already exists.

# 3. Install Oracle Java 17

Official archive: https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html

Download the Windows x64 ZIP for JDK 17 from Oracle. Extract it and move the CONTENTS of the extracted jdk-17.x folder into E:\SoftwareInstalled\Java17 so that E:\SoftwareInstalled\Java17\bin\java.exe exists. Oracle may require sign-in or license acceptance. Do not mix this path with an older JDK.

dir E:\SoftwareInstalled\Java17\bin\java.exe  
set "JAVA_HOME=E:\SoftwareInstalled\Java17"  
set "PATH=%JAVA_HOME%\bin;%PATH%"  
setx JAVA_HOME "E:\SoftwareInstalled\Java17"  
java -version  
javac -version

set changes the current CMD window; setx persists a user environment variable for NEW CMD windows. Never use setx PATH with the full existing PATH because it may truncate or damage PATH.

# 4. Install Flutter SDK 3.47.9

Download the Windows Flutter SDK archive for Flutter 3.47.9 from https://docs.flutter.dev/install/archive and extract it so flutter.bat is at E:\SoftwareInstalled\Flutter\flutter\bin\flutter.bat. Avoid an extra nested flutter folder.

dir E:\SoftwareInstalled\Flutter\flutter\bin\flutter.bat  
set "FLUTTER_HOME=E:\SoftwareInstalled\Flutter\flutter"  
set "PATH=%FLUTTER_HOME%\bin;%PATH%"  
setx FLUTTER_HOME "E:\SoftwareInstalled\Flutter\flutter"  
flutter --version

Add E:\SoftwareInstalled\Flutter\flutter\bin to the Windows User Path once using the Environment Variables GUI, or use the CMD-only registry approach in section 7. Git for Windows is also needed by Flutter.

# 5. Install Android SDK command-line tools (without Android Studio)

Download “Command line tools only” for Windows from https://developer.android.com/studio#command-line-tools-only . Extract the downloaded ZIP. Its cmdline-tools folder contains bin, lib, source.properties, etc. Arrange the final structure as follows:

E:\SoftwareInstalled\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat  
E:\SoftwareInstalled\Android\Sdk\cmdline-tools\latest\bin\avdmanager.bat

Important: the earlier temporary extraction location E:\SoftwareInstalled\Android\Sdk\cmdline-tools\bin is NOT the final standard layout. Move bin/lib and the other contents into cmdline-tools\latest, not a second nested cmdline-tools folder.

set "ANDROID_HOME=E:\SoftwareInstalled\Android\Sdk"  
set "ANDROID_SDK_ROOT=%ANDROID_HOME%"  
set "PATH=%ANDROID_HOME%\cmdline-tools\latest\bin;%ANDROID_HOME%\platform-tools;%PATH%"  
setx ANDROID_HOME "E:\SoftwareInstalled\Android\Sdk"  
setx ANDROID_SDK_ROOT "E:\SoftwareInstalled\Android\Sdk"  
sdkmanager --sdk_root="%ANDROID_HOME%" --licenses  
sdkmanager --sdk_root="%ANDROID_HOME%" "platform-tools" "platforms;android-36" "build-tools;36.0.0"  
sdkmanager --sdk_root="%ANDROID_HOME%" --list_installed

Accept licenses interactively. If sdkmanager complains about Java, confirm JAVA_HOME points to JDK 17 and java -version succeeds.

# 6. Move caches and temporary files to E:

The previous setup moved Pub, Gradle, and Windows temporary build storage away from C:. These are user-level variables:

set "PUB_CACHE=E:\SoftwareInstalled\Flutter\PubCache"  
set "GRADLE_USER_HOME=E:\SoftwareInstalled\Android\GradleCache"  
set "TEMP=E:\SoftwareInstalled\Flutter\Temp"  
set "TMP=E:\SoftwareInstalled\Flutter\Temp"  
setx PUB_CACHE "E:\SoftwareInstalled\Flutter\PubCache"  
setx GRADLE_USER_HOME "E:\SoftwareInstalled\Android\GradleCache"  
setx TEMP "E:\SoftwareInstalled\Flutter\Temp"  
setx TMP "E:\SoftwareInstalled\Flutter\Temp"

Changing TEMP/TMP affects future user processes; restart terminals and development tools afterward. Do not delete old cache folders until a fresh build succeeds.

# 7. Persist executable directories in User PATH using CMD only

CMD’s setx PATH is deliberately avoided. Use reg add to write a minimal, expandable User Path value; the example assumes a fresh machine/user Path. First inspect the existing User Path. Preserve its other entries if present before replacing it.

reg query HKCU\Environment /v Path  
reg add HKCU\Environment /v Path /t REG_EXPAND_SZ /d "E:\SoftwareInstalled\Java17\bin;E:\SoftwareInstalled\Flutter\flutter\bin;E:\SoftwareInstalled\Android\Sdk\platform-tools;E:\SoftwareInstalled\Android\Sdk\cmdline-tools\latest\bin" /f

CAUTION: reg add replaces the User Path value. If the first command shows an existing Path, append these four directories to its existing value instead of running the replacement command unchanged. Close CMD and open a NEW CMD window for persistent variables to load.

# 8. Configure Flutter and validate the toolchain

flutter config --android-sdk "E:\SoftwareInstalled\Android\Sdk"  
flutter config --jdk-dir "E:\SoftwareInstalled\Java17"  
where java  
where flutter  
where adb  
where sdkmanager  
java -version  
flutter --version  
flutter doctor -v  
adb version

Flutter doctor should recognize the Android toolchain. Android Studio not installed is acceptable for this CMD-only workflow; a missing Android SDK license is not. Flutter may also report unrelated desktop/web toolchains as unavailable.

# 9. Obtain the Hisaab source and dependencies

Clone using the actual repository URL supplied by the maintainer, or copy the existing project into E:\GitProg\hisaab. The project must contain pubspec.yaml, lib, android, and other Flutter files.

cd /d E:\GitProg\hisaab  
flutter pub get  
flutter analyze  
flutter test

If the repository has no automated tests, flutter test may report that no tests were found; this is different from a failing test suite. Do not run flutter pub upgrade by default: it can alter the locked dependency versions.

# 10. Connect and run on an Android phone

On the phone, enable Developer options and USB debugging, connect over USB, and approve the RSA debugging prompt. Install any device USB driver required by Windows.

adb devices  
flutter devices  
cd /d E:\GitProg\hisaab  
flutter run -d I2221

I2221 was the earlier connected device ID; use the ID actually displayed by flutter devices. Correct syntax is flutter run -d I2221, not flutter run -d --debug I2221. Debug is the default run mode.

# 11. Build and locate the release APK

cd /d E:\GitProg\hisaab  
flutter clean  
flutter pub get  
flutter analyze  
flutter test  
flutter build apk --release  
dir build\app\outputs\flutter-apk\app-release.apk

Previously the release APK was about 65.6 MB; actual size can change. Output: E:\GitProg\hisaab\build\app\outputs\flutter-apk\app-release.apk.

# 12. Release signing: preserve existing credentials

The project previously used android\app\hisaab-release.jks with alias hisaab. To reproduce an existing Play Store signing identity, obtain the original keystore and the corresponding local signing configuration securely from the maintainer. Do NOT generate a new keystore as a replacement for an existing release identity. Never commit the .jks file, passwords, or key.properties.

cd /d E:\GitProg\hisaab  
"%ANDROID_HOME%\build-tools\36.0.0\apksigner.bat" verify --verbose --print-certs "build\app\outputs\flutter-apk\app-release.apk"

The previous APK passed APK Signature Scheme v2 verification. A v1=false result alone is not a failure when v2 verification succeeds. Check that the certificate fingerprint matches the expected release signing identity before distribution.

# 13. Troubleshooting quick reference

## java is not recognized

echo %JAVA_HOME%  
where java  
java -version

Ensure JDK 17 bin is on PATH; reopen CMD after setx.

## sdkmanager is not recognized

dir "%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat"

Check the latest/bin layout, then reopen CMD.

## Android licenses missing

sdkmanager --sdk_root="%ANDROID_HOME%" --licenses  
flutter doctor -v

Accept all applicable Android SDK licenses.

## Device not detected

adb kill-server  
adb start-server  
adb devices

Reconnect USB, unlock phone, approve USB debugging and check Windows USB driver.

## Stale build artifacts

flutter clean  
flutter pub get  
flutter build apk --release

Use after changing toolchains; do not wipe signing files.

## Wrong Java selected

where java  
flutter config --jdk-dir "E:\SoftwareInstalled\Java17"  
flutter doctor -v

Multiple Java installs can conflict; verify Flutter JDK selection.

# 14. Fresh machine completion checklist

- Oracle JDK 17 installed and java/javac commands work.

- Flutter 3.47.9 and Dart 3.13.7 verified.

- Android SDK command-line tools, platform-tools, API 36, Build Tools 36.0.0 installed.

- Licenses accepted; flutter doctor recognizes Android toolchain.

- JAVA_HOME, ANDROID_HOME, FLUTTER_HOME, PUB_CACHE, GRADLE_USER_HOME, TEMP/TMP configured.

- Hisaab dependencies restored and static analysis reviewed.

- USB device visible via adb devices; flutter run succeeds.

- Release APK built; signing identity verified before distribution.

Official references: Oracle JDK 17 archive: https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html \| Flutter SDK archive: https://docs.flutter.dev/install/archive \| Android command-line tools: https://developer.android.com/studio#command-line-tools-only \| Flutter Android setup: https://docs.flutter.dev/platform-integration/android/setup
