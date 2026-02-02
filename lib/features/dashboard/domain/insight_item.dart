import 'package:flutter/material.dart';

/// One item in the horizontal insight strip (e.g. "5 memories", "this month").
class InsightItem {
  const InsightItem({
    required this.title,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
}
