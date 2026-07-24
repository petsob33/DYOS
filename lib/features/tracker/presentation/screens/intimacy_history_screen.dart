import 'package:flutter/material.dart';

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
        title: const Text('Intimacy History'),
      ),
      body: const SafeArea(
        child: IntimacyHistoryList(),
      ),
    );
  }
}
