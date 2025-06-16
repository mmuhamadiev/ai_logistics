class GroupingHelperResultModel {
  final bool isGoodGroup;
  final List<String> issues;
  final String reasoning;
  final List<String> recommendations;

  GroupingHelperResultModel({
    required this.isGoodGroup,
    required this.issues,
    required this.reasoning,
    required this.recommendations,
  });

  factory GroupingHelperResultModel.fromJson(Map<String, dynamic> json) {
    return GroupingHelperResultModel(
      isGoodGroup: json['isGoodGroup'] ?? false,
      issues: List<String>.from(json['issues'] ?? []),
      reasoning: json['reasoning'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}
