import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../state/app_state.dart';
import '../state/auth_state.dart';
import '../../../widgets/verdi_logo.dart';

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
    super.dispose();
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(authStateProvider.notifier);

    if (!_isSignUp) {
      // Direct sign in
      final success = await notifier.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (success) {
        _showToast('Signed in successfully.');
      } else {
        final err = ref.read(authStateProvider).errorMessage ?? '';
        if (err.toLowerCase().contains('connection') || err.toLowerCase().contains('fail')) {
          _showConnectionFailedDialog(
            email: _emailController.text.trim(),
            role: UserRole.farmer,
          );
        } else {
          _showToast(err.isNotEmpty ? err : 'Invalid email or password.');
        }
      }
    } else {
      // Proceed to Stakeholder selector step
      setState(() {
        _currentStep = 2;
      });
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
              if (key == 'Mufasa05?' || key == 'VERDI-ADMIN-2026' || key == 'admin123') {
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

                ref.read(appStateProvider.notifier).setRole(UserRole.admin);
                
                ref.read(authStateProvider.notifier).authenticateUser(adminUser);
                
                _showToast('Welcome back, Creator.');
              } else {
                _showToast('Invalid Admin Passkey.');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF16A34A), foregroundColor: Colors.white),
            child: const Text('Access'),
          ),
        ],
      ),
    );
  }

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
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );

    if (success) {
      _showToast('Account & tenant profile registered successfully.');
      setState(() {
        _currentStep = 5;
      });
    } else {
      final err = ref.read(authStateProvider).errorMessage ?? '';
      if (err.toLowerCase().contains('connection') || err.toLowerCase().contains('fail')) {
        _showConnectionFailedDialog(
          email: _emailController.text.trim(),
          fullName: _nameController.text.trim(),
          role: _selectedRole,
        );
      } else {
        _showToast(err.isNotEmpty ? err : 'Unable to complete sign up.');
        setState(() {
          _currentStep = 1; // Fallback to credentials
        });
      }
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
          // Background Wash
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xEE0F172A), Color(0xCC1E293B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
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

  Widget _buildCurrentStepWidget(AuthState authState) {
    switch (_currentStep) {
      case 0:
        return _buildSplashStep();
      case 1:
        return _buildCredentialsStep(authState);
      case 2:
        return _buildStakeholderSelectorStep();
      case 3:
        return _buildCompanyTenantStep();
      case 4:
        return _buildAccessPreviewStep();
      case 5:
        return _buildCompleteOnboardingStep();
      default:
        return _buildSplashStep();
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 0: SPLASH SCREEN
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildSplashStep() {
    return Card(
      key: const ValueKey('splash_step'),
      color: Colors.white.withOpacity(0.92),
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const VerdiLogo(size: 80),
            const SizedBox(height: 24),
            Text(
              'VERDI',
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intelligent Agriculture Value Chain OS',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Connecting farmers, agronomists, logistics fleets, buyers, and financial services in one unified platform.',
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
                setState(() {
                  _currentStep = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Get Started', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 1: CREDENTIALS (SIGN IN / SIGN UP)
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCredentialsStep(AuthState authState) {
    return Card(
      key: const ValueKey('credentials_step'),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
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
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isSignUp
                    ? 'Enter your details to create an account'
                    : 'Sign in to access your platform dashboard.',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
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
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Enter your email'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                autofillHints: const [],
                validator: (value) => (value == null || value.length < 6)
                    ? 'Use at least 6 characters'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
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
                    onPressed: () {
                      final email = _emailController.text.trim().isEmpty ? 'operator@verdi.co' : _emailController.text.trim();
                      ref.read(authStateProvider.notifier).enterOfflineDemoMode(
                        email: email,
                        fullName: 'Platform Operator',
                        role: UserRole.admin,
                      );
                      _showToast('Offline Demo Mode Activated.');
                    },
                    icon: const Icon(Icons.flash_on_outlined, size: 16, color: Color(0xFF16A34A)),
                    label: const Text('Offline Demo Mode', style: TextStyle(color: Color(0xFF16A34A), fontSize: 12, fontWeight: FontWeight.bold)),
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
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 2: STAKEHOLDER SELECTOR GRID
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildStakeholderSelectorStep() {
    return Card(
      key: const ValueKey('stakeholder_step'),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
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
              child: const Text('Next: Preview Workspace', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 3: COMPANY TENANT SETUP
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCompanyTenantStep() {
    return Card(
      key: const ValueKey('company_step'),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
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
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 4: PERMISSIONS & MODULE PREVIEW
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildAccessPreviewStep() {
    final List<Map<String, dynamic>> previewItems = _getPermissionsPreview(_selectedRole);

    return Card(
      key: const ValueKey('preview_step'),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
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
                color: Colors.grey.shade50,
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
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // STEP 5: FINAL ONBOARDING COMPLETION
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildCompleteOnboardingStep() {
    return Card(
      key: const ValueKey('complete_step'),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
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
        'access': (role == UserRole.driver || role == UserRole.transporter || role == UserRole.admin)
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
