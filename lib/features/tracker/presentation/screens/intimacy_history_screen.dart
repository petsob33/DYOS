import 'package:flutter/material.dart';

import '../../../../core/l10n/build_context_l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/intimacy_history_list.dart';

/// Screen displaying all intimacy logs
class IntimacyHistoryScreen extends StatelessWidget {
  const IntimacyHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(context.l10n.intimacyHistoryScreenTitle),
      ),
      body: const SafeArea(
        child: IntimacyHistoryList(),
      ),
    );
  }
}
