class RubricCheck {
  final String rubricItem;
  final String status;
  final String textSnippet;
  final String suggestion;

  RubricCheck({
    required this.rubricItem,
    required this.status,
    required this.textSnippet,
    required this.suggestion,
  });

  factory RubricCheck.fromJson(Map<String, dynamic> json) {
    return RubricCheck(
      rubricItem: json['rubric_item'],
      status: json['status'],
      textSnippet: json['text_snippet'],
      suggestion: json['suggestion'],
    );
  }
}

class AutogradeFeedback {
  final String completionStatus;
  final List<RubricCheck> rubricChecks;
  final String overallFeedback;

  AutogradeFeedback({
    required this.completionStatus,
    required this.rubricChecks,
    required this.overallFeedback,
  });

  factory AutogradeFeedback.fromJson(Map<String, dynamic> json) {
    return AutogradeFeedback(
      completionStatus: json['completion_status'],
      rubricChecks: (json['rubric_checks'] as List)
          .map((e) => RubricCheck.fromJson(e))
          .toList(),
      overallFeedback: json['overall_feedback'],
    );
  }
}
