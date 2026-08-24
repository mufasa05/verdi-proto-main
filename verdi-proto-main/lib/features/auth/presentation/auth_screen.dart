import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../state/app_state.dart';
import '../state/auth_state.dart';
import '../../../widgets/verdi_logo.dart';
import '../../agri_expert/data/agri_expert_models.dart';
import '../../agri_expert/state/agri_expert_state.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Tenant Details
  final _companyController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  String _selectedCountry = 'Zimbabwe';
  bool _createNewTenant = true;
  bool _obscurePassword = true;

  bool _isPhoneInput(String input) {
    final clean = input.trim();
    if (clean.contains('@')) return false;
    return RegExp(r'^\+?[0-9\s\-]{7,15}$').hasMatch(clean);
  }

  bool _isValidInput(String input) {
    final clean = input.trim();
    if (clean.isEmpty) return false;
    if (clean.contains('@')) {
      return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(clean);
    }
    return RegExp(r'^\+?[0-9\s\-]{7,15}$').hasMatch(clean);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final email = await ref.read(authStateProvider.notifier).getLastEmail();
      if (!mounted) return;
      if (email != null && email.isNotEmpty) {
        setState(() {
          _emailController.text = email;
        });
      }
    });
  }

  // Step Management
  // 0: Welcome Splash
  // 1: Sign In / Sign Up Credentials
  // 2: Stakeholder Selector Grid
  // 3: Company Tenant Setup
  // 4: Access Control Module Preview
  // 5: Final Onboarding Completion
  int _currentStep = 0;
  bool _isSignUp = false;
  UserRole _selectedRole = UserRole.farmer;

  // Agri-Expert specific onboarding state
  ExpertPersona _selectedExpertPersona = ExpertPersona.independentConsultant;
  final _practiceOrOrgNameCtrl = TextEditingController();
  final _licenseOrStaffIdCtrl = TextEditingController();
  final _districtOrStationCtrl = TextEditingController();
  final _hourlyRateCtrl = TextEditingController();
  final _visitRateCtrl = TextEditingController();
  final _retainerRateCtrl = TextEditingController();
  final _expertBioCtrl = TextEditingController();
  final _specializationsCtrl = TextEditingController();

  final List<String> _countries = [
    'Zimbabwe',
    'South Africa',
    'Zambia',
    'Kenya',
    'Mozambique',
    'Malawi',
    'Nigeria',
    'Ghana',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _companyController.dispose();
    _inviteCodeController.dispose();
    _practiceOrOrgNameCtrl.dispose();
    _licenseOrStaffIdCtrl.dispose();
    _districtOrStationCtrl.dispose();
    _hourlyRateCtrl.dispose();
    _visitRateCtrl.dispose();
    _retainerRateCtrl.dispose();
    _expertBioCtrl.dispose();
    _specializationsCtrl.dispose();
    super.dispose();
  }

  void _showSmsOtpDialog({required String phone, required Future<void> Function() onVerified}) {
    final otpController = TextEditingController();
    final String simulatedOtp = '482910';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📱 SMS Inbox: Your Verdi OTP verification code for $phone is $simulatedOtp'),
        backgroundColor: const Color(0xFF16A34A),
        duration: const Duration(seconds: 6),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.sms_outlined, color: Color(0xFF16A34A)),
              SizedBox(width: 8),
              Text('SMS OTP Verification'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'A 6-digit confirmation code was sent via SMS to $phone. Enter the code below to verify device ownership.',
                style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 6),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: '6-Digit OTP Code',
                  hintText: 'e.g. 482910',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (otpController.text.trim() == simulatedOtp) {
                  Navigator.pop(context);
                  await onVerified();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid SMS OTP code. Please enter 482910.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Verify & Proceed'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final input = _emailController.text.trim();
    final isPhone = _isPhoneInput(input);
    final notifier = ref.read(authStateProvider.notifier);

    if (!_isSignUp) {
      // Sign in logic
      Future<void> doSignIn() async {
        final success = await notifier.signIn(
          emailOrPhone: input,
          password: _passwordController.text,
        );
        if (!mounted) return;
        if (!success) {
          final err = ref.read(authStateProvider).errorMessage ?? 'Invalid credentials.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err), backgroundColor: const Color(0xFFEF4444)),
          );
        }
      }

      if (isPhone) {
        _showSmsOtpDialog(phone: input, onVerified: doSignIn);
      } else {
        await doSignIn();
      }
    } else {
      // Proceed to Stakeholder selector step
      if (isPhone) {
        _showSmsOtpDialog(
          phone: input,
          onVerified: () async {
            setState(() {
              _currentStep = 2;
            });
          },
        );
      } else {
        setState(() {
          _currentStep = 2;
        });
      }
    }
  }

  void _showAdminPasskeyDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Admin Console Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your special creator access key:'),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              obscureText: true,
              autofillHints: const [],
              decoration: InputDecoration(
                hintText: 'Admin Passkey',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final key = controller.text.trim();
              if (key == 'Mufasa05?') {
                Navigator.pop(context);
                final adminUser = AppUser(
                  id: 'admin_creator',
                  fullName: 'Verdi Creator',
                  email: 'creator@verdi.ag',
                  role: UserRole.admin,
                );

                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('verdi.auth.session', jsonEncode(adminUser.toJson()));
                await prefs.setString('verdi.auth.token', 'creator_token_2026');

                final isDemo = ref.read(isDemoModeProvider);
                ref.read(appStateProvider.notifier).setDemoMode(isDemo);
                ref.read(appStateProvider.notifier).setRole(UserRole.admin);
                
                ref.read(authStateProvider.notifier).authenticateUser(adminUser);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid Admin Passkey. Access key must be Mufasa05?'), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
            child: const Text('Access'),
          ),
        ],
      ),
    );
  }

  void _showDemoRolePickerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
        title: Row(
          children: const [
            Icon(Icons.flash_on, color: Color(0xFFF59E0B), size: 24),
            SizedBox(width: 8),
            Text(
              'Launch Offline Demo Mode',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select any stakeholder role to experience its fully-populated demo cockpit with live mock telemetry:',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                ),
                const SizedBox(height: 14),
                ...UserRole.values.where((r) => r != UserRole.admin).map((role) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF16A34A).withOpacity(0.2),
                        child: Icon(role.icon, color: const Color(0xFF16A34A), size: 20),
                      ),
                      title: Text(
                        role.label,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        'Demo ${role.categoryTag} workspace with live mock telemetry',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (role == UserRole.expert) {
                          _showExpertPersonaDemoPicker();
                        } else {
                          ref.read(authStateProvider.notifier).enterOfflineDemoMode(
                            email: '${role.name}@demo.verdi.co',
                            fullName: 'Demo User',
                            role: role,
                          );
                        }
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }

  void _showExpertPersonaDemoPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
        title: const Text(
          'Select Agri-Expert Demo Persona',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ExpertPersona.values.map((p) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.color.withOpacity(0.5)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: p.color.withOpacity(0.2),
                child: Icon(p.icon, color: p.color, size: 20),
              ),
              title: Text(
                p.label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              subtitle: Text(
                p.badgeTitle,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(authStateProvider.notifier).enterOfflineDemoMode(
                  email: 'dr.nyasha.expert@demo.verdi.co',
                  fullName: 'Demo User',
                  role: UserRole.expert,
                  expertPersona: p,
                );
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  // ignore: unused_element
  void _showConnectionFailedDialog({String? email, String? fullName, UserRole? role}) {
    final notifier = ref.read(authStateProvider.notifier);
    final ipController = TextEditingController(text: notifier.currentBaseUrl);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.cloud_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Server Unreachable'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We were unable to establish a connection with the backend API.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Current Backend URL: ${notifier.currentBaseUrl}'),
            const SizedBox(height: 16),
            const Text('Configure Custom Backend Server IP/URL:'),
            const SizedBox(height: 6),
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                hintText: 'http://192.168.1.100:3000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.enterOfflineDemoMode(
                email: email ?? _emailController.text,
                fullName: fullName ?? _nameController.text,
                role: role ?? _selectedRole,
              );
              _showToast('Offline Demo Mode Activated.');
            },
            child: const Text('Offline Demo Mode'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUrl = ipController.text.trim();
              Navigator.pop(context);
              if (newUrl.isNotEmpty) {
                await notifier.setCustomBaseUrl(newUrl);
                _showToast('Backend URL updated. Please try again.');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update & Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _finishSignUp() async {
    final notifier = ref.read(authStateProvider.notifier);
    final success = await notifier.signUp(
      fullName: _nameController.text.trim(),
      emailOrPhone: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );

    if (!mounted) return;
    if (success) {
      setState(() {
        _currentStep = 5;
      });
    } else {
      final err = ref.read(authStateProvider).errorMessage ?? 'Unable to complete sign up.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _showToast(String msg) {
    // Suppressed unnecessary button-click toast popups
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Background Wash with Visual Photo Depth
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/agriculture_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.60),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Subtle Ambient Glow Orbs
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16A34A).withValues(alpha: 0.25),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.2),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: anim.drive(
                          Tween<Offset>(
                            begin: const Offset(0.05, 0.0),
                            end: Offset.zero,
                          ),
                        ),
                        child: child,
                      ),
                    ),
                    child: _buildCurrentStepWidget(authState),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({
    required Widget child,
    Key? key,
    EdgeInsetsGeometry padding = const EdgeInsets.all(28.0),
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Theme(
              data: ThemeData.dark().copyWith(
                primaryColor: const Color(0xFF16A34A),
                scaffoldBackgroundColor: Colors.transparent,
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.25),
                  labelStyle: const TextStyle(color: Colors.white70, fontSize: 13.5),
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIconColor: Colors.white70,
                  suffixIconColor: Colors.white70,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF4ADE80), width: 1.8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                ),
              ),
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepWidget(AuthState authState) {
    switch (_currentStep) {
      case 0:
        return _buildWelcomeStep();
      case 1:
        return _buildCredentialsStep(authState);
      case 2:
        return _buildStakeholderSelectorStep();
      case 21:
        return _buildExpertPersonaSelectionStep();
      case 22:
        return _buildExpertCredentialsAndBioStep();
      case 3:
        return _buildCompanyTenantStep();
      case 4:
        return _buildAccessPreviewStep();
      case 5:
        return _buildCompleteOnboardingStep();
      default:
        return _buildWelcomeStep();
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 0: WELCOME LANDING
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildWelcomeStep() {
    return _buildGlassCard(
      key: const ValueKey('welcome_step'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const VerdiLogo(size: 80),
          const SizedBox(height: 24),
          Text(
            'Smart Agriculture Command Center',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Precision irrigation, multispectral satellite imagery, marketplace trading & drone fleet command.',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white70, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentStep = 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 18),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(appStateProvider.notifier).setDemoMode(true);
                  _showDemoRolePickerDialog();
                },
                icon: const Icon(Icons.flash_on, color: Colors.white, size: 18),
                label: const Text('Offline Demo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 1: CREDENTIALS (SIGN IN / SIGN UP)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCredentialsStep(AuthState authState) {
    return _buildGlassCard(
      key: const ValueKey('credentials_step'),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isSignUp ? 'Create your account' : 'Welcome back',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isSignUp
                  ? 'Enter your details to create an account'
                  : 'Sign in to access your platform dashboard.',
              style: const TextStyle(color: Colors.white70, fontSize: 13.5),
            ),
            const SizedBox(height: 24),
            if (_isSignUp) ...[
              TextFormField(
                controller: _nameController,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter your full name'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your email or phone number';
                }
                if (!_isValidInput(value)) {
                  return 'Enter a valid email (user@verdi.ag) or phone number (+263...)';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Email Address or Phone Number',
                hintText: 'user@verdi.ag or +263771234567',
                prefixIcon: const Icon(Icons.contact_mail_outlined, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [],
              validator: (value) => (value == null || value.length < 6)
                  ? 'Use at least 6 characters'
                  : null,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF64748B),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            _buildModeSelectorTile(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: authState.isLoading ? null : _submitAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isSignUp ? 'Next: Choose Stakeholder Role' : 'Sign In', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _isSignUp = !_isSignUp),
              child: Text(
                _isSignUp
                    ? 'Already have an account? Sign in'
                    : 'New to Verdi? Create an account',
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _showDemoRolePickerDialog,
                  icon: const Icon(Icons.flash_on_outlined, size: 16, color: Color(0xFF16A34A)),
                  label: const Text('Launch Offline Demo Mode', style: TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                TextButton.icon(
                  onPressed: _showAdminPasskeyDialog,
                  icon: const Icon(Icons.admin_panel_settings_outlined, size: 16, color: Color(0xFF64748B)),
                  label: const Text('Admin Access', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelectorTile() {
    final isDemoMode = ref.watch(isDemoModeProvider);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          // Segment 1: Live Real Mode
          Expanded(
            child: InkWell(
              onTap: () => ref.read(appStateProvider.notifier).setDemoMode(false),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: !isDemoMode ? const Color(0xFF10B981) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isDemoMode
                      ? [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: !isDemoMode ? Colors.white : Colors.white38,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live Real Mode',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: !isDemoMode ? FontWeight.w800 : FontWeight.w600,
                        color: !isDemoMode ? Colors.white : Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Segment 2: Offline Demo Mode
          Expanded(
            child: InkWell(
              onTap: () {
                ref.read(appStateProvider.notifier).setDemoMode(true);
                _showDemoRolePickerDialog();
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: isDemoMode ? const Color(0xFFF59E0B) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isDemoMode
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 13,
                      color: isDemoMode ? Colors.white : Colors.white38,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Offline Demo',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: isDemoMode ? FontWeight.w800 : FontWeight.w600,
                        color: isDemoMode ? Colors.white : Colors.white60,
                      ),
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

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 2: STAKEHOLDER SELECTOR GRID
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStakeholderSelectorStep() {
    return _buildGlassCard(
      key: const ValueKey('stakeholder_step'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _currentStep = 1),
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Stakeholder Role',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                'Select your primary function in the value chain. This defines your active workspace module bundle.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 340,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: UserRole.values.where((r) => r != UserRole.admin).length,
                itemBuilder: (context, index) {
                  final role = UserRole.values.where((r) => r != UserRole.admin).toList()[index];
                  final isSelected = _selectedRole == role;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedRole = role;
                        });
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF16A34A).withOpacity(0.08) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF16A34A) : Colors.black12,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(role.icon, color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF64748B), size: 28),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        role.label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(role.categoryTag, style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    role.description,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_selectedRole == UserRole.expert) {
                  setState(() {
                    _currentStep = 21;
                  });
                } else {
                  setState(() {
                    _currentStep = 4;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _selectedRole == UserRole.expert ? 'Next: Select Expert Persona' : 'Next: Preview Workspace',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 2A: AGRI-EXPERT PERSONA SELECTION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildExpertPersonaSelectionStep() {
    return _buildGlassCard(
      key: const ValueKey('expert_persona_step'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _currentStep = 2),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agri-Expert Persona',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Select your primary operating classification',
                      style: TextStyle(fontSize: 12.5, color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Immutable Lock Warning Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.lock_clock_outlined, color: Color(0xFFD97706), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Important: Your persona classification is permanent and immutable once selected. You cannot switch freely in-app without submitting a formal verification inquiry.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF92400E), height: 1.4, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...ExpertPersona.values.map((persona) {
            final isSelected = _selectedExpertPersona == persona;
            String subtitle = '';
            List<String> tags = [];

            switch (persona) {
              case ExpertPersona.independentConsultant:
                subtitle = 'Private agronomy consultant, independent soil lab, or freelance crop specialist. Bill clients, set custom advisory rates, and publish whitelabel reports.';
                tags = ['Private Billing', 'Client CRM', 'Whitelabel Export', 'Open Marketplace'];
                break;
              case ExpertPersona.governmentExtension:
                subtitle = 'Ministry of Agriculture / Agritex extension officer. Manage geofenced rural territories, offline surveys, and state emergency SMS broadcasts.';
                tags = ['State Verified', 'Agritex Sync', 'Offline Forms', 'Emergency SMS'];
                break;
              case ExpertPersona.companyAgronomist:
                subtitle = 'Internal agronomist for contract farming / agribusiness (SeedCo, Delta, Olivine). Air-gapped data firewall, outgrower dispatch SLAs, and input warehouse syncing.';
                tags = ['Air-Gapped Firewall', 'Outgrower SLAs', 'Corporate SKU Match'];
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _selectedExpertPersona = persona),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? persona.color.withOpacity(0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? persona.color : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: persona.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(persona.icon, color: persona.color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    persona.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: persona.color, size: 20),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.35),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: tags.map((t) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(t, style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _currentStep = 22;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedExpertPersona.color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Next: Professional Credentials & Bio', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 2B: TAILORED CREDENTIALS & BIO FORM
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildExpertCredentialsAndBioStep() {
    final persona = _selectedExpertPersona;

    return _buildGlassCard(
      key: const ValueKey('expert_credentials_step'),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => setState(() => _currentStep = 21),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${persona.label} Profile',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Provide your professional credentials and practice details',
                      style: const TextStyle(fontSize: 12.5, color: Colors.white70, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 380),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form fields customized by persona
                  if (persona == ExpertPersona.independentConsultant) ...[
                    TextFormField(
                      controller: _practiceOrOrgNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Practice / Lab Name (Optional)',
                        hintText: 'e.g. Sovereign Agronomy & Soil Solutions',
                        hintStyle: TextStyle(color: Colors.black26),
                        prefixIcon: Icon(Icons.business_center_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _licenseOrStaffIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ZAPB Professional License No.',
                        hintText: 'e.g. ZAPB-LIC-2024-089',
                        hintStyle: TextStyle(color: Colors.black26),
                        prefixIcon: Icon(Icons.verified_user_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hourlyRateCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Hourly Rate (USD)',
                              hintText: 'e.g. 45.00',
                              hintStyle: TextStyle(color: Colors.black26),
                              prefixText: '\$ ',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _visitRateCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Farm Visit (USD)',
                              hintText: 'e.g. 120.00',
                              hintStyle: TextStyle(color: Colors.black26),
                              prefixText: '\$ ',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (persona == ExpertPersona.governmentExtension) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.verified, color: Color(0xFF2563EB), size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'State Accreditation: All registered Agritex Extension Officers receive the official "Verified by State" trust badge.',
                              style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _licenseOrStaffIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Agritex Officer Service ID',
                        hintText: 'e.g. AGX-ZW-2026-9041',
                        hintStyle: TextStyle(color: Colors.black26),
                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _districtOrStationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Assigned District & Ward Territory',
                        hintText: 'e.g. Mazowe District (Ward 4 & 5)',
                        hintStyle: TextStyle(color: Colors.black26),
                        prefixIcon: Icon(Icons.map_outlined, size: 20),
                      ),
                    ),
                  ] else ...[
                    // Corporate Agronomist
                    TextFormField(
                      controller: _practiceOrOrgNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Agribusiness / Corporate Employer',
                        hintText: 'e.g. SeedCo, Delta Outgrower Scheme, Tanganda',
                        hintStyle: TextStyle(color: Colors.black26),
                        prefixIcon: Icon(Icons.domain_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _licenseOrStaffIdCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Corporate Employee / Staff ID',
                        hintText: 'e.g. SC-AGR-4491',
                        hintStyle: TextStyle(color: Colors.black26),
                        prefixIcon: Icon(Icons.badge_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _districtOrStationCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Scheme Block / Depot',
                        hintText: 'e.g. Banket Malt Barley Contract Scheme',
                        hintStyle: TextStyle(color: Colors.black26),
                        prefixIcon: Icon(Icons.warehouse_outlined, size: 20),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _specializationsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Specialization Domains',
                      hintText: 'e.g. Soil Chemistry, Pest Management, Drip Irrigation',
                      hintStyle: TextStyle(color: Colors.black26),
                      prefixIcon: Icon(Icons.psychology_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _expertBioCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Professional Bio & Experience Summary',
                      hintText: 'Outline your agricultural advisory background and credentials...',
                      hintStyle: TextStyle(color: Colors.black26),
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Commit persona to state
              ref.read(appStateProvider.notifier).setExpertPersona(persona);

              // Update custom profile values if provided
              final customBio = _expertBioCtrl.text.trim();
              final customLicense = _licenseOrStaffIdCtrl.text.trim();
              final customAffiliation = _practiceOrOrgNameCtrl.text.trim();
              final customDistrict = _districtOrStationCtrl.text.trim();
              final customHourly = double.tryParse(_hourlyRateCtrl.text.trim()) ?? 45.0;
              final customVisit = double.tryParse(_visitRateCtrl.text.trim()) ?? 120.0;

              final curProfile = ref.read(agriExpertProvider).profile;
              ref.read(agriExpertProvider.notifier).updateProfile(
                    curProfile.copyWith(
                      activePersona: persona,
                      bio: customBio.isNotEmpty ? customBio : curProfile.bio,
                      companyAffiliation: customAffiliation.isNotEmpty ? customAffiliation : curProfile.companyAffiliation,
                      operatingDistrict: customDistrict.isNotEmpty ? customDistrict : curProfile.operatingDistrict,
                      hourlyRateUsd: customHourly,
                      farmVisitRateUsd: customVisit,
                      isVerifiedByState: persona == ExpertPersona.governmentExtension,
                      agritexOfficerId: customLicense.isNotEmpty ? customLicense : curProfile.agritexOfficerId,
                    ),
                  );

              setState(() {
                _currentStep = 4; // Preview workspace step
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save & Preview Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 3: COMPANY TENANT SETUP
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCompanyTenantStep() {
    return _buildGlassCard(
      key: const ValueKey('company_step'),
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep = 2),
              ),
              const SizedBox(width: 8),
              Text(
                'Company & Workspace',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Create New Org'),
                  selected: _createNewTenant,
                  onSelected: (val) {
                    setState(() => _createNewTenant = true);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Join with Code'),
                  selected: !_createNewTenant,
                  onSelected: (val) {
                    setState(() => _createNewTenant = false);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_createNewTenant) ...[
            TextFormField(
              controller: _companyController,
              decoration: InputDecoration(
                labelText: 'Company / Organization Name',
                prefixIcon: const Icon(Icons.business_outlined, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ] else ...[
            TextFormField(
              controller: _inviteCodeController,
              decoration: InputDecoration(
                labelText: 'Enter Invite Code',
                hintText: 'e.g. ORG-9981-ABC',
                prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCountry,
            decoration: InputDecoration(
              labelText: 'Operating Region',
              prefixIcon: const Icon(Icons.map_outlined, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _countries.map((c) {
              return DropdownMenuItem(value: c, child: Text(c));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedCountry = val);
              }
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_createNewTenant && _companyController.text.trim().isEmpty) {
                _showToast('Please specify a company name.');
                return;
              }
              if (!_createNewTenant && _inviteCodeController.text.trim().isEmpty) {
                _showToast('Please enter your invitation code.');
                return;
              }
              setState(() {
                _currentStep = 4;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Next: Access & Permissions Preview', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 4: PERMISSIONS & MODULE PREVIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildAccessPreviewStep() {
    final List<Map<String, dynamic>> previewItems = _getPermissionsPreview(_selectedRole);

    return _buildGlassCard(
      key: const ValueKey('preview_step'),
      padding: const EdgeInsets.all(28.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _currentStep = 2),
              ),
              const SizedBox(width: 8),
              Text(
                'Workspace Preview',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          Text(
            'Below is the dynamic layout Verdi will configure for your role (${_selectedRole.label}):',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
            ),
            child: SizedBox(
              height: 240,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: previewItems.length,
                itemBuilder: (context, index) {
                  final item = previewItems[index];
                  final String access = item['access'].toString();
                  final Color badgeColor = access == 'Read + Write' 
                      ? const Color(0xFF16A34A) 
                      : (access == 'Read Only' ? Colors.blue : Colors.red.shade400);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(item['icon'] as IconData, size: 20, color: const Color(0xFF0F172A)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(item['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            access,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _finishSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Confirm & Complete Onboarding', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 5: FINAL ONBOARDING COMPLETION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCompleteOnboardingStep() {
    return _buildGlassCard(
      key: const ValueKey('complete_step'),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF16A34A),
            size: 72,
          ),
          const SizedBox(height: 24),
          Text(
            'Onboarding Completed!',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your specialized workspace has been configured successfully. Real-time telemetry, market feeds, and module access control are now active.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              ref.read(authStateProvider.notifier).initialize();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Enter App Workspace', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(width: 8),
                Icon(Icons.login, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getPermissionsPreview(UserRole role) {
    return [
      {
        'name': 'Home Hub',
        'access': 'Read + Write',
        'icon': Icons.home_outlined,
      },
      {
        'name': 'Value-Chain Marketplace',
        'access': 'Read + Write',
        'icon': Icons.storefront_outlined,
      },
      {
        'name': 'AI Co-Pilot Advisor',
        'access': 'Read + Write',
        'icon': Icons.assistant_outlined,
      },
      {
        'name': 'Traceability Ledger',
        'access': (role == UserRole.farmer || role == UserRole.buyer || role == UserRole.admin || role == UserRole.transporter) 
            ? 'Read + Write' 
            : 'Read Only',
        'icon': Icons.link_outlined,
      },
      {
        'name': 'Payments & Finance',
        'access': (role == UserRole.financier || role == UserRole.admin || role == UserRole.farmer)
            ? 'Read + Write'
            : (role == UserRole.buyer ? 'Read Only' : 'Hidden'),
        'icon': Icons.payments_outlined,
      },
      {
        'name': 'Farm Irrigation & Operations',
        'access': (role == UserRole.farmer || role == UserRole.expert || role == UserRole.admin)
            ? 'Read + Write'
            : 'Hidden',
        'icon': Icons.agriculture_outlined,
      },
      {
        'name': 'Logistics & Fleet Tracker',
        'access': (role == UserRole.transporter || role == UserRole.admin)
            ? 'Read + Write'
            : (role == UserRole.buyer || role == UserRole.farmer ? 'Read Only' : 'Hidden'),
        'icon': Icons.local_shipping_outlined,
      },
      {
        'name': 'Global Platform Settings',
        'access': (role == UserRole.admin) ? 'Read + Write' : 'Read Only',
        'icon': Icons.settings_outlined,
      },
    ];
  }
}
