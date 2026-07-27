class AssessmentResult {
  final String riskLevel;
  final double riskProbability;
  final String? symptomsLevel;
  final double? symptomsProbability;
  final double? sleepDisorderProbability;
  final String? nutritionCategory;
  final double? nutritionScore;
  final String? lifestyleCategory;
  final String? summary;
  final String? factorPrincipal;
  final List<String> recommendations;

  AssessmentResult({
    required this.riskLevel,
    required this.riskProbability,
    this.symptomsLevel,
    this.symptomsProbability,
    this.sleepDisorderProbability,
    this.nutritionCategory,
    this.nutritionScore,
    this.lifestyleCategory,
    this.summary,
    this.factorPrincipal,
    this.recommendations = const [],
  });

  factory AssessmentResult.fromJson(Map<String, dynamic> json) => AssessmentResult(
        riskLevel: json['risk_level'] as String,
        riskProbability: (json['risk_probability'] as num).toDouble(),
        symptomsLevel: json['symptoms_level'] as String?,
        symptomsProbability: (json['symptoms_probability'] as num?)?.toDouble(),
        sleepDisorderProbability: (json['sleep_disorder_probability'] as num?)?.toDouble(),
        nutritionCategory: json['nutrition_category'] as String?,
        nutritionScore: (json['nutrition_score'] as num?)?.toDouble(),
        lifestyleCategory: json['lifestyle_category'] as String?,
        summary: json['llm_recommendation']?['resumen'] as String?,
        factorPrincipal: json['llm_recommendation']?['factor_principal'] as String?,
        recommendations: (json['llm_recommendation']?['recomendaciones'] as List<dynamic>?)
                ?.map((item) => item.toString())
                .toList() ??
            [],
      );
}
