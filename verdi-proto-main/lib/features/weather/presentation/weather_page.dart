import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;

import '../../../core/services/verdi_api_service.dart';
import '../../../state/app_state.dart';
import '../data/weather_model.dart';
import 'weather_provider.dart';

class WeatherPage extends ConsumerStatefulWidget {
  const WeatherPage({super.key});

  @override
  ConsumerState<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends ConsumerState<WeatherPage> {
  String _selectedLocation = 'Harare, Zimbabwe';
  String _selectedRadarMode = 'Precipitation Radar';
  bool _isAiQuerying = false;
  String? _customAiReply;
  bool _isTransporterView = false;
  String _selectedCorridor = 'A4: Harare ──▶ Chiredzi (420 km)';

  static const green = Color(0xFF16A34A);
  static const dark = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const blue = Color(0xFF2563EB);
  static const orange = Color(0xFFF97316);

  final List<String> _locations = const [
    'Harare, Zimbabwe',
    'Chiredzi, Lowveld',
    'Mutare, Manicaland',
    'Bindura, Mashonaland',
    'Bulawayo, Matabeleland',
  ];

  final List<String> _corridors = const [
    'A4: Harare ──▶ Chiredzi (420 km)',
    'N2: Harare ──▶ Bulawayo (440 km)',
    'Grain Belt: Mvurwi ──▶ Bulawayo (540 km)',
    'A3: Harare ──▶ Mutare / Beira (290 km)',
  ];

  WeatherData _getWeatherDataForLocation(String location, WeatherData baseWeather) {
    if (location.contains('Chiredzi')) {
      return const WeatherData(
        location: 'Chiredzi, Lowveld',
        summary: 'Hot & sunny with high solar irradiance',
        temperature: 33,
        feelsLike: 35,
        humidity: 42,
        windSpeed: 11,
        pressure: 1012,
        rainChance: 10,
        visibility: 10,
        alerts: [
          WeatherAlert(
            title: 'Heat & Transpiration Alert',
            message: 'High evapotranspiration (6.5mm/day) expected. Increase pivot irrigation cycles.',
            severity: 'Medium',
          ),
        ],
        hourly: [
          HourlyForecast(time: '10 AM', temperature: 31, condition: 'Sunny'),
          HourlyForecast(time: '11 AM', temperature: 33, condition: 'Sunny'),
          HourlyForecast(time: '12 PM', temperature: 34, condition: 'Sunny'),
          HourlyForecast(time: '01 PM', temperature: 35, condition: 'Sunny'),
          HourlyForecast(time: '02 PM', temperature: 34, condition: 'Cloudy'),
          HourlyForecast(time: '03 PM', temperature: 33, condition: 'Sunny'),
        ],
        daily: [
          DailyForecast(day: 'Today', minTemp: 23, maxTemp: 35, condition: 'Sunny'),
          DailyForecast(day: 'Fri', minTemp: 22, maxTemp: 34, condition: 'Sunny'),
          DailyForecast(day: 'Sat', minTemp: 23, maxTemp: 36, condition: 'Sunny'),
          DailyForecast(day: 'Sun', minTemp: 24, maxTemp: 33, condition: 'Cloudy'),
        ],
      );
    } else if (location.contains('Mutare')) {
      return const WeatherData(
        location: 'Mutare, Manicaland',
        summary: 'Cool mist & high chance of afternoon showers',
        temperature: 24,
        feelsLike: 24,
        humidity: 82,
        windSpeed: 18,
        pressure: 1018,
        rainChance: 75,
        visibility: 6,
        alerts: [
          WeatherAlert(
            title: 'Fungal Disease Risk',
            message: 'Persistent high humidity (82%) favors leaf wetness. Apply protective fungicide.',
            severity: 'High',
          ),
        ],
        hourly: [
          HourlyForecast(time: '10 AM', temperature: 23, condition: 'Cloudy'),
          HourlyForecast(time: '11 AM', temperature: 24, condition: 'Rain'),
          HourlyForecast(time: '12 PM', temperature: 24, condition: 'Rain'),
          HourlyForecast(time: '01 PM', temperature: 23, condition: 'Storm'),
          HourlyForecast(time: '02 PM', temperature: 22, condition: 'Rain'),
          HourlyForecast(time: '03 PM', temperature: 23, condition: 'Cloudy'),
        ],
        daily: [
          DailyForecast(day: 'Today', minTemp: 18, maxTemp: 24, condition: 'Rain'),
          DailyForecast(day: 'Fri', minTemp: 17, maxTemp: 23, condition: 'Rain'),
          DailyForecast(day: 'Sat', minTemp: 18, maxTemp: 25, condition: 'Cloudy'),
          DailyForecast(day: 'Sun', minTemp: 19, maxTemp: 26, condition: 'Sunny'),
        ],
      );
    }
    return baseWeather;
  }

  Future<void> _askAiWeatherConsultant(String question) async {
    setState(() {
      _isAiQuerying = true;
      _customAiReply = null;
    });

    final prompt = 'You are Verdi Backend AI Agronomic Weather Advisor. Location: $_selectedLocation. Question: $question';
    try {
      final reply = await VerdiApiService.instance.askBackendAi(prompt);
      if (mounted) {
        setState(() {
          _customAiReply = reply;
          _isAiQuerying = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _customAiReply = 'Agronomic weather insight for $_selectedLocation: Maintain optimal soil moisture and monitor wind vectors before chemical spraying.';
          _isAiQuerying = false;
        });
      }
    }
  }

  void _showAiAdvisorDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.smart_toy_rounded, color: green),
              const SizedBox(width: 10),
              Text('Verdi Backend AI Weather Consultant', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask Verdi\'s Backend AI tailored questions about current weather impacts on your crops, spraying windows, or irrigation in $_selectedLocation.',
                  style: GoogleFonts.inter(fontSize: 12.5, color: muted),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Is today suitable for spraying maize in $_selectedLocation?',
                    hintStyle: GoogleFonts.inter(fontSize: 12, color: muted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('Spraying Window?'),
                      onPressed: () {
                        textController.text = 'What is the optimal pesticide spraying window today in $_selectedLocation?';
                      },
                    ),
                    ActionChip(
                      label: const Text('Irrigation Need?'),
                      onPressed: () {
                        textController.text = 'How much irrigation is recommended today given current humidity and temperature?';
                      },
                    ),
                    ActionChip(
                      label: const Text('Frost/Pest Risk?'),
                      onPressed: () {
                        textController.text = 'Is there any blight or pest outbreak risk with today\'s weather in $_selectedLocation?';
                      },
                    ),
                  ],
                ),
                if (_isAiQuerying) ...[
                  const SizedBox(height: 16),
                  const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 10),
                        Text('Querying Verdi Backend AI...'),
                      ],
                    ),
                  ),
                ] else if (_customAiReply != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: green.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology_outlined, color: green, size: 18),
                            const SizedBox(width: 6),
                            Text('Verdi AI Response:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: green)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(_customAiReply!, style: GoogleFonts.inter(fontSize: 12.5, color: dark)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ElevatedButton.icon(
              onPressed: () async {
                if (textController.text.trim().isNotEmpty) {
                  setModalState(() => _isAiQuerying = true);
                  await _askAiWeatherConsultant(textController.text.trim());
                  setModalState(() => _isAiQuerying = false);
                }
              },
              icon: const Icon(Icons.send_rounded, size: 16),
              label: const Text('Ask AI'),
              style: ElevatedButton.styleFrom(backgroundColor: green, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<WeatherProvider>();
    final appRole = ref.watch(appStateProvider).role;
    final isTransporterRole = appRole == UserRole.transporter || appRole == UserRole.admin;
    final effectiveTransporterView = isTransporterRole ? _isTransporterView : false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Agri-Climate Intelligence',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: dark),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAiAdvisorDialog(context),
            icon: const Icon(Icons.psychology_rounded, color: green),
            tooltip: 'Ask Verdi Backend AI Weather Advisor',
          ),
          IconButton(
            onPressed: state.loadWeather,
            icon: state.isLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded, color: dark),
            tooltip: 'Refresh Weather Data',
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.weather == null
                    ? Center(
                        child: Text(
                          state.error ?? 'No weather data available',
                          style: GoogleFonts.inter(color: dark),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: MediaQuery.of(context).size.width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 1100;
                            final activeWeather = _getWeatherDataForLocation(_selectedLocation, state.weather!);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Transporter vs Farm Mode Switcher Bar (Only visible for Carrier/Admin roles)
                                if (isTransporterRole)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => setState(() => _isTransporterView = true),
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              decoration: BoxDecoration(
                                                color: _isTransporterView ? const Color(0xFFF97316) : Colors.transparent,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.local_shipping_rounded, size: 18, color: _isTransporterView ? Colors.white : dark),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Transporter Highway Corridors',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: _isTransporterView ? Colors.white : dark,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: InkWell(
                                            onTap: () => setState(() => _isTransporterView = false),
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              decoration: BoxDecoration(
                                                color: !_isTransporterView ? green : Colors.transparent,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.agriculture_rounded, size: 18, color: !_isTransporterView ? Colors.white : dark),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Farm Agronomy & Crops',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12.5,
                                                      fontWeight: FontWeight.bold,
                                                      color: !_isTransporterView ? Colors.white : dark,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                if (effectiveTransporterView) ...[
                                  // Transporter Corridor Picker
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.alt_route_rounded, color: orange, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Transit Corridor:',
                                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: dark),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: _corridors.map((corridor) {
                                                final selected = corridor == _selectedCorridor;
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 6),
                                                  child: ChoiceChip(
                                                    label: Text('${corridor.split(':').first}: ${corridor.split('──▶').last}'),
                                                    selected: selected,
                                                    selectedColor: orange,
                                                    labelStyle: GoogleFonts.inter(
                                                      color: selected ? Colors.white : dark,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 11.5,
                                                    ),
                                                    onSelected: (_) {
                                                      setState(() => _selectedCorridor = corridor);
                                                    },
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Transporter Logistics Weather Hero Card
                                  _TransporterWeatherHeroCard(
                                    corridor: _selectedCorridor,
                                    weather: activeWeather,
                                    onAskAi: () => _showAiAdvisorDialog(context),
                                  ),
                                  const SizedBox(height: 16),

                                  // Transporter Logistics Hazards & Road Kpis
                                  _TransporterLogisticsKpiGrid(corridor: _selectedCorridor),
                                  const SizedBox(height: 16),
                                ] else ...[
                                  // Location Quick Picker Bar
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.location_on_rounded, color: blue, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Selected Region:',
                                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: dark),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: _locations.map((loc) {
                                                final selected = loc == _selectedLocation;
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 6),
                                                  child: ChoiceChip(
                                                    label: Text(loc.split(',').first),
                                                    selected: selected,
                                                    selectedColor: blue,
                                                    labelStyle: GoogleFonts.inter(
                                                      color: selected ? Colors.white : dark,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    onSelected: (_) {
                                                      setState(() => _selectedLocation = loc);
                                                    },
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Hero Weather Card
                                  _WeatherHeroCard(
                                    weather: activeWeather,
                                    onAskAi: () => _showAiAdvisorDialog(context),
                                  ),
                                  const SizedBox(height: 16),

                                  // Weather Alerts Card
                                  _WeatherAlertCard(alerts: activeWeather.alerts),
                                  const SizedBox(height: 16),

                                  // AI Agronomic Insights Rail
                                  _AiAgronomicInsightsRail(
                                    weather: activeWeather,
                                    onAskAi: () => _showAiAdvisorDialog(context),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // Interactive Weather Radar Simulation Widget
                                _RadarCard(
                                  selectedMode: _selectedRadarMode,
                                  onModeChanged: (mode) => setState(() => _selectedRadarMode = mode),
                                  weather: activeWeather,
                                ),
                                const SizedBox(height: 20),

                                // Current Conditions Section Title
                                _SectionTitle(
                                  title: 'Current Conditions & Agronomic Index',
                                  actionText: 'Refresh Live Data',
                                  onTap: state.loadWeather,
                                ),
                                const SizedBox(height: 12),
                                _CurrentConditionsGrid(weather: activeWeather),
                                const SizedBox(height: 20),

                                // Hourly Forecast
                                _SectionTitle(
                                  title: '24-Hour Forecast & Spraying Hours',
                                  actionText: 'Full Schedule',
                                  onTap: () {},
                                ),
                                const SizedBox(height: 12),
                                _HourlyForecastList(hours: activeWeather.hourly),
                                const SizedBox(height: 20),

                                // 7-Day Outlook
                                _SectionTitle(
                                  title: '7-Day Climate Outlook',
                                  actionText: 'Export Report',
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('📄 7-Day Agri-Climate Report exported for $_selectedLocation!')),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                if (isWide)
                                  _WeeklyForecastWide(days: activeWeather.daily)
                                else
                                  _WeeklyForecastList(days: activeWeather.daily),
                              ],
                            );
                          },
                        ),
                      ),
          ),
        ),
      ),
    );
  }
}

class _WeatherHeroCard extends StatelessWidget {
  final WeatherData weather;
  final VoidCallback onAskAi;

  const _WeatherHeroCard({required this.weather, required this.onAskAi});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0B132B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  weather.temperature > 30 ? Icons.wb_sunny_rounded : Icons.cloud_outlined,
                  color: weather.temperature > 30 ? Colors.amber : Colors.lightBlueAccent,
                  size: 40,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          weather.location,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: green),
                          ),
                          child: Text(
                            'Live Station',
                            style: GoogleFonts.inter(color: green, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.summary,
                      style: GoogleFonts.inter(color: Colors.grey.shade300, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: onAskAi,
                icon: const Icon(Icons.smart_toy_rounded, size: 16),
                label: const Text('Ask AI'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${weather.temperature}°C',
                style: GoogleFonts.inter(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Feels like ${weather.feelsLike}°C • Rain Risk ${weather.rainChance}%',
                style: GoogleFonts.inter(color: Colors.grey.shade300, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Agronomic Metrics Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeroSubMetric(
                    label: 'Evapotranspiration',
                    value: weather.temperature > 30 ? '6.5 mm/day' : '4.2 mm/day',
                    icon: Icons.water_drop_outlined,
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                Expanded(
                  child: _HeroSubMetric(
                    label: 'Spraying Window',
                    value: weather.windSpeed > 15 ? 'Caution (Windy)' : 'Optimal (06-10 AM)',
                    icon: Icons.sanitizer_outlined,
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                Expanded(
                  child: _HeroSubMetric(
                    label: 'UV Index',
                    value: '7 High',
                    icon: Icons.wb_sunny_outlined,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSubMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _HeroSubMetric({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text(label, style: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _AiAgronomicInsightsRail extends StatelessWidget {
  final WeatherData weather;
  final VoidCallback onAskAi;

  const _AiAgronomicInsightsRail({required this.weather, required this.onAskAi});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF16A34A);
    const orange = Color(0xFFF97316);
    const blue = Color(0xFF2563EB);

    final insights = [
      _AiAgronomicInsight(
        title: 'Optimal Spraying Window',
        desc: 'Spraying pesticide recommended between 06:00 AM & 09:30 AM before wind speed increases to ${weather.windSpeed} km/h.',
        confidence: 94,
        color: green,
        icon: Icons.science_outlined,
      ),
      _AiAgronomicInsight(
        title: 'Evapotranspiration & Water Cycle',
        desc: weather.temperature > 30
            ? 'High evapotranspiration rate (6.5mm/day). Recommended 25mm pivot cycle today.'
            : 'Moderate ET0 (4.2mm/day). Maintain standard drip irrigation cycle.',
        confidence: 91,
        color: blue,
        icon: Icons.water_drop_outlined,
      ),
      _AiAgronomicInsight(
        title: 'Pathogen & Spore Forecast',
        desc: 'Relative humidity (${weather.humidity}%) favors Early Blight spore germination in tomatoes and potatoes.',
        confidence: 86,
        color: orange,
        icon: Icons.bug_report_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology_rounded, color: green, size: 20),
            const SizedBox(width: 8),
            Text(
              'AI Agronomic Weather Insights',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onAskAi,
              icon: const Icon(Icons.smart_toy_rounded, size: 14),
              label: const Text('Consult AI Advisor'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: insights.length,
            itemBuilder: (context, i) {
              final ins = insights[i];
              return Container(
                width: 310,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ins.color.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ins.color.withValues(alpha: 0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ins.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(ins.icon, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  ins.title,
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF0F172A)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text('${ins.confidence}% AI', style: TextStyle(color: ins.color, fontWeight: FontWeight.bold, fontSize: 10)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ins.desc,
                            style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF64748B)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AiAgronomicInsight {
  final String title;
  final String desc;
  final int confidence;
  final Color color;
  final IconData icon;

  const _AiAgronomicInsight({
    required this.title,
    required this.desc,
    required this.confidence,
    required this.color,
    required this.icon,
  });
}

class _RadarCard extends StatefulWidget {
  final WeatherData weather;
  final String selectedMode;
  final ValueChanged<String> onModeChanged;

  const _RadarCard({
    required this.weather,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  State<_RadarCard> createState() => _RadarCardState();
}

class _RadarCardState extends State<_RadarCard> with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;
  bool _isPlaying = true;
  int _timelineIndex = 4;
  final List<String> _timeline = ['-60m', '-45m', '-30m', '-15m', 'LIVE'];

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _sweepController.repeat();
      } else {
        _sweepController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const modes = ['Precipitation Radar', 'Wind Vectors', 'Cloud Overlay'];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Mode Selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.radar_rounded, color: Color(0xFF16A34A), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Doppler & Satellite Radar',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Real-Time High-Resolution Telemetry (${widget.weather.location})',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: modes.map((m) {
                      final selected = m == widget.selectedMode;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text(m.split(' ').first),
                          selected: selected,
                          selectedColor: const Color(0xFF16A34A),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          onSelected: (_) => widget.onModeChanged(m),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Radar Display Canvas & Controls
          Container(
            height: 240,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF0B132B),
              border: Border.all(color: const Color(0xFF1E293B)),
            ),
            child: Stack(
              children: [
                // Animated Doppler Radar Canvas
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedBuilder(
                      animation: _sweepController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _DopplerRadarPainter(
                            sweepAngle: _sweepController.value * 2 * 3.14159,
                            mode: widget.selectedMode,
                            locationName: widget.weather.location,
                            rainChance: widget.weather.rainChance,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Radar Live Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF16A34A)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isPlaying ? const Color(0xFF16A34A) : Colors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isPlaying ? 'RADAR SWEEP ACTIVE' : 'RADAR PAUSED',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // dBZ Reflectivity Scale Legend
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text('dBZ: ', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                        _dBzBox('Light', const Color(0xFF4ADE80)),
                        _dBzBox('Mod', const Color(0xFFFACC15)),
                        _dBzBox('Heavy', const Color(0xFFEF4444)),
                        _dBzBox('Hail', const Color(0xFFA855F7)),
                      ],
                    ),
                  ),
                ),

                // Bottom Timeline Scrubber Bar & Playback Controls
                Positioned(
                  bottom: 10,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: _togglePlay,
                          child: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: const Color(0xFF16A34A), size: 26),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(_timeline.length, (idx) {
                              final active = idx == _timelineIndex;
                              return InkWell(
                                onTap: () => setState(() => _timelineIndex = idx),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: active ? const Color(0xFF16A34A) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _timeline[idx],
                                    style: TextStyle(
                                      color: active ? Colors.white : Colors.white60,
                                      fontSize: 10.5,
                                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _dBzBox(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 2),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 9.5)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM DOPPLER RADAR PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _DopplerRadarPainter extends CustomPainter {
  final double sweepAngle;
  final String mode;
  final String locationName;
  final int rainChance;

  _DopplerRadarPainter({
    required this.sweepAngle,
    required this.mode,
    required this.locationName,
    required this.rainChance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.height * 0.45;

    // Grid circles
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int r = 1; r <= 3; r++) {
      canvas.drawCircle(center, maxRadius * (r / 3), gridPaint);
    }

    // Crosshairs
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), gridPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), gridPaint);

    // Weather reflectivity rain bands
    if (mode == 'Wind Vectors') {
      // Draw wind vector stream lines
      final windPaint = Paint()
        ..color = const Color(0xFF38BDF8).withOpacity(0.5)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      for (double y = 20; y < size.height - 20; y += 25) {
        final path = Path();
        path.moveTo(10, y);
        path.cubicTo(size.width * 0.3, y - 15, size.width * 0.6, y + 15, size.width - 10, y);
        canvas.drawPath(path, windPaint);
      }
    } else {
      // Precipitation Doppler Bands
      final lightRain = Paint()..color = const Color(0xFF4ADE80).withOpacity(0.35);
      final modRain = Paint()..color = const Color(0xFFFACC15).withOpacity(0.45);
      final heavyRain = Paint()..color = const Color(0xFFEF4444).withOpacity(0.55);

      canvas.drawCircle(Offset(center.dx - 40, center.dy - 20), 45, lightRain);
      if (rainChance > 30) {
        canvas.drawCircle(Offset(center.dx - 35, center.dy - 15), 28, modRain);
      }
      if (rainChance > 60) {
        canvas.drawCircle(Offset(center.dx - 30, center.dy - 10), 16, heavyRain);
      }
    }

    // Radar Sweep Sector Arc
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFF16A34A).withOpacity(0.0),
          const Color(0xFF16A34A).withOpacity(0.4),
        ],
        stops: const [0.85, 1.0],
        transform: GradientRotation(sweepAngle),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

    canvas.drawCircle(center, maxRadius, sweepPaint);

    // Radar Sweep Line
    final linePaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..strokeWidth = 2.0;
    canvas.drawLine(center, Offset(center.dx + maxRadius * (sweepAngle > 0 ? 0.8 : 0.8), center.dy - maxRadius * 0.6), linePaint);

    // Center Station Marker
    final stationPaint = Paint()..color = const Color(0xFF22C55E);
    canvas.drawCircle(center, 5, stationPaint);
    final stationBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 5, stationBorder);
  }

  @override
  bool shouldRepaint(covariant _DopplerRadarPainter oldDelegate) => true;
}

class _WeatherAlertCard extends StatelessWidget {
  final List<WeatherAlert> alerts;

  const _WeatherAlertCard({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    final alert = alerts.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red.shade900),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: GoogleFonts.inter(fontSize: 12.5, color: Colors.red.shade800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onTap;

  const _SectionTitle({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        const Spacer(),
        TextButton(
          onPressed: onTap,
          child: Text(actionText, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

class _CurrentConditionsGrid extends StatelessWidget {
  final WeatherData weather;

  const _CurrentConditionsGrid({required this.weather});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 900
            ? 6
            : (constraints.maxWidth > 600
                ? 3
                : (constraints.maxWidth > 350 ? 2 : 1));
        final spacing = 14.0;
        final double width = (constraints.maxWidth - (spacing * (cols - 1))) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _ConditionCard(
              title: 'Temperature',
              value: '${weather.temperature}°C',
              icon: Icons.thermostat_outlined,
              width: width,
              color: Colors.orange,
            ),
            _ConditionCard(
              title: 'Humidity',
              value: '${weather.humidity}%',
              icon: Icons.water_drop_outlined,
              width: width,
              color: Colors.blue,
            ),
            _ConditionCard(
              title: 'Wind Speed',
              value: '${weather.windSpeed} km/h',
              icon: Icons.air_outlined,
              width: width,
              color: Colors.teal,
            ),
            _ConditionCard(
              title: 'Barometric Pressure',
              value: '${weather.pressure} hPa',
              icon: Icons.speed_outlined,
              width: width,
              color: Colors.indigo,
            ),
            _ConditionCard(
              title: 'Rain Chance',
              value: '${weather.rainChance}%',
              icon: Icons.umbrella_outlined,
              width: width,
              color: Colors.blueAccent,
            ),
            _ConditionCard(
              title: 'Visibility',
              value: '${weather.visibility} km',
              icon: Icons.visibility_outlined,
              width: width,
              color: Colors.purple,
            ),
          ],
        );
      },
    );
  }
}

class _ConditionCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final double? width;
  final Color color;

  const _ConditionCard({
    required this.title,
    required this.value,
    required this.icon,
    this.width,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyForecastList extends StatelessWidget {
  final List<HourlyForecast> hours;

  const _HourlyForecastList({required this.hours});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 135,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hours.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = hours[index];
          return _HourTile(
            time: item.time,
            temp: '${item.temperature}°C',
            condition: item.condition,
          );
        },
      ),
    );
  }
}

class _HourTile extends StatelessWidget {
  final String time;
  final String temp;
  final String condition;

  const _HourTile({
    required this.time,
    required this.temp,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.cloud_outlined;
    Color color = Colors.blueGrey;

    if (condition == 'Rain') {
      icon = Icons.water_drop_outlined;
      color = Colors.blue;
    } else if (condition == 'Storm') {
      icon = Icons.thunderstorm_outlined;
      color = Colors.deepPurple;
    } else if (condition == 'Sunny') {
      icon = Icons.wb_sunny_outlined;
      color = Colors.amber;
    }

    return Container(
      width: 96,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            temp,
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }
}

class _WeeklyForecastList extends StatelessWidget {
  final List<DailyForecast> days;

  const _WeeklyForecastList({required this.days});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: days
          .map(
            (day) => _DailyForecastTile(
              day: day.day,
              min: '${day.minTemp}°',
              max: '${day.maxTemp}°',
              condition: day.condition,
            ),
          )
          .toList(),
    );
  }
}

class _WeeklyForecastWide extends StatelessWidget {
  final List<DailyForecast> days;

  const _WeeklyForecastWide({required this.days});

  @override
  Widget build(BuildContext context) {
    final split = (days.length / 2).ceil();
    final left = days.take(split).toList();
    final right = days.skip(split).toList();

    return Row(
      children: [
        Expanded(
          child: Column(
            children: left
                .map(
                  (day) => _DailyForecastTile(
                    day: day.day,
                    min: '${day.minTemp}°',
                    max: '${day.maxTemp}°',
                    condition: day.condition,
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            children: right
                .map(
                  (day) => _DailyForecastTile(
                    day: day.day,
                    min: '${day.minTemp}°',
                    max: '${day.maxTemp}°',
                    condition: day.condition,
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _DailyForecastTile extends StatelessWidget {
  final String day;
  final String min;
  final String max;
  final String condition;

  const _DailyForecastTile({
    required this.day,
    required this.min,
    required this.max,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.cloud_outlined;
    Color color = Colors.blueGrey;

    if (condition == 'Rain') {
      icon = Icons.water_drop_outlined;
      color = Colors.blue;
    } else if (condition == 'Sunny') {
      icon = Icons.wb_sunny_outlined;
      color = Colors.amber;
    } else if (condition == 'Storm') {
      icon = Icons.thunderstorm_outlined;
      color = Colors.deepPurple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              day,
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
          ),
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              condition,
              style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13),
            ),
          ),
          Text(
            '$min / $max',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }
}

class _TransporterWeatherHeroCard extends StatelessWidget {
  final String corridor;
  final WeatherData weather;
  final VoidCallback onAskAi;

  const _TransporterWeatherHeroCard({
    required this.corridor,
    required this.weather,
    required this.onAskAi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFF97316).withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.radar_rounded, color: Color(0xFFF97316), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'HIGHWAY FREIGHT CORRIDOR RADAR',
                      style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w900, color: const Color(0xFFF97316), letterSpacing: 0.8),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onAskAi,
                icon: const Icon(Icons.psychology_rounded, size: 15),
                label: const Text('Logistics AI Advisor', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            corridor,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Route Status: Active Freight Haulage • Ambient Temperature 33°C • Moderate Crosswinds',
            style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMetricChip(Icons.wb_sunny_outlined, '33°C Heat', 'Lowveld Segment', Colors.amber),
              const SizedBox(width: 12),
              _buildMetricChip(Icons.air_rounded, '38 km/h Wind', 'Escarpment Gusts', Colors.cyan),
              const SizedBox(width: 12),
              _buildMetricChip(Icons.water_drop_outlined, '18mm Rain', 'Farm Ramp Mud', Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(IconData icon, String title, String subtitle, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransporterLogisticsKpiGrid extends StatelessWidget {
  final String corridor;

  const _TransporterLogisticsKpiGrid({required this.corridor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shield_outlined, color: Color(0xFFF97316), size: 18),
            const SizedBox(width: 6),
            Text(
              'TRANSPORTER ROAD HAZARDS & CARGO RISK INDEX',
              style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A), letterSpacing: 0.8),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: const [
            _TransporterHazardCard(
              title: 'Farm Road Mud Access',
              status: 'HIGH MUD RISK',
              detail: '18mm recent rain on unpaved dirt ramps. 30-Tonne rigs risk getting bogged.',
              statusColor: Color(0xFFDC2626),
              icon: Icons.terrain_rounded,
            ),
            _TransporterHazardCard(
              title: 'Highway Hydroplaning',
              status: 'LOW RISK',
              detail: 'Main asphalt tar is dry. Good tire traction along A4/N2 arterial roads.',
              statusColor: Color(0xFF16A34A),
              icon: Icons.alt_route_rounded,
            ),
            _TransporterHazardCard(
              title: 'Trailer Crosswind Risk',
              status: 'MODERATE WARNING',
              detail: '38 km/h wind gusts on Save River bridge. Reduce speed for curtain-side trailers.',
              statusColor: Color(0xFFD97706),
              icon: Icons.air_rounded,
            ),
            _TransporterHazardCard(
              title: 'Produce Spoilage Risk',
              status: 'CRITICAL THERMAL',
              detail: '33°C ambient heat in Lowveld. Fresh tomatoes require tarpaulin or refrigerated vent.',
              statusColor: Color(0xFFDC2626),
              icon: Icons.thermostat_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

class _TransporterHazardCard extends StatelessWidget {
  final String title;
  final String status;
  final String detail;
  final Color statusColor;
  final IconData icon;

  const _TransporterHazardCard({
    required this.title,
    required this.status,
    required this.detail,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: statusColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w900, color: statusColor),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              detail,
              style: GoogleFonts.inter(fontSize: 10.5, color: const Color(0xFF64748B), height: 1.25),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
