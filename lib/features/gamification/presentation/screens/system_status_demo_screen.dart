import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../widgets/system_status_card.dart';

/// Demo screen to preview [SystemStatusCard] with mock SP (750 = early v2.0 Connected).
class SystemStatusDemoScreen extends StatelessWidget {
  const SystemStatusDemoScreen({super.key});

  /// Mock SP for preview: 750 puts user in v2.0 with next reward tip.
  static const int mockSp = 750;

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
              const SystemStatusCard(currentXp: mockSp),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Mock data: $mockSp SP. Use SystemStatusCard(currentXp: yourSp) with real data.',
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
