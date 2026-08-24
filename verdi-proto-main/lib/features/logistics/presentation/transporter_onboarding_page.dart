import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/supabase_service.dart';
import '../../../state/platform_data_state.dart';
import '../data/agri_logistics_models.dart';
import '../state/agri_logistics_state.dart';

/// 3-Step Carrier Onboarding & Fleet Registration Wizard
class TransporterOnboardingPage extends ConsumerStatefulWidget {
  final VoidCallback onCompleted;
  const TransporterOnboardingPage({super.key, required this.onCompleted});

  @override
  ConsumerState<TransporterOnboardingPage> createState() => _TransporterOnboardingPageState();
}

class _TransporterOnboardingPageState extends ConsumerState<TransporterOnboardingPage> {
  static const bgDark = Color(0xFF060B14);
  static const cardDark = Color(0xFF0D1626);
  static const cardBorder = Color(0xFF1E293B);
  static const amber = Color(0xFFFF9F1C);
  static const cyan = Color(0xFF00F0FF);
  static const green = Color(0xFF10B981);
  static const textMuted = Color(0xFF94A3B8);

  int _currentStep = 0;

  // Step 1 Controllers
  final _carrierNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  LogisticsTier _selectedTier = LogisticsTier.longDistance;

  // Step 2 Controllers
  VehicleType _selectedVehicleType = VehicleType.reeferContainer;
  final _plateCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  bool _hasColdChain = true;

  // Step 3 Controllers
  final _licenseCtrl = TextEditingController();
  final _eudrPermitCtrl = TextEditingController();
  bool _agreedToTerms = true;

  @override
  void dispose() {
    _carrierNameCtrl.dispose();
    _phoneCtrl.dispose();
    _plateCtrl.dispose();
    _capacityCtrl.dispose();
    _licenseCtrl.dispose();
    _eudrPermitCtrl.dispose();
    super.dispose();
  }

