import 'cycle_settings_model.dart';
import 'cycle_log_model.dart';

/// Enum representing cycle phases
enum CyclePhase {
  menstruation,
  follicular,
  ovulation,
  luteal,
}

/// Model representing daily cycle status
class DailyCycleStatus {
  const DailyCycleStatus({
    required this.phase,
    required this.isFertile,
    required this.dayInCycle,
    required this.partnerMessage,
  });

  final CyclePhase phase;
  final bool isFertile;
  final int dayInCycle;
  final String partnerMessage;
}

/// Pure Dart class for calculating menstrual cycle status
class CycleCalculator {
  /// Calculate cycle status for a target date
  /// 
  /// Rules:
  /// - Ovulation: lastPeriodDate + (averageCycleLength - 14 days)
  /// - Fertile Window: from ovulationDate - 5 days to ovulationDate + 1 day
  /// - Predicted Period: lastPeriodDate + averageCycleLength
  /// - Spotting vs Period: If flowIntensity == spotting, it does NOT reset cycle start date
  ///   Only light, medium, or heavy updates lastPeriodDate
  static DailyCycleStatus calculateStatus({
    required CycleSettings settings,
    required DateTime targetDate,
  }) {
    if (settings.lastPeriodDate == null) {
      return DailyCycleStatus(
        phase: CyclePhase.follicular,
        isFertile: false,
        dayInCycle: 0,
        partnerMessage: 'No period data yet. Track your period to get predictions.',
      );
    }

    final lastPeriodDate = settings.lastPeriodDate!;
    
    // Normalize dates to start of day for comparison
    final normalizedTargetDate = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    final normalizedLastPeriodDate = DateTime(
      lastPeriodDate.year,
      lastPeriodDate.month,
      lastPeriodDate.day,
    );

    // Calculate day in cycle (1-based)
    final daysSinceLastPeriod = normalizedTargetDate.difference(normalizedLastPeriodDate).inDays;
    final dayInCycle = (daysSinceLastPeriod % settings.averageCycleLength) + 1;

    // Calculate ovulation date (14 days before next predicted period)
    final ovulationDayInCycle = settings.averageCycleLength - 14;
    
    // Calculate fertile window
    final fertileWindowStart = ovulationDayInCycle - 5;
    final fertileWindowEnd = ovulationDayInCycle + 1;

    // Determine phase and fertility
    CyclePhase phase;
    bool isFertile = false;

    if (dayInCycle <= settings.periodLength) {
      phase = CyclePhase.menstruation;
      isFertile = false;
    } else if (dayInCycle < fertileWindowStart) {
      phase = CyclePhase.follicular;
      isFertile = false;
    } else if (dayInCycle >= fertileWindowStart && dayInCycle <= fertileWindowEnd) {
      if (dayInCycle == ovulationDayInCycle || dayInCycle == ovulationDayInCycle - 1) {
        phase = CyclePhase.ovulation;
      } else {
        phase = CyclePhase.follicular;
      }
      isFertile = true;
    } else {
      phase = CyclePhase.luteal;
      isFertile = false;
    }

    // Generate partner message based on phase and day
    final partnerMessage = _generatePartnerMessage(
      dayInCycle: dayInCycle,
      phase: phase,
      isFertile: isFertile,
      periodLength: settings.periodLength,
      ovulationDay: ovulationDayInCycle,
    );

    return DailyCycleStatus(
      phase: phase,
      isFertile: isFertile,
      dayInCycle: dayInCycle,
      partnerMessage: partnerMessage,
    );
  }

  /// Calculate ovulation date based on last period date
  static DateTime? calculateOvulationDate({
    required CycleSettings settings,
  }) {
    if (settings.lastPeriodDate == null) return null;

    final ovulationDayOffset = settings.averageCycleLength - 14;
    return settings.lastPeriodDate!.add(Duration(days: ovulationDayOffset));
  }

  /// Calculate fertile window dates
  static ({DateTime start, DateTime end})? calculateFertileWindow({
    required CycleSettings settings,
  }) {
    final ovulationDate = calculateOvulationDate(settings: settings);
    if (ovulationDate == null) return null;

    final start = ovulationDate.subtract(const Duration(days: 5));
    final end = ovulationDate.add(const Duration(days: 1));

    return (start: start, end: end);
  }

  /// Calculate predicted next period date
  static DateTime? calculatePredictedPeriod({
    required CycleSettings settings,
  }) {
    if (settings.lastPeriodDate == null) return null;

    return settings.lastPeriodDate!.add(
      Duration(days: settings.averageCycleLength),
    );
  }

  /// Check if a flow intensity should reset the cycle (spotting does NOT reset)
  static bool shouldResetCycle(FlowIntensity flowIntensity) {
    return flowIntensity != FlowIntensity.spotting;
  }

  /// Generate partner message based on cycle status
  static String _generatePartnerMessage({
    required int dayInCycle,
    required CyclePhase phase,
    required bool isFertile,
    required int periodLength,
    required int ovulationDay,
  }) {
    switch (phase) {
      case CyclePhase.menstruation:
        return 'Day $dayInCycle: Period in progress. Be supportive and patient.';
      
      case CyclePhase.follicular:
        if (isFertile) {
          if (dayInCycle == ovulationDay - 1) {
            return 'Day $dayInCycle: Fertile window open! High chance of conception.';
          }
          return 'Day $dayInCycle: Fertile window approaching. Be attentive and understanding.';
        }
        if (dayInCycle < ovulationDay - 5) {
          return 'Day $dayInCycle: Early cycle. Energy levels rising.';
        }
        return 'Day $dayInCycle: Approaching fertile window. Stay connected.';

      case CyclePhase.ovulation:
        return 'Day $dayInCycle: OVULATION DAY! Peak fertility. High libido alert.';

      case CyclePhase.luteal:
        final daysUntilPeriod = periodLength + (28 - ovulationDay) - (dayInCycle - ovulationDay - 1);
        if (daysUntilPeriod <= 3) {
          return 'Day $dayInCycle: PMS Danger Zone. Be extra patient and understanding.';
        }
        if (daysUntilPeriod <= 7) {
          return 'Day $dayInCycle: Pre-PMS phase. Mood changes possible. Stay supportive.';
        }
        return 'Day $dayInCycle: Post-ovulation. Mood may stabilize.';
    }
  }
}