import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../widgets/system_status_card.dart';

/// Demo screen to preview [SystemStatusCard] with mock XP (750 = mid v2.0 → v3.0).
class SystemStatusDemoScreen extends StatelessWidget {
  const SystemStatusDemoScreen({super.key});

  /// Mock XP for preview: 750 puts user in v2.x with "Next Unlock: The Vault".
  static const int mockXp = 750;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Status (Preview)'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.lg),
              const SystemStatusCard(currentXp: mockXp),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Mock data: $mockXp XP. Use SystemStatusCard(currentXp: yourXp) with real data.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