  void _submitOnboarding() {
    final carrierProfile = CarrierProfile(
      id: 'CAR-ZIM-${DateTime.now().millisecondsSinceEpoch % 10000}',
      carrierName: _carrierNameCtrl.text.trim().isEmpty ? 'Verdi Sovereign Carrier' : _carrierNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isEmpty ? '+263 77 000 0000' : _phoneCtrl.text.trim(),
      email: '${_carrierNameCtrl.text.trim().toLowerCase().replaceAll(' ', '')}@verdi.ag',
      operatingTier: _selectedTier,
      vehicle: AgriVehicle(
        id: 'VEH-${DateTime.now().millisecondsSinceEpoch % 1000}',
        ownerId: 'CAR-ZIM-01',
        registrationNumber: _plateCtrl.text.trim().isEmpty ? 'AEB-2910' : _plateCtrl.text.trim(),
        type: _selectedVehicleType,
        tierCapability: _selectedTier,
        maxWeightCapacityKg: double.tryParse(_capacityCtrl.text.trim()) ?? 30000.0,
        hasColdChain: _hasColdChain,
        model: _selectedVehicleType == VehicleType.reeferContainer ? 'Volvo FH16 Reefer' : 'Isuzu NPR Utility',
      ),
      isVerifiedBadge: true,
      completedTripsCount: 20,
      rating: 5.0,
      dutyStatus: CarrierDutyStatus.available,
      walletBalance: 0.0,
      eudrPermitCode: _eudrPermitCtrl.text.trim().isEmpty ? 'EUDR-LOG-ZIM-2026-88' : _eudrPermitCtrl.text.trim(),
    );

    // Save profile to state
    ref.read(agriLogisticsProvider.notifier).updateCarrierProfile(carrierProfile);
    ref.read(agriLogisticsProvider.notifier).awardVerifiedBadge(true);

    // Sync newly registered vehicle across platform (NearbyTransportPanel, Marketplace, Farmers & Buyers)
    final truckItem = TruckItem(
      id: 'truck-${carrierProfile.vehicle.id}',
      driver: carrierProfile.carrierName,
      vehicle: '${carrierProfile.vehicle.type.label} (${(carrierProfile.vehicle.maxWeightCapacityKg / 1000).toStringAsFixed(1)}T)',
      plateNumber: carrierProfile.vehicle.registrationNumber,
      regNumber: carrierProfile.eudrPermitCode,
      color: 'Fleet White',
      model: carrierProfile.vehicle.model,
      from: 'Live Dispatch Corridor',
      eta: 'Available Now',
      costPerKm: carrierProfile.operatingTier == LogisticsTier.shortTrip ? 0.12 : 0.35,
      rating: 5.0,
      status: 'Ready for dispatch',
    );
    ref.read(trucksListProvider.notifier).addTruck(truckItem);

    // Broadcast to Supabase
    SupabaseService.instance.insertRecord('verdi_vehicles', {
      'id': carrierProfile.vehicle.id,
      'driver_name': carrierProfile.carrierName,
      'plate_number': carrierProfile.vehicle.registrationNumber,
      'type': carrierProfile.vehicle.type.name,
      'has_cold_chain': carrierProfile.vehicle.hasColdChain,
      'capacity_kg': carrierProfile.vehicle.maxWeightCapacityKg,
      'status': 'ACTIVE',
    });

    widget.onCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: cardDark,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.app_registration_rounded, color: amber, size: 20),
            const SizedBox(width: 10),
            Text('Carrier Fleet Onboarding', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step Progress Indicator
                _buildProgressHeader(),
                const SizedBox(height: 24),

                // Active Step Content
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cardBorder),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: _buildCurrentStepContent(),
                ),
                const SizedBox(height: 24),

                // Navigation Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentStep > 0)
                      OutlinedButton.icon(
                        onPressed: () => setState(() => _currentStep--),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Back'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textMuted,
                          side: const BorderSide(color: cardBorder),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_currentStep < 2) {
                          setState(() => _currentStep++);
                        } else {
                          _submitOnboarding();
                        }
                      },
                      icon: Icon(_currentStep == 2 ? Icons.check_circle_outline : Icons.arrow_forward, size: 18),
                      label: Text(
                        _currentStep == 2 ? 'Launch Carrier OS' : 'Proceed to Step ${_currentStep + 2}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: amber,
                        foregroundColor: bgDark,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Row(
      children: [
        _stepCircle(0, '1. Profile & Tiers'),
        Expanded(child: Container(height: 2, color: _currentStep >= 1 ? amber : cardBorder)),
        _stepCircle(1, '2. Asset & Reefer'),
        Expanded(child: Container(height: 2, color: _currentStep >= 2 ? amber : cardBorder)),
        _stepCircle(2, '3. EUDR & Clearance'),
      ],
    );
  }

  Widget _stepCircle(int step, String label) {
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;

    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: isDone ? green : (isActive ? amber : cardDark),
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text('${step + 1}', style: TextStyle(color: isActive ? bgDark : textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? Colors.white : textMuted, fontSize: 10.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Profile();
      case 1:
        return _buildStep2VehicleAsset();
      case 2:
        return _buildStep3Clearance();
      default:
        return const SizedBox.shrink();
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 1: CARRIER IDENTITY & OPERATING TIER
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep1Profile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 1: Carrier Identity & Operating Tier', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Configure your carrier entity and choose your primary agricultural logistics domain.', style: TextStyle(fontSize: 12, color: textMuted)),
        const SizedBox(height: 20),

        _inputField('Carrier / Fleet Business Name', _carrierNameCtrl, Icons.business_outlined, hint: 'e.g. Chinhoyi Heavy Haulage Ltd'),
        const SizedBox(height: 14),
        _inputField('Dispatch Contact Phone', _phoneCtrl, Icons.phone_outlined, hint: 'e.g. +263 77 902 1140', keyboardType: TextInputType.phone),
        const SizedBox(height: 20),

        Text('Primary Operating Tier', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _tierOptionCard(
                LogisticsTier.shortTrip,
                'Hyper-Local Short-Trip',
                'Farmgate-to-hub aggregation (< 50 km) via small trucks, trikes & bikes.',
                Icons.electric_rickshaw_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _tierOptionCard(
                LogisticsTier.longDistance,
                'Long-Distance Bulk',
                'Multi-tonne inter-provincial & cold-chain refrigerated bulk haulage.',
                Icons.fire_truck_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tierOptionCard(LogisticsTier tier, String title, String desc, IconData icon) {
    final isSelected = _selectedTier == tier;
    return InkWell(
      onTap: () => setState(() => _selectedTier = tier),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? amber.withOpacity(0.12) : const Color(0xFF070B12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? amber : cardBorder, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? amber : textMuted, size: 22),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 11, color: textMuted, height: 1.3)),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 2: VEHICLE & REEFER ASSET SETUP
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep2VehicleAsset() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 2: Fleet Asset & Cold-Chain Telemetry', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Register your vehicle specifications and cold-chain monitoring hardware.', style: TextStyle(fontSize: 12, color: textMuted)),
        const SizedBox(height: 20),

        Text('Vehicle Classification', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        DropdownButtonFormField<VehicleType>(
          value: _selectedVehicleType,
          dropdownColor: cardDark,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          items: VehicleType.values.map((v) => DropdownMenuItem(value: v, child: Text(v.label))).toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedVehicleType = val;
                if (val == VehicleType.reeferContainer) _hasColdChain = true;
              });
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF070B12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cardBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cardBorder)),
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(child: _inputField('Vehicle Plate / SADC Reg', _plateCtrl, Icons.badge_outlined, hint: 'e.g. AEB-2910')),
            const SizedBox(width: 12),
            Expanded(child: _inputField('Max Weight Payload (kg)', _capacityCtrl, Icons.scale_outlined, hint: 'e.g. 30000', keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 16),

        // Cold-Chain Switch
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF070B12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _hasColdChain ? cyan.withOpacity(0.4) : cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.ac_unit_outlined, color: cyan, size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cold-Chain Reefer Sensor Active', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                    Text('Transmits real-time temperature logs (+2°C to +6°C) to smart contract escrow.', style: TextStyle(color: textMuted, fontSize: 11)),
                  ],
                ),
              ),
              Switch(
                value: _hasColdChain,
                activeColor: cyan,
                onChanged: (v) => setState(() => _hasColdChain = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 3: CLEARANCE & EUDR DECLARATION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStep3Clearance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Step 3: Driver License & EUDR Provenance Clearance', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        const Text('Confirm regulatory compliance for cross-border corridor access and verified badge eligibility.', style: TextStyle(fontSize: 12, color: textMuted)),
        const SizedBox(height: 20),

        _inputField('Driver Commercial License ID', _licenseCtrl, Icons.credit_card_outlined, hint: 'e.g. DL-ZIM-2026-99120'),
        const SizedBox(height: 14),
        _inputField('EUDR Carrier Provenance Permit', _eudrPermitCtrl, Icons.verified_user_outlined, hint: 'e.g. EUDR-LOG-ZIM-2026-88'),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: amber.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: amber.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.military_tech_outlined, color: amber, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sovereign Verified Carrier Status', style: TextStyle(fontWeight: FontWeight.bold, color: amber, fontSize: 13)),
                    Text('You will be eligible for instant Escrow payouts and preferential marketplace dispatch matching.', style: TextStyle(color: textMuted, fontSize: 11)),
                  ],
                ),
              ),
              Checkbox(
                value: _agreedToTerms,
                activeColor: amber,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _inputField(String label, TextEditingController ctrl, IconData icon, {String? hint, TextInputType? keyboardType}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: textMuted, fontSize: 12),
        hintText: hint,
        hintStyle: TextStyle(color: textMuted.withOpacity(0.35), fontSize: 12),
        prefixIcon: Icon(icon, color: amber, size: 18),
        filled: true,
        fillColor: const Color(0xFF070B12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: amber)),
      ),
    );
  }
}
