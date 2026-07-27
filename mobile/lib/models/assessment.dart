class AssessmentResult {
  final String riskLevel;
  final double riskProbability;
  final String? nutritionCategory;
  final String? lifestyleCategory;
  final String? summary;

  AssessmentResult({
    required this.riskLevel,
    required this.riskProbability,
    this.nutritionCategory,
    this.lifestyleCategory,
    this.summary,
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) => AssessmentResult(
        riskLevel: json['risk_level'] as String,
        riskProbability: (json['risk_probability'] as num).toDouble(),
        nutritionCategory: json['nutrition_category'] as String?,
        lifestyleCategory: json['lifestyle_category'] as String?,
        summary: json['llm_recommendation']?['resumen'] as String?,
      );
}
