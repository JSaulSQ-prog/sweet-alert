import 'package:flutter/material.dart';
import 'package:diabetes_risk_mobile/models/assessment.dart';
import 'package:diabetes_risk_mobile/models/profile.dart';
import 'package:diabetes_risk_mobile/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  Profile? _profile;
  AssessmentResult? _latestAssessment;
  List<AssessmentResult> _history = [];
  bool _isLoading = false;

  String _selectedSex = 'F';
  String _selectedEducation = 'Secundaria';
  String _selectedIncome = 'Medios';
  String _selectedGenHealth = 'Regular';

  final _birthDateController = TextEditingController(text: '1990-01-01');
  final _heightController = TextEditingController(text: '165');
  final _occupationController = TextEditingController(text: 'Estudiante');

  final _weightController = TextEditingController(text: '70');
  final _sleepHoursController = TextEditingController(text: '6.5');
  final _sleepQualityController = TextEditingController(text: '6');
  final _stressController = TextEditingController(text: '7');
  final _dailyStepsController = TextEditingController(text: '6000');
  final _heartRateController = TextEditingController(text: '78');
  final _caloriesController = TextEditingController(text: '2100');
  final _sugarController = TextEditingController(text: '45');
  final _carbsController = TextEditingController(text: '250');
  final _proteinController = TextEditingController(text: '70');
  final _fatController = TextEditingController(text: '60');
  final _fiberController = TextEditingController(text: '20');
  final _waterController = TextEditingController(text: '1.8');
  final _fruitServingsController = TextEditingController(text: '2');
  final _veggieServingsController = TextEditingController(text: '3');

  bool _highBp = false;
  bool _highChol = false;
  bool _smoker = false;
  bool _physActivity = true;
  bool _fruits = true;
  bool _veggies = true;
  bool _diffWalk = false;
  bool _polyuria = false;
  bool _polydipsia = false;
  bool _suddenWeightLoss = false;
  bool _weakness = false;
  bool _polyphagia = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    _heightController.dispose();
    _occupationController.dispose();
    _weightController.dispose();
    _sleepHoursController.dispose();
    _sleepQualityController.dispose();
    _stressController.dispose();
    _dailyStepsController.dispose();
    _heartRateController.dispose();
    _caloriesController.dispose();
    _sugarController.dispose();
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _waterController.dispose();
    _fruitServingsController.dispose();
    _veggieServingsController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _apiService.getProfile();
      final history = await _apiService.getHistory();
      setState(() {
        _profile = profile;
        _history = history;
        _selectedSex = profile.sex;
        _birthDateController.text = profile.birthDate.toIso8601String().split('T').first;
        _heightController.text = profile.heightCm.toString();
        _selectedEducation = _educationLabelFromValue(profile.educationLevel);
        _selectedIncome = _incomeLabelFromValue(profile.incomeLevel);
        _occupationController.text = profile.occupation ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todavía no hay perfil guardado: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _apiService.saveProfile(
        Profile(
          sex: _selectedSex,
          birthDate: DateTime.parse(_birthDateController.text),
          heightCm: double.parse(_heightController.text),
          educationLevel: _educationValueFromLabel(_selectedEducation),
          incomeLevel: _incomeValueFromLabel(_selectedIncome),
          occupation: _occupationController.text.isEmpty ? null : _occupationController.text,
        ),
      );
      setState(() => _profile = profile);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el perfil: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendAssessment() async {
    setState(() => _isLoading = true);
    try {
      final assessment = await _apiService.sendAssessment(
        weightKg: double.parse(_weightController.text),
        highBp: _highBp,
        highChol: _highChol,
        smoker: _smoker,
        physActivity: _physActivity,
        fruits: _fruits,
        veggies: _veggies,
        genHealth: _genHealthValueFromLabel(_selectedGenHealth),
        diffWalk: _diffWalk,
        polyuria: _polyuria,
        polydipsia: _polydipsia,
        suddenWeightLoss: _suddenWeightLoss,
        weakness: _weakness,
        polyphagia: _polyphagia,
        sleepDurationHours: double.parse(_sleepHoursController.text),
        sleepQuality: int.parse(_sleepQualityController.text),
        stressLevel: int.parse(_stressController.text),
        dailySteps: int.parse(_dailyStepsController.text),
        heartRate: int.parse(_heartRateController.text),
        dailyCalories: double.parse(_caloriesController.text),
        sugarG: double.parse(_sugarController.text),
        carbsG: double.parse(_carbsController.text),
        proteinG: double.parse(_proteinController.text),
        fatG: double.parse(_fatController.text),
        fiberG: double.parse(_fiberController.text),
        waterL: double.parse(_waterController.text),
        fruitServings: int.parse(_fruitServingsController.text),
        veggieServings: int.parse(_veggieServingsController.text),
      );
      setState(() {
        _latestAssessment = assessment;
        _history = [assessment, ..._history];
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check-in enviado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo enviar el check-in: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _educationLabelFromValue(int value) {
    switch (value) {
      case 1:
        return 'Primaria';
      case 2:
        return 'Secundaria';
      case 3:
        return 'Técnico/Superior';
      default:
        return 'Secundaria';
    }
  }

  int _educationValueFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'primaria':
        return 1;
      case 'secundaria':
        return 2;
      case 'técnico/superior':
      case 'tecnico/superior':
        return 3;
      default:
        return 2;
    }
  }

  String _incomeLabelFromValue(int value) {
    switch (value) {
      case 1:
        return 'Muy bajos';
      case 2:
        return 'Bajos';
      case 3:
        return 'Medios bajos';
      case 4:
        return 'Medios';
      case 5:
        return 'Medios altos';
      case 6:
        return 'Altos';
      case 7:
        return 'Muy altos';
      default:
        return 'Medios';
    }
  }

  int _incomeValueFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'muy bajos':
        return 1;
      case 'bajos':
        return 2;
      case 'medios bajos':
        return 3;
      case 'medios':
        return 4;
      case 'medios altos':
        return 5;
      case 'altos':
        return 6;
      case 'muy altos':
        return 7;
      default:
        return 4;
    }
  }

  String _genHealthLabelFromValue(int value) {
    switch (value) {
      case 1:
        return 'Mala';
      case 2:
        return 'Regular';
      case 3:
        return 'Buena';
      case 4:
        return 'Muy buena';
      case 5:
        return 'Excelente';
      default:
        return 'Regular';
    }
  }

  int _genHealthValueFromLabel(String label) {
    switch (label.toLowerCase()) {
      case 'mala':
        return 1;
      case 'regular':
        return 2;
      case 'buena':
        return 3;
      case 'muy buena':
        return 4;
      case 'excelente':
        return 5;
      default:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text('Sweet Alert'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _buildHeroCard(),
            const SizedBox(height: 18),
            _buildSectionHeader('Tu perfil', 'Actualiza tus datos para personalizar el análisis'),
            _buildProfileCard(),
            const SizedBox(height: 18),
            _buildSectionHeader('Check-in diario', 'Registra tu estado de salud y nutrición'),
            _buildCheckInCard(),
            const SizedBox(height: 18),
            _buildSectionHeader('Historial', 'Revisa tus evaluaciones previas'),
            _buildHistoryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final profileText = _profile == null
        ? 'Completa tu perfil para personalizar el análisis.'
        : 'Perfil listo para ${_profile!.sex} · ${_profile!.heightCm.toStringAsFixed(0)} cm · ${_profile!.occupation ?? 'sin ocupación'}';

    final resultText = _latestAssessment == null
        ? 'Tus resultados aparecerán aquí tras enviar el primer check-in.'
        : 'Último resultado: ${_latestAssessment!.riskLevel} · ${( _latestAssessment!.riskProbability * 100).toStringAsFixed(1)}% de riesgo';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu bienestar, en una sola vista',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _profile == null ? 'Bienvenido' : 'Bienvenido de nuevo',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profileText,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Text(
            resultText,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildPill('Monitoreo continuo', Icons.monitor_heart_rounded),
              _buildPill('Recomendaciones claras', Icons.auto_awesome_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProfileCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Datos del perfil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedSex,
            decoration: const InputDecoration(labelText: 'Sexo'),
            items: const [
              DropdownMenuItem(value: 'M', child: Text('Masculino')),
              DropdownMenuItem(value: 'F', child: Text('Femenino')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _selectedSex = value);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(controller: _birthDateController, decoration: const InputDecoration(labelText: 'Fecha de nacimiento (YYYY-MM-DD)')),
          const SizedBox(height: 10),
          TextFormField(controller: _heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Altura (cm)')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedEducation,
            decoration: const InputDecoration(labelText: 'Educación'),
            items: const [
              DropdownMenuItem(value: 'Primaria', child: Text('Primaria')),
              DropdownMenuItem(value: 'Secundaria', child: Text('Secundaria')),
              DropdownMenuItem(value: 'Técnico/Superior', child: Text('Técnico/Superior')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _selectedEducation = value);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedIncome,
            decoration: const InputDecoration(labelText: 'Ingreso'),
            items: const [
              DropdownMenuItem(value: 'Muy bajos', child: Text('Muy bajos')),
              DropdownMenuItem(value: 'Bajos', child: Text('Bajos')),
              DropdownMenuItem(value: 'Medios bajos', child: Text('Medios bajos')),
              DropdownMenuItem(value: 'Medios', child: Text('Medios')),
              DropdownMenuItem(value: 'Medios altos', child: Text('Medios altos')),
              DropdownMenuItem(value: 'Altos', child: Text('Altos')),
              DropdownMenuItem(value: 'Muy altos', child: Text('Muy altos')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _selectedIncome = value);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(controller: _occupationController, decoration: const InputDecoration(labelText: 'Ocupación')),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _saveProfile,
              icon: const Icon(Icons.save_rounded),
              label: const Text('Guardar perfil'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Información de hoy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          const SizedBox(height: 12),
          TextFormField(controller: _weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Peso (kg)')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedGenHealth,
            decoration: const InputDecoration(labelText: 'Salud general'),
            items: const [
              DropdownMenuItem(value: 'Mala', child: Text('Mala')),
              DropdownMenuItem(value: 'Regular', child: Text('Regular')),
              DropdownMenuItem(value: 'Buena', child: Text('Buena')),
              DropdownMenuItem(value: 'Muy buena', child: Text('Muy buena')),
              DropdownMenuItem(value: 'Excelente', child: Text('Excelente')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _selectedGenHealth = value);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(controller: _sleepHoursController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Horas de sueño')),
          const SizedBox(height: 10),
          TextFormField(controller: _sleepQualityController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calidad de sueño (1-10)')),
          const SizedBox(height: 10),
          TextFormField(controller: _stressController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Estrés (1-10)')),
          const SizedBox(height: 10),
          TextFormField(controller: _dailyStepsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pasos diarios')),
          const SizedBox(height: 10),
          TextFormField(controller: _heartRateController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Frecuencia cardíaca')),
          const SizedBox(height: 10),
          TextFormField(controller: _caloriesController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Calorías')),
          const SizedBox(height: 10),
          TextFormField(controller: _sugarController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Azúcar (g)')),
          const SizedBox(height: 10),
          TextFormField(controller: _carbsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Carbs (g)')),
          const SizedBox(height: 10),
          TextFormField(controller: _proteinController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Proteína (g)')),
          const SizedBox(height: 10),
          TextFormField(controller: _fatController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Grasa (g)')),
          const SizedBox(height: 10),
          TextFormField(controller: _fiberController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fibra (g)')),
          const SizedBox(height: 10),
          TextFormField(controller: _waterController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Agua (L)')),
          const SizedBox(height: 10),
          TextFormField(controller: _fruitServingsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Porciones de fruta')),
          const SizedBox(height: 10),
          TextFormField(controller: _veggieServingsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Porciones de verduras')),
          const SizedBox(height: 14),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _highBp,
            onChanged: (value) => setState(() => _highBp = value),
            title: const Text('Presión alta'),
            subtitle: const Text('Monitorea tu salud cardiovascular'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _highChol,
            onChanged: (value) => setState(() => _highChol = value),
            title: const Text('Colesterol alto'),
            subtitle: const Text('Registra hábitos que impactan el metabolismo'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _smoker,
            onChanged: (value) => setState(() => _smoker = value),
            title: const Text('Fumador'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _physActivity,
            onChanged: (value) => setState(() => _physActivity = value),
            title: const Text('Actividad física'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _fruits,
            onChanged: (value) => setState(() => _fruits = value),
            title: const Text('Consume fruta'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _veggies,
            onChanged: (value) => setState(() => _veggies = value),
            title: const Text('Consume verduras'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _diffWalk,
            onChanged: (value) => setState(() => _diffWalk = value),
            title: const Text('Dificultad para caminar'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _polyuria,
            onChanged: (value) => setState(() => _polyuria = value),
            title: const Text('Poliuria'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _polydipsia,
            onChanged: (value) => setState(() => _polydipsia = value),
            title: const Text('Polidipsia'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _suddenWeightLoss,
            onChanged: (value) => setState(() => _suddenWeightLoss = value),
            title: const Text('Pérdida de peso'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _weakness,
            onChanged: (value) => setState(() => _weakness = value),
            title: const Text('Debilidad'),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _polyphagia,
            onChanged: (value) => setState(() => _polyphagia = value),
            title: const Text('Hambre excesiva'),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _sendAssessment,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Enviar check-in'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_history.isEmpty)
            const Text('Aún no hay evaluaciones guardadas.', style: TextStyle(color: Color(0xFF64748B)))
          else
            ..._history.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDBEAFE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.history_rounded, size: 16, color: Color(0xFF1D4ED8)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.riskLevel.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('Probabilidad ${(item.riskProbability * 100).toStringAsFixed(1)}%'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
