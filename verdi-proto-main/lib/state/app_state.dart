import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// All stakeholder types in the VERDI agricultural value chain.
enum UserRole {
  // ── Core roles ───────────────────────────────────────────────────
  farmer,       // 1. Smallholder / Commercial / Cooperative farmers
  buyer,        // 2. Retailers, wholesalers, supermarkets, exporters
  transporter,  // 3. Transport companies & fleet operators
  admin,        // 10. Platform admins & developers

  // ── Extended stakeholder roles ──────────────────────────────────
  valueAdder,   // 4. Food processors, packagers, cold storage
  expert,       // 5. Agronomists, vets, soil scientists
  financier,    // 6. Banks, MFIs, agri-loan & insurance providers
  government,   // 8. Ministry of Agriculture, NGOs, extension officers
  consumer,     // 9. Individuals, restaurants, institutions
;

  /// Human-readable display label.
  String get label => switch (this) {
        UserRole.farmer => 'Farmer',
        UserRole.buyer => 'Commercial Buyer (B2B)',
        UserRole.admin => 'Admin',
        UserRole.transporter => 'Transporter',
        UserRole.valueAdder => 'Value Adder',
        UserRole.expert => 'Agri-Expert',
        UserRole.financier => 'Financial Institution',
        UserRole.government => 'Government / NGO',
        UserRole.consumer => 'Consumer (End-User)',
      };

  /// Short role category tag shown in banners/chips.
  String get categoryTag => switch (this) {
        UserRole.farmer => 'Supply-side',
        UserRole.buyer => 'B2B Enterprise',
        UserRole.transporter => 'Logistics',
        UserRole.admin => 'Platform Admin',
        UserRole.valueAdder => 'Value Chain',
        UserRole.expert => 'Advisory',
        UserRole.financier => 'Financial Services',
        UserRole.government => 'Public Sector',
        UserRole.consumer => 'Retail & Household',
      };

  /// Material icon for each role.
  IconData get icon => switch (this) {
        UserRole.farmer => Icons.agriculture_outlined,
        UserRole.buyer => Icons.storefront_outlined,
        UserRole.transporter => Icons.local_shipping_outlined,
        UserRole.admin => Icons.admin_panel_settings_outlined,
        UserRole.valueAdder => Icons.factory_outlined,
        UserRole.expert => Icons.science_outlined,
        UserRole.financier => Icons.account_balance_outlined,
        UserRole.government => Icons.account_balance_wallet_outlined,
        UserRole.consumer => Icons.shopping_basket_outlined,
      };

  /// Short description of what this role does on the platform.
  String get description => switch (this) {
        UserRole.farmer =>
          'Sell produce, access markets, view prices, request transport.',
        UserRole.buyer =>
          'Bulk lot procurement, outgrower contracts, wholesale trade desk, and commercial escrow.',
        UserRole.transporter =>
          'Manage fleet, register vehicles, assign drivers & track shipments.',
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
          'Farm-to-table fresh produce, consumer grocery basket, direct courier delivery & EcoCash wallet.',
      };

  /// Whether this role has full analytics access.
  bool get hasFullAnalytics =>
      this == UserRole.admin || this == UserRole.government;

  /// Whether this role sees logistics/delivery features.
  bool get hasLogisticsAccess =>
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

/// Specific Buyer Category in the VERDI Marketplace Ecosystem.
enum BuyerSubRole {
  retailerWholesaler, // ① Retailer / Wholesaler (Commercial B2B Buyer)
  endUserCustomer,    // ② Customer / End User (Direct B2C Consumer)
  ;

  String get label => switch (this) {
    BuyerSubRole.retailerWholesaler => 'Retailer / Wholesaler (B2B Commercial)',
    BuyerSubRole.endUserCustomer => 'Customer / End-User (Direct Consumer)',
  };

  String get shortTitle => switch (this) {
    BuyerSubRole.retailerWholesaler => 'Retailer / Wholesaler',
    BuyerSubRole.endUserCustomer => 'Customer / End-User',
  };

  String get description => switch (this) {
    BuyerSubRole.retailerWholesaler => 'Bulk lot procurement, outgrower contracts, wholesale trade desk, and commercial escrow.',
    BuyerSubRole.endUserCustomer => 'Farm-to-table fresh produce, consumer grocery basket, InDrive-style delivery tracking & direct messenger.',
  };
}

class AppState {
  final UserRole role;
  final BuyerSubRole buyerSubRole;
  final int navIndex;
  final AppCurrency currency;
  final bool isDemoMode;
  final ThemeMode themeMode;

