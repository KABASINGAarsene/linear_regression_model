import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

// ─── Colour tokens ────────────────────────────────────────────────────────────
const _emerald      = Color(0xFF10B981);
const _emeraldDark  = Color(0xFF059669);
const _emeraldLight = Color(0xFFD1FAE5);
const _bgColor      = Color(0xFFF8FAFB);
const _textDark     = Color(0xFF111827);
const _textMuted    = Color(0xFF6B7280);

// ─── API base URL ─────────────────────────────────────────────────────────────
// Updated with your live Render URL
String get _baseUrl {
  return 'https://energy-api-sgov.onrender.com';
}

void main() {
  runApp(const EnergyPredictorApp());
}

class EnergyPredictorApp extends StatelessWidget {
  const EnergyPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Energy Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: _emerald,
        useMaterial3: true,
        scaffoldBackgroundColor: _bgColor,
        textTheme: GoogleFonts.interTextTheme(),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: _emerald, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          labelStyle: const TextStyle(color: _textMuted),
          floatingLabelStyle: const TextStyle(color: _emerald),
        ),
      ),
      home: const PredictorPage(),
    );
  }
}

// ─── Main Page ────────────────────────────────────────────────────────────────
class PredictorPage extends StatefulWidget {
  const PredictorPage({super.key});
  @override
  State<PredictorPage> createState() => _PredictorPageState();
}

class _PredictorPageState extends State<PredictorPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _sqftCtrl  = TextEditingController();
  final _occCtrl   = TextEditingController();
  final _appCtrl   = TextEditingController();
  final _tempCtrl  = TextEditingController();

  int    _dayOfWeek  = 0; // 0 = Weekday, 1 = Weekend
  bool   _isLoading  = false;
  double? _prediction;
  String? _errorMsg;

  late AnimationController _glowCtrl;
  late Animation<double>   _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 6, end: 18).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _sqftCtrl.dispose();
    _occCtrl.dispose();
    _appCtrl.dispose();
    _tempCtrl.dispose();
    super.dispose();
  }

  // ── HTTP call ───────────────────────────────────────────────────────────────
  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMsg = null; _prediction = null; });

    final payload = {
      'square_footage':  double.parse(_sqftCtrl.text),
      'num_occupants':   int.parse(_occCtrl.text),
      'appliances_used': int.parse(_appCtrl.text),
      'avg_temperature': double.parse(_tempCtrl.text),
      'day_of_week':     _dayOfWeek,
    };

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() => _prediction = (body['predicted_energy_kwh'] as num).toDouble());
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() => _errorMsg = body['detail']?.toString() ?? 'Server error ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMsg = 'Could not reach the server.\n$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Validators ──────────────────────────────────────────────────────────────
  String? _numValidator(String? v, {double min = 0, double max = double.infinity, bool integer = false}) {
    if (v == null || v.trim().isEmpty) return 'This field is required.';
    final n = double.tryParse(v);
    if (n == null) return 'Enter a valid number.';
    if (integer && n != n.truncate()) return 'Enter a whole number.';
    if (n < min) return 'Minimum value is $min.';
    if (n > max) return 'Maximum value is $max.';
    return null;
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: _emeraldDark,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Energy Predictor',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_emeraldDark, Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 56, left: 20, right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        'Enter house details to predict monthly energy usage.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Form body ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle('House Details'),
                    const SizedBox(height: 12),

                    _inputField(
                      controller: _sqftCtrl,
                      label: 'Square Footage',
                      hint: 'e.g. 2500',
                      icon: Icons.home_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => _numValidator(v, min: 100, max: 10000),
                    ),
                    const SizedBox(height: 14),

                    _inputField(
                      controller: _occCtrl,
                      label: 'Number of Occupants',
                      hint: 'e.g. 4',
                      icon: Icons.people_outline,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => _numValidator(v, min: 1, max: 20, integer: true),
                    ),
                    const SizedBox(height: 14),

                    _inputField(
                      controller: _appCtrl,
                      label: 'Appliances Used',
                      hint: 'e.g. 8',
                      icon: Icons.electrical_services_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) => _numValidator(v, min: 0, max: 50, integer: true),
                    ),
                    const SizedBox(height: 14),

                    _inputField(
                      controller: _tempCtrl,
                      label: 'Average Temperature (°C)',
                      hint: 'e.g. 22.5',
                      icon: Icons.thermostat_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) => _numValidator(v, min: -30, max: 55),
                    ),
                    const SizedBox(height: 20),

                    // Day of Week toggle
                    _sectionTitle('Day Type'),
                    const SizedBox(height: 10),
                    _dayOfWeekToggle(),
                    const SizedBox(height: 28),

                    // Predict button
                    _predictButton(),
                    const SizedBox(height: 24),

                    // Result / Error area
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                    begin: const Offset(0, 0.2),
                                    end: Offset.zero)
                                    .animate(anim),
                                child: child,
                              )),
                      child: _isLoading
                          ? _loadingWidget()
                          : _prediction != null
                              ? _resultCard()
                              : _errorMsg != null
                                  ? _errorCard()
                                  : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Widgets ─────────────────────────────────────────────────────────────────

  Widget _sectionTitle(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _textMuted,
          letterSpacing: 0.8,
        ),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: _textDark, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 14),
        prefixIcon: Icon(icon, color: _emerald, size: 22),
      ),
    );
  }

  Widget _dayOfWeekToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          _dayOption(label: '☀️  Weekday', value: 0),
          _dayOption(label: '🌴  Weekend', value: 1),
        ],
      ),
    );
  }

  Widget _dayOption({required String label, required int value}) {
    final selected = _dayOfWeek == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _dayOfWeek = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? _emerald : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : _textMuted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _predictButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _predict,
        icon: const Icon(Icons.bolt_rounded, size: 22),
        label: Text(
          'Predict Energy Usage',
          style: GoogleFonts.inter(
              fontSize: 16, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _emerald,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _emeraldLight,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          shadowColor: _emerald.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _loadingWidget() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: _emerald, strokeWidth: 3),
              SizedBox(height: 14),
              Text('AI is thinking…',
                  style: TextStyle(color: _textMuted, fontSize: 14)),
            ],
          ),
        ),
      );

  Widget _resultCard() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF065F46), _emeraldDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _emerald.withValues(alpha: 0.45),
                blurRadius: _glowAnim.value,
                spreadRadius: 1,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: child,
        );
      },
      child: Column(
        children: [
          const Icon(Icons.energy_savings_leaf_rounded,
              color: Color(0xFF6EE7B7), size: 40),
          const SizedBox(height: 12),
          Text(
            'Predicted Energy Consumption',
            style: GoogleFonts.inter(
              color: const Color(0xFFD1FAE5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_prediction!.toStringAsFixed(2)} kWh',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'per month',
            style: GoogleFonts.inter(
                color: const Color(0xFF6EE7B7), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCA5A5)),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMsg!,
              style: const TextStyle(
                  color: Color(0xFF991B1B), fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
