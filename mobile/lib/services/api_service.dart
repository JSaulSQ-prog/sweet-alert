import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:diabetes_risk_mobile/models/assessment.dart';
import 'package:diabetes_risk_mobile/models/profile.dart';

class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:8000';
  static const String _authHeader = 'Bearer demo';

  Future<Profile> getProfile() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {'Authorization': _authHeader},
    );
    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar el perfil');
    }
    return Profile.fromJson(jsonDecode(response.body));
  }

  Future<Profile> saveProfile(Profile profile) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _authHeader,
      },
      body: jsonEncode(profile.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    return Profile.fromJson(jsonDecode(response.body));
  }

  Future<AssessmentResult> sendAssessment({
    required double weightKg,
    required bool highBp,
    required bool highChol,
    required bool smoker,
    required bool physActivity,
    required bool fruits,
    required bool veggies,
    required int genHealth,
    required bool diffWalk,
    required bool polyuria,
    required bool polydipsia,
    required bool suddenWeightLoss,
    required bool weakness,
    required bool polyphagia,
    required double sleepDurationHours,
    required int sleepQuality,
    required int stressLevel,
    required int dailySteps,
    required int heartRate,
    required double dailyCalories,
    required double sugarG,
    required double carbsG,
    required double proteinG,
    required double fatG,
    required double fiberG,
    required double waterL,
    required int fruitServings,
    required int veggieServings,
  }) async {
    final payload = {
      'weight_kg': weightKg,
      'high_bp': highBp,
      'high_chol': highChol,
      'chol_check': true,
      'smoker': smoker,
      'stroke': false,
      'heart_disease': false,
      'phys_activity': physActivity,
      'fruits': fruits,
      'veggies': veggies,
      'hvy_alcohol': false,
      'any_healthcare': true,
      'no_doc_cost': false,
      'gen_health': genHealth,
      'ment_health_days': 2,
      'phys_health_days': 1,
      'diff_walk': diffWalk,
      'polyuria': polyuria,
      'polydipsia': polydipsia,
      'sudden_weight_loss': suddenWeightLoss,
      'weakness': weakness,
      'polyphagia': polyphagia,
      'genital_thrush': false,
      'visual_blurring': false,
      'itching': false,
      'irritability': false,
      'delayed_healing': false,
      'partial_paresis': false,
      'muscle_stiffness': false,
      'alopecia': false,
      'obesity': false,
      'sleep_duration_hours': sleepDurationHours,
      'sleep_quality': sleepQuality,
      'physical_activity_level': 40,
      'stress_level': stressLevel,
      'daily_steps': dailySteps,
      'heart_rate': heartRate,
      'daily_calories': dailyCalories,
      'sugar_g': sugarG,
      'carbs_g': carbsG,
      'protein_g': proteinG,
      'fat_g': fatG,
      'fiber_g': fiberG,
      'water_l': waterL,
      'fruit_servings': fruitServings,
      'veggie_servings': veggieServings,
    };

    final response = await http.post(
      Uri.parse('$_baseUrl/assessments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _authHeader,
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return AssessmentResult.fromJson(decoded);
  }

  Future<List<AssessmentResult>> getHistory() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/assessments'),
      headers: {'Authorization': _authHeader},
    );
    if (response.statusCode != 200) {
      throw Exception('No se pudo cargar el historial');
    }
    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded.map((item) => AssessmentResult.fromJson(item as Map<String, dynamic>)).toList();
  }
}