  const AppState({
    required this.role,
    this.buyerSubRole = BuyerSubRole.retailerWholesaler,
    required this.navIndex,
    this.currency = AppCurrency.zig,
    this.isDemoMode = false,
    this.themeMode = ThemeMode.system,
  });

  AppState copyWith({
    UserRole? role,
    BuyerSubRole? buyerSubRole,
    int? navIndex,
    AppCurrency? currency,
    bool? isDemoMode,
    ThemeMode? themeMode,
  }) {
    return AppState(
      role: role ?? this.role,
      buyerSubRole: buyerSubRole ?? this.buyerSubRole,
      navIndex: navIndex ?? this.navIndex,
      currency: currency ?? this.currency,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  static const initial = AppState(
    role: UserRole.farmer,
    buyerSubRole: BuyerSubRole.retailerWholesaler,
    navIndex: 0,
    currency: AppCurrency.zig,
    isDemoMode: false,
    themeMode: ThemeMode.system,
  );
}

class AppStateNotifier extends StateNotifier<AppState> {
  static const _prefDemoModeKey = 'verdi.app.is_demo_mode';
  static const _prefCurrencyKey = 'verdi.app.selected_currency';
  static const _prefBuyerSubRoleKey = 'verdi.app.buyer_sub_role';
  static const _prefThemeModeKey = 'verdi.app.theme_mode';

  AppStateNotifier() : super(AppState.initial) {
    _loadPersistedPreferences();
  }

  Future<void> _loadPersistedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasDemoPref = prefs.containsKey(_prefDemoModeKey);
      final isDemo = hasDemoPref ? (prefs.getBool(_prefDemoModeKey) ?? false) : false;
      final currencyCode = prefs.getString(_prefCurrencyKey);
      final buyerSubRoleName = prefs.getString(_prefBuyerSubRoleKey);
      final savedThemeMode = prefs.getString(_prefThemeModeKey);

      AppCurrency selectedCurrency = AppCurrency.zig;
      if (currencyCode != null) {
        selectedCurrency = AppCurrency.values.firstWhere(
          (c) => c.name == currencyCode,
          orElse: () => AppCurrency.zig,
        );
      }

      BuyerSubRole selectedBuyerSubRole = BuyerSubRole.retailerWholesaler;
      if (buyerSubRoleName != null) {
        selectedBuyerSubRole = BuyerSubRole.values.firstWhere(
          (s) => s.name == buyerSubRoleName,
          orElse: () => BuyerSubRole.retailerWholesaler,
        );
      }

      ThemeMode selectedThemeMode = ThemeMode.system;
      if (savedThemeMode != null) {
        if (savedThemeMode == 'light') selectedThemeMode = ThemeMode.light;
        if (savedThemeMode == 'dark') selectedThemeMode = ThemeMode.dark;
        if (savedThemeMode == 'system') selectedThemeMode = ThemeMode.system;
      }

      state = state.copyWith(
        isDemoMode: isDemo,
        currency: selectedCurrency,
        buyerSubRole: selectedBuyerSubRole,
        themeMode: selectedThemeMode,
      );
    } catch (_) {}
  }

  void setRole(UserRole role) {
    int initialNav = 0;
    if (role == UserRole.transporter) {
      initialNav = 5; // Launch directly into Verdi Logistics OS
    }
    state = state.copyWith(role: role, navIndex: initialNav);
  }

  void setBuyerSubRole(BuyerSubRole subRole) {
    state = state.copyWith(buyerSubRole: subRole);
    SharedPreferences.getInstance().then((p) => p.setString(_prefBuyerSubRoleKey, subRole.name)).catchError((_) => false);
  }

  void setNavIndex(int index) {
    state = state.copyWith(navIndex: index);
  }

  void setCurrency(AppCurrency currency) {
    state = state.copyWith(currency: currency);
    SharedPreferences.getInstance().then((p) => p.setString(_prefCurrencyKey, currency.name)).catchError((_) => false);
  }

  void setDemoMode(bool enabled) {
    state = state.copyWith(isDemoMode: enabled);
    SharedPreferences.getInstance().then((p) => p.setBool(_prefDemoModeKey, enabled)).catchError((_) => false);
  }

  void toggleDemoMode() {
    final newMode = !state.isDemoMode;
    setDemoMode(newMode);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    SharedPreferences.getInstance().then((p) => p.setString(_prefThemeModeKey, mode.name)).catchError((_) => false);
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

final isDemoModeProvider = Provider<bool>((ref) {
  return ref.watch(appStateProvider).isDemoMode;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appStateProvider).themeMode;
});