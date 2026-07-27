class Profile {
  final String sex;
  final DateTime birthDate;
  final double heightCm;
  final int educationLevel;
  final int incomeLevel;
  final String? occupation;

  Profile({
    required this.sex,
    required this.birthDate,
    required this.heightCm,
    required this.educationLevel,
    required this.incomeLevel,
    this.occupation,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        sex: json['sex'] as String,
        birthDate: DateTime.parse(json['birth_date'] as String),
        heightCm: (json['height_cm'] as num).toDouble(),
        educationLevel: json['education_level'] as int,
        incomeLevel: json['income_level'] as int,
        occupation: json['occupation'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'sex': sex,
        'birth_date': birthDate.toIso8601String().split('T').first,
        'height_cm': heightCm,
        'education_level': educationLevel,
        'income_level': incomeLevel,
        'occupation': occupation,
      };
}
