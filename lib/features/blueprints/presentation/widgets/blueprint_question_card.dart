import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/blueprint_question.dart';

/// Renders one Blueprint question in a minimalistic white card.
class BlueprintQuestionCard extends StatelessWidget {
  const BlueprintQuestionCard({
    super.key,
    required this.question,
    required this.value,
    required this.onChanged,
    this.partnerValue,
  });

  final BlueprintQuestion question;
  final dynamic value;
  final void Function(dynamic) onChanged;
  /// Partner's answer to show below the input (if any).
  final dynamic partnerValue;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            question.title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: c.text,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildInput(c),
          if (partnerValue != null && _partnerDisplayValue != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Partner: $_partnerDisplayValue',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: c.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? get _partnerDisplayValue {
    if (partnerValue == null) return null;
    if (partnerValue is List) {
      final l = partnerValue as List;
      if (l.isEmpty) return null;
      return l.join(', ');
    }
    if (partnerValue is bool) return (partnerValue as bool) ? 'Yes' : 'No';
    if (partnerValue is num) return partnerValue.toString();
    return partnerValue.toString();
  }

  Widget _buildInput(AppPalette c) {
    switch (question.type) {
      case BlueprintQuestionType.slider:
        return _SliderInput(
          leftLabel: question.sliderLeftLabel ?? '',
          rightLabel: question.sliderRightLabel ?? '',
          value: (value as num?)?.toDouble() ?? 0.5,
          onChanged: (v) => onChanged(v),
        );
      case BlueprintQuestionType.choiceChips:
        return _ChoiceChipsInput(
          options: question.options ?? [],
          selected: value as String?,
          onChanged: (v) => onChanged(v),
        );
      case BlueprintQuestionType.multiSelect:
        return _MultiSelectInput(
          options: question.options ?? [],
          selected:
              value is List ? List<String>.from(value) : const [],
          onChanged: (v) => onChanged(v),
        );
      case BlueprintQuestionType.measurement:
        return _MeasurementInput(
          suffix: question.measurementSuffix ?? '',
          placeholder: question.measurementPlaceholder,
          value: value as String?,
          onChanged: (v) => onChanged(v),
        );
      case BlueprintQuestionType.switchType:
        return _SwitchInput(
          value: value as bool? ?? false,
          onChanged: (v) => onChanged(v),
        );
    }
  }
}

class _SliderInput extends StatelessWidget {
  const _SliderInput({
    required this.leftLabel,
    required this.rightLabel,
    required this.value,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: c.primary,
            inactiveTrackColor: c.background,
            thumbColor: c.primary,
            overlayColor: c.primary.withOpacity(0.2),
            trackHeight: 10,
          ),
          child: Slider(
            value: value.clamp(0.0, 1.0),
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              leftLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: c.textSecondary,
              ),
            ),
            Text(
              rightLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: c.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ChoiceChipsInput extends StatelessWidget {
  const _ChoiceChipsInput({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: options.map((option) {
        final isSelected = selected == option;
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onChanged(isSelected ? null : option),
          selectedColor: c.primary.withOpacity(0.2),
          checkmarkColor: c.primary,
          backgroundColor: c.background,
          side: BorderSide(
            color: isSelected ? c.primary : const Color(0xFFE5E5EA),
            width: isSelected ? 1.5 : 1,
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? c.primary : c.textSecondary,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }
}

class _MultiSelectInput extends StatelessWidget {
  const _MultiSelectInput({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) {
            final next = isSelected
                ? selected.where((e) => e != option).toList()
                : [...selected, option];
            onChanged(next);
          },
          selectedColor: c.primary.withOpacity(0.2),
          checkmarkColor: c.primary,
          backgroundColor: c.background,
          side: BorderSide(
            color: isSelected ? c.primary : const Color(0xFFE5E5EA),
            width: isSelected ? 1.5 : 1,
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? c.primary : c.textSecondary,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
  }).toList(),
    );
  }
}

class _MeasurementInput extends StatelessWidget {
  const _MeasurementInput({
    required this.suffix,
    this.placeholder,
    required this.value,
    required this.onChanged,
  });

  final String suffix;
  final String? placeholder;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: c.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              initialValue: value,
              onChanged: (s) => onChanged(s.isEmpty ? null : s),
              decoration: InputDecoration(
                hintText: placeholder,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                hintStyle: GoogleFonts.inter(color: c.textSecondary),
              ),
              style: GoogleFonts.inter(color: c.text, fontSize: 16),
            ),
          ),
        ),
        if (suffix.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.sm),
          Text(
            suffix,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: c.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _SwitchInput extends StatelessWidget {
  const _SwitchInput({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = AppTheme.colors;
    return Row(
      children: [
        Text(
          value ? 'Yes' : 'No',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: c.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Switch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
