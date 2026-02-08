import 'package:freezed_annotation/freezed_annotation.dart';

part 'blueprint_question.freezed.dart';
part 'blueprint_question.g.dart';

enum BlueprintQuestionType {
  slider,
  choiceChips,
  multiSelect,
  measurement,
  switchType,
}

/// Single question in a Blueprint (preference questionnaire) section.
@freezed
class BlueprintQuestion with _$BlueprintQuestion {
  const factory BlueprintQuestion({
    required String id,
    required String title,
    required BlueprintQuestionType type,
    /// Slider: left label (e.g. "Relax").
    String? sliderLeftLabel,
    /// Slider: right label (e.g. "Adventure").
    String? sliderRightLabel,
    /// Choice chips / multiSelect: list of options.
    List<String>? options,
    /// Measurement: suffix shown after input (e.g. "US" for ring size).
    String? measurementSuffix,
    /// Measurement: optional placeholder.
    String? measurementPlaceholder,
  }) = _BlueprintQuestion;

  factory BlueprintQuestion.fromJson(Map<String, dynamic> json) =>
      _$BlueprintQuestionFromJson(json);
}
