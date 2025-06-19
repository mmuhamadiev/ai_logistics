class GroupingHelperResultModel {
  final bool isGoodGroup;
  final String reasoning;
  final List<String> issues;
  final List<String> recommendations;

  GroupingHelperResultModel({
    required this.isGoodGroup,
    required this.reasoning,
    required this.issues,
    required this.recommendations,
  });

  factory GroupingHelperResultModel.fromJson(Map<String, dynamic> json) {
    return GroupingHelperResultModel(
      isGoodGroup: json['isGoodGroup'] as bool,
      reasoning: json['reasoning'] as String? ?? '',
      issues: List<String>.from(json['issues'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}