import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

import '../theme/app_theme.dart';

/// A reusable, generic calendar widget that follows the OurOS design system.
/// 
/// This widget is domain-agnostic and only handles calendar display and interaction.
/// The parent widget provides markers and styling through callbacks.
/// 
/// Features:
/// - Bento-style container (white background, 24px border radius, soft shadow)
/// - Customizable selected day color (default: brand color #5E5CE6)
/// - Customizable today styling
/// - Flexible marker builder for custom day markers
/// - Custom background colors for specific days
class OurOSUniversalCalendar extends StatelessWidget {
  const OurOSUniversalCalendar({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    this.onDaySelected,
    this.markerBuilder,
    this.eventLoader,
    this.calendarBuilders,
    this.calendarStyle,
    this.selectedDayColor,
    this.todayColor,
    this.firstDay,
    this.lastDay,
    this.calendarFormat = CalendarFormat.month,
    this.headerStyle,
    this.daysOfWeekStyle,
    this.onPageChanged,
    this.startingDayOfWeek = StartingDayOfWeek.monday,
  });

  /// The currently focused day in the calendar
  final DateTime focusedDay;

  /// The currently selected day (if any)
  final DateTime? selectedDay;

  /// Callback when a day is selected
  final void Function(DateTime selectedDay, DateTime focusedDay)? onDaySelected;

  /// Builder function for custom markers on specific days
  /// 
  /// Parameters:
  /// - BuildContext: The build context
  /// - DateTime: The date to build markers for
  /// - List: List of events/markers for that day
  /// 
  /// Returns: Widget to display as marker (e.g., dots, icons, images)
  final Widget Function(BuildContext, DateTime, List<dynamic>)? markerBuilder;

  /// Function that returns events/markers for a given day
  /// 
  /// Used in conjunction with markerBuilder to determine what markers to show
  final List<dynamic> Function(DateTime)? eventLoader;

  /// Custom calendar builders for custom day rendering
  /// 
  /// This allows customization of individual days, including background colors
  final CalendarBuilders? calendarBuilders;

  /// Custom calendar style for additional styling options
  /// 
  /// This can be used to set custom background colors for specific days,
  /// text styles, etc. This will be merged with the default styles.
  final CalendarStyle? calendarStyle;

  /// Color for the selected day (default: brand color #5E5CE6)
  final Color? selectedDayColor;

  /// Color for today's date (default: brand color with opacity)
  final Color? todayColor;

  /// First selectable day (default: 50 years ago)
  final DateTime? firstDay;

  /// Last selectable day (default: 50 years from now)
  final DateTime? lastDay;

  /// Calendar format (month, twoWeeks, week)
  final CalendarFormat calendarFormat;

  /// Custom header style
  final HeaderStyle? headerStyle;

  /// Custom days of week style
  final DaysOfWeekStyle? daysOfWeekStyle;

  /// Callback when the calendar page changes
  final void Function(DateTime focusedDay)? onPageChanged;

  /// Starting day of the week (default: Monday)
  final StartingDayOfWeek startingDayOfWeek;

  @override
  Widget build(BuildContext context) {
    final defaultSelectedColor = selectedDayColor ?? AppTheme.colors.primary;
    final defaultTodayColor = todayColor ??
        defaultSelectedColor.withValues(alpha: 0.3);

    // Build calendar style, using custom style if provided, otherwise defaults
    final mergedCalendarStyle = calendarStyle ??
        CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: defaultSelectedColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: defaultTodayColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: defaultSelectedColor,
              width: 2,
            ),
          ),
          selectedTextStyle: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          todayTextStyle: GoogleFonts.inter(
            color: AppTheme.colors.text,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          defaultTextStyle: GoogleFonts.inter(
            color: AppTheme.colors.text,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          weekendTextStyle: GoogleFonts.inter(
            color: AppTheme.colors.text,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          outsideTextStyle: GoogleFonts.inter(
            color: AppTheme.colors.textSecondary,
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          disabledTextStyle: GoogleFonts.inter(
            color: AppTheme.colors.textSecondary.withValues(alpha: 0.5),
            fontWeight: FontWeight.w400,
            fontSize: 16,
          ),
          markerDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: defaultSelectedColor,
          ),
        );

    // Build header style
    final mergedHeaderStyle = headerStyle ??
        HeaderStyle(
          titleTextStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.colors.text,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppTheme.colors.text,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppTheme.colors.text,
          ),
          formatButtonVisible: false,
          titleCentered: true,
        );

    // Build days of week style
    final mergedDaysOfWeekStyle = daysOfWeekStyle ??
        DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.colors.textSecondary,
          ),
          weekendStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.colors.textSecondary,
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.colors.card,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: TableCalendar(
        firstDay: firstDay ?? DateTime.utc(1970, 1, 1),
        lastDay: lastDay ?? DateTime.utc(2070, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: selectedDay != null
            ? (day) => isSameDay(selectedDay, day)
            : null,
        onDaySelected: onDaySelected,
        eventLoader: eventLoader,
        calendarStyle: mergedCalendarStyle,
        headerStyle: mergedHeaderStyle,
        daysOfWeekStyle: mergedDaysOfWeekStyle,
        calendarFormat: calendarFormat,
        onPageChanged: onPageChanged,
        startingDayOfWeek: startingDayOfWeek,
        calendarBuilders: calendarBuilders ?? (markerBuilder != null
            ? CalendarBuilders(
                markerBuilder: markerBuilder,
              )
            : const CalendarBuilders()),
      ),
    );
  }
}