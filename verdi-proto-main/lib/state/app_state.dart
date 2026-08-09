import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All 10 stakeholder types in the VERDI agricultural value chain.
/// The original 4 (farmer, buyer, driver, admin) are preserved for
/// backward-compatibility with the existing auth and routing logic.
enum UserRole {
  // ── Core original roles ─────────────────────────────────────────
  farmer,       // 1. Smallholder / Commercial / Cooperative farmers
  buyer,        // 2. Retailers, wholesalers, supermarkets, exporters
  driver,       // 3. Transport providers (trucks, motorbikes)
  admin,        // 10. Platform admins & developers

  // ── Extended stakeholder roles ──────────────────────────────────
  transporter,  // 3b. Transport companies (fleet managers)
  valueAdder,   // 4. Food processors, packagers, cold storage
  expert,       // 5. Agronomists, vets, soil scientists
  financier,    // 6. Banks, MFIs, agri-loan & insurance providers
  government,   // 8. Ministry of Agriculture, NGOs, extension officers
  consumer,     // 9. Individuals, restaurants, institutions
;

  /// Human-readable display label.
  String get label => switch (this) {
        UserRole.farmer => 'Farmer',
        UserRole.buyer => 'Buyer',
        UserRole.driver => 'Driver',
        UserRole.admin => 'Admin',
        UserRole.transporter => 'Transporter',
        UserRole.valueAdder => 'Value Adder',
        UserRole.expert => 'Agri-Expert',
        UserRole.financier => 'Financial Institution',
        UserRole.government => 'Government / NGO',
        UserRole.consumer => 'Consumer',
      };

  /// Short role category tag shown in banners/chips.
  String get categoryTag => switch (this) {
        UserRole.farmer => 'Supply-side',
        UserRole.buyer => 'Demand-side',
        UserRole.driver || UserRole.transporter => 'Logistics',
        UserRole.admin => 'Platform Admin',
        UserRole.valueAdder => 'Value Chain',
        UserRole.expert => 'Advisory',
        UserRole.financier => 'Financial Services',
        UserRole.government => 'Public Sector',
        UserRole.consumer => 'End Consumer',
      };

  /// Material icon for each role.
  IconData get icon => switch (this) {
        UserRole.farmer => Icons.agriculture_outlined,
        UserRole.buyer => Icons.shopping_cart_outlined,
        UserRole.driver || UserRole.transporter => Icons.local_shipping_outlined,
        UserRole.admin => Icons.admin_panel_settings_outlined,
        UserRole.valueAdder => Icons.factory_outlined,
        UserRole.expert => Icons.science_outlined,
        UserRole.financier => Icons.account_balance_outlined,
        UserRole.government => Icons.account_balance_wallet_outlined,
        UserRole.consumer => Icons.person_outline,
      };

  /// Short description of what this role does on the platform.
  String get description => switch (this) {
        UserRole.farmer =>
          'Sell produce, access markets, view prices, request transport.',
        UserRole.buyer =>
          'Browse produce, place orders, schedule deliveries.',
        UserRole.driver =>
          'Get delivery requests, track routes, manage logistics.',
        UserRole.transporter =>
          'Manage fleet, assign drivers, track shipments.',
        UserRole.admin =>
          'Maintain system, manage users, monitor platform health.',
        UserRole.valueAdder =>
          'Source raw materials, offer processing & storage services.',
        UserRole.expert =>
          'Offer advisory services, field diagnostics, and reports.',
        UserRole.financier =>
          'Offer credit scoring, loans, crop insurance, wallet integration.',
        UserRole.government =>
          'Access data, monitor farmer activity, support programs.',
        UserRole.consumer =>
          'Buy directly from farmers or retailers.',
      };

  /// Whether this role has full analytics access.
  bool get hasFullAnalytics =>
      this == UserRole.admin || this == UserRole.government;

  /// Whether this role sees logistics/delivery features.
  bool get hasLogisticsAccess =>
      this == UserRole.driver ||
      this == UserRole.transporter ||
      this == UserRole.admin ||
      this == UserRole.government;

  /// Whether this role can place orders.
  bool get canPlaceOrders =>
      this == UserRole.buyer ||
      this == UserRole.consumer ||
      this == UserRole.valueAdder;

  /// Whether this role can list produce.
  bool get canListProduce =>
      this == UserRole.farmer || this == UserRole.valueAdder;
}

/// Supported Multi-Currency Modes for Zimbabwe & SADC Agricultural Trade.
enum AppCurrency {
  zig, // 🇿🇼 Zimbabwe Gold (ZiG)
  usd, // 🇺🇸 United States Dollar
  zar, // 🇿🇦 South African Rand
;

  String get code => switch (this) {
        AppCurrency.zig => 'ZiG',
        AppCurrency.usd => 'USD',
        AppCurrency.zar => 'ZAR',
      };

  String get symbol => switch (this) {
        AppCurrency.zig => 'ZiG ',
        AppCurrency.usd => '\$',
        AppCurrency.zar => 'R ',
      };

  String get flag => switch (this) {
        AppCurrency.zig => '🇿🇼',
        AppCurrency.usd => '🇺🇸',
        AppCurrency.zar => '🇿🇦',
      };

  String get label => switch (this) {
        AppCurrency.zig => '🇿🇼 ZiG (Zimbabwe Gold)',
        AppCurrency.usd => '🇺🇸 USD (US Dollar)',
        AppCurrency.zar => '🇿🇦 ZAR (SA Rand)',
      };

  /// Exchange rate relative to USD (1 USD = X Local Units)
  double get rateToUsd => switch (this) {
        AppCurrency.zig => 13.50, // Official Reserve Bank ZiG rate
        AppCurrency.usd => 1.00,
        AppCurrency.zar => 18.00, // SADC regional trade rate
      };

  /// Converts a base USD amount to the selected currency string
  String format(double usdAmount) {
    final converted = usdAmount * rateToUsd;
    if (this == AppCurrency.zig) {
      final formatted = converted >= 1000
          ? _formatWithCommas(converted)
          : converted.toStringAsFixed(2);
      return 'ZiG $formatted';
    } else if (this == AppCurrency.zar) {
      return 'R ${_formatWithCommas(converted)}';
    } else {
      return '\$${_formatWithCommas(converted)} USD';
    }
  }

  static String _formatWithCommas(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '$integerPart.${parts[1]}';
  }
}

class AppState {
  final UserRole role;
  final int navIndex;
  final AppCurrency currency;
  final bool isDemoMode;

  const AppState({
    required this.role,
    required this.navIndex,
    this.currency = AppCurrency.zig,
    this.isDemoMode = false,
  });

  AppState copyWith({
    UserRole? role,
    int? navIndex,
    AppCurrency? currency,
    bool? isDemoMode,
  }) {
    return AppState(
      role: role ?? this.role,
      navIndex: navIndex ?? this.navIndex,
      currency: currency ?? this.currency,
      isDemoMode: isDemoMode ?? this.isDemoMode,
    );
  }

  static const initial = AppState(
    role: UserRole.farmer,
    navIndex: 0,
    currency: AppCurrency.zig,
    isDemoMode: false,
  );
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState.initial);

  void setRole(UserRole role) {
    state = state.copyWith(role: role, navIndex: 0);
  }

  void setNavIndex(int index) {
    state = state.copyWith(navIndex: index);
  }

  void setCurrency(AppCurrency currency) {
    state = state.copyWith(currency: currency);
  }

  void setDemoMode(bool enabled) {
    state = state.copyWith(isDemoMode: enabled);
  }

  void toggleDemoMode() {
    state = state.copyWith(isDemoMode: !state.isDemoMode);
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

final isDemoModeProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isDemoMode;
});