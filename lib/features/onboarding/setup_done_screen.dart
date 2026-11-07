import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Setup complete screen. Navigates to the main Today shell.
class SetupDoneScreen extends ConsumerWidget {
  const SetupDoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("You're all set!"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/today'),
              child: const Text('Start Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}
