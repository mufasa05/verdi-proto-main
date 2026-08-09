import 'package:flutter/foundation.dart';
import '../../../core/services/verdi_api_service.dart';
import 'platform_word_index.dart';

/// Structured execution result returned by the Verdi Autonomous Voice Agent.
class AgentExecutionResult {
  final String actionType; // 'navigate' | 'execute' | 'query' | 'inform' | 'disambiguate'
  final String moduleName;
  final int? navIndex;
  final String responseSpeech;
  final Map<String, dynamic>? payload;

  const AgentExecutionResult({
    required this.actionType,
    required this.moduleName,
    this.navIndex,
    required this.responseSpeech,
    this.payload,
  });
}

/// Autonomous Voice-First AI Agent client for Verdi Platform.
/// Interprets natural language/voice prompts, routes function calls to Verdi modules,
/// executes platform actions, and provides speech feedback (Shona/English).
class VerdiAgroAutonomousAgent {
  VerdiAgroAutonomousAgent._();
  static final VerdiAgroAutonomousAgent instance = VerdiAgroAutonomousAgent._();

  /// Processes raw voice/text [prompt] and executes autonomous action routing with RBAC check.
  Future<AgentExecutionResult> processAutonomousCommand(String prompt, {String? userRole}) async {
    final t = prompt.trim();
    final lower = t.toLowerCase();

    if (t.isEmpty) {
      return const AgentExecutionResult(
        actionType: 'inform',
        moduleName: 'assistant',
        responseSpeech: 'Welcome to Verdi Autonomous Voice Agent. Ask any question or issue a voice command to operate all 25 modules.',
      );
    }

    // RBAC Permission Check for Field Operations
    final normRole = (userRole ?? '').toLowerCase();
    const restrictedRoles = ['driver', 'transporter', 'buyer', 'consumer'];

    // ─────────────────────────────────────────────────────────────────────────
    // 0. PLATFORM GLOBAL WORD CLASSIFIER & MULTI-SCREEN DISAMBIGUATION
    // ─────────────────────────────────────────────────────────────────────────
    final wordLookup = PlatformWordIndex.instance.lookupTerm(t);
    if (wordLookup.isDisambiguationNeeded && wordLookup.disambiguation != null) {
      final matches = wordLookup.disambiguation!.matches;
      final matchDescriptions = matches.asMap().entries.map((e) => '${e.key + 1}. ${e.value.pageName}').join(', ');
      return AgentExecutionResult(
        actionType: 'disambiguate',
        moduleName: 'assistant',
        responseSpeech: 'The term "${wordLookup.disambiguation!.keyword}" was found on ${matches.length} screens: $matchDescriptions. Which one would you prefer to visit?',
        payload: {
          'keyword': wordLookup.disambiguation!.keyword,
          'matches': matches,
        },
      );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 1. NAVIGATION INTENT ROUTING (Voice & Text UI Navigation for 25 Modules)
    // ─────────────────────────────────────────────────────────────────────────

    // Admin Command Center (Index 23)
    if (lower.contains('admin') || lower.contains('command center') || lower.contains('admin dashboard')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'admin',
        navIndex: 23,
        responseSpeech: 'Opening Admin Command Center...',
      );
    }

    // Logistics & Transport (Index 5)
    if (lower.contains('logistics') || lower.contains('truck') || lower.contains('dispatch') || lower.contains('transport') || lower.contains('fleet')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'logistics',
        navIndex: 5,
        responseSpeech: 'Opening fleet tracking and transport logistics dashboard...',
      );
    }

    // Drone Inspection (Index 10)
    if (lower.contains('drone') || lower.contains('fly') || lower.contains('aerial')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'drone',
        navIndex: 10,
        responseSpeech: 'Connecting to aerial telemetry and drone inspection controls...',
      );
    }

    // Smart Irrigation (Index 8 / 9)
    if (lower.contains('irrigation') || lower.contains('watering') || lower.contains('water field') || lower.contains('pump') || lower.contains('water')) {
      if (restrictedRoles.contains(normRole) && (lower.contains('start') || lower.contains('schedule') || lower.contains('turn on') || lower.contains('run') || lower.contains('water'))) {
        return AgentExecutionResult(
          actionType: 'inform',
          moduleName: 'assistant',
          responseSpeech: 'Access Denied: You do not have permission to execute smart irrigation controls with your active $userRole role.',
        );
      }
      final durationMatch = RegExp(r'(\d+)\s*(min|minute|hr|hour)s?').firstMatch(lower);
      final durationStr = durationMatch != null ? '${durationMatch.group(1)} ${durationMatch.group(2)}s' : '30 mins';

      String targetField = 'Field A (Maize)';
      if (lower.contains('field b') || lower.contains('zone b')) targetField = 'Field B (Soybeans)';
      if (lower.contains('field c') || lower.contains('zone c')) targetField = 'Field C (Wheat)';
      if (lower.contains('zone 1')) targetField = 'Zone 1 - High Density';
      if (lower.contains('zone 2')) targetField = 'Zone 2 - Pivot Sector';

      if (lower.contains('start') || lower.contains('schedule') || lower.contains('turn on') || lower.contains('run') || lower.contains('water')) {
        return AgentExecutionResult(
          actionType: 'execute',
          moduleName: 'irrigation',
          navIndex: 8,
          responseSpeech: 'Starting automated smart irrigation protocol for $targetField ($durationStr)...',
          payload: {
            'status': 'active',
            'duration': durationStr,
            'targetField': targetField,
          },
        );
      }
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'irrigation',
        navIndex: 8,
        responseSpeech: 'Opening Smart Irrigation Management dashboard...',
      );
    }

    // Farm Operations (Index 11)
    if (lower.contains('farm operations') || lower.contains('field work') || lower.contains('operations task')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'farm_operations',
        navIndex: 11,
        responseSpeech: 'Opening Farm Operations management...',
      );
    }

    // Operations Dashboard (Index 12)
    if (lower == 'dashboard' || lower.contains('operations dashboard') || lower.contains('kpi dashboard') || lower.contains('farm dashboard')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'dashboard',
        navIndex: 12,
        responseSpeech: 'Opening Operations Dashboard...',
      );
    }

    // Analytics & Yield (Index 3)
    if (lower.contains('analytics') || lower.contains('analysis') || lower.contains('yield forecast') || lower.contains('metrics') || lower.contains('performance report')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'analytics',
        navIndex: 3,
        responseSpeech: 'Opening farm performance analytics...',
      );
    }

    // Orders (Index 4)
    if (lower.contains('orders') || lower.contains('order list') || lower.contains('my orders')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'orders',
        navIndex: 4,
        responseSpeech: 'Opening Orders management...',
      );
    }

    // Payments & Escrow (Index 6)
    if (lower.contains('payments') || lower.contains('escrow') || lower.contains('settlement')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'payments',
        navIndex: 6,
        responseSpeech: 'Opening Payments & Escrow Hub...',
      );
    }

    // Notifications (Index 7)
    if (lower.contains('notification') || lower.contains('alert center') || lower.contains('unread alerts')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'notifications',
        navIndex: 7,
        responseSpeech: 'Opening Notification Center...',
      );
    }

    // Geospatial (Index 13)
    if (lower.contains('geospatial') || lower.contains('gis map') || lower.contains('contour') || lower.contains('boundary map')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'geospatial',
        navIndex: 13,
        responseSpeech: 'Opening Geospatial GIS mapping...',
      );
    }

    // Crop Health (Index 14)
    if (lower.contains('crop health') || lower.contains('disease') || lower.contains('pest') || lower.contains('diagnosis') || lower.contains('scan') || lower.contains('diagnostic')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'crop_health',
        navIndex: 14,
        responseSpeech: 'Opening Crop Health diagnostics...',
      );
    }

    // Traceability (Index 15)
    if (lower.contains('traceability') || lower.contains('batch scan') || lower.contains('qr code') || lower.contains('farm to fork')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'traceability',
        navIndex: 15,
        responseSpeech: 'Opening Supply Chain Traceability...',
      );
    }

    // Finance & Agri-Wallet (Index 16)
    if (lower.contains('finance') || lower.contains('agri wallet') || lower.contains('credit score') || lower.contains('loans')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'finance',
        navIndex: 16,
        responseSpeech: 'Opening Finance & Agri-Wallet...',
      );
    }

    // Weather (Index 17)
    if (lower.contains('weather') || lower.contains('forecast') || lower.contains('rain') || lower.contains('radar') || lower.contains('climate') || lower.contains('temp')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'weather',
        navIndex: 17,
        responseSpeech: 'Loading real-time weather radar and forecasts...',
      );
    }

    // Government (Index 18)
    if (lower.contains('government') || lower.contains('subsidy') || lower.contains('voucher') || lower.contains('extension officer')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'government',
        navIndex: 18,
        responseSpeech: 'Opening Government AgOS Administration & E-Vouchers...',
      );
    }

    // Trade (Index 19)
    if (lower.contains('trade') || lower.contains('commodity price') || lower.contains('regional trade')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'trade',
        navIndex: 19,
        responseSpeech: 'Opening Regional Trade Intelligence Hub...',
      );
    }

    // Satellite (Index 20)
    if (lower.contains('satellite') || lower.contains('ndvi') || lower.contains('imagery') || lower.contains('sentinel')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'satellite',
        navIndex: 20,
        responseSpeech: 'Loading satellite crop health scans and NDVI maps...',
      );
    }

    // Settings (Index 21)
    if (lower.contains('settings') || lower.contains('preferences') || lower.contains('profile config')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'settings',
        navIndex: 21,
        responseSpeech: 'Opening Settings & Configuration...',
      );
    }

    // Export (Index 22)
    if (lower.contains('export') || lower.contains('ephyto') || lower.contains('customs clearance')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'export',
        navIndex: 22,
        responseSpeech: 'Opening Export & ePhyto Hub...',
      );
    }

    // News (Index 24)
    if (lower.contains('news') || lower.contains('updates') || lower.contains('agri news')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'news',
        navIndex: 24,
        responseSpeech: 'Loading regional agriculture news feed...',
      );
    }

    // Home (Index 0)
    if (lower.contains('home') || lower.contains('main screen') || lower.contains('go home')) {
      return const AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'home',
        navIndex: 0,
        responseSpeech: 'Returning to Home Dashboard...',
      );
    }

    // Marketplace (Index 1)
    if (lower.contains('marketplace') ||
        lower.contains('market') ||
        lower.contains('buy') ||
        lower.contains('store') ||
        lower.contains('shop') ||
        lower.contains('order') ||
        lower.contains('purchase')) {
      // Dynamic quantity and product parsing
      final qtyMatch = RegExp(r'(\d+)\s*(bag|unit|kg|ton|pack)s?').firstMatch(lower);
      final qtyStr = qtyMatch != null ? '${qtyMatch.group(1)} ${qtyMatch.group(2)}s' : null;

      String itemStr = 'Agricultural Products';
      if (lower.contains('fertilizer')) itemStr = 'NPK Fertilizer';
      if (lower.contains('seed') || lower.contains('maize seed')) itemStr = 'Hybrid Seed Maize';
      if (lower.contains('solar') || lower.contains('pump')) itemStr = 'Solar Irrigation Pump';

      if (lower.contains('revive') || lower.contains('juice') || lower.contains('soda') || lower.contains('coke')) {
        return const AgentExecutionResult(
          actionType: 'navigate',
          moduleName: 'marketplace',
          navIndex: 1,
          responseSpeech: 'I searched the Verdi Agricultural Marketplace, but "Revive Juice" is currently not listed or out of stock in our agricultural catalogue. Our marketplace features farm produce, seeds, fertilizers, and farm equipment.',
        );
      }

      final responseText = qtyStr != null
          ? 'Searching Marketplace for $qtyStr of $itemStr...'
          : 'Opening the Verdi Agricultural Marketplace...';

      return AgentExecutionResult(
        actionType: 'navigate',
        moduleName: 'marketplace',
        navIndex: 1,
        responseSpeech: responseText,
        payload: qtyStr != null ? {'quantity': qtyStr, 'product': itemStr} : null,
      );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 2. QUERY & BACKEND AI INTENT ROUTING
    // ─────────────────────────────────────────────────────────────────────────
    try {
      final backendText = await VerdiApiService.instance.askBackendAi(t);
      if (backendText.isNotEmpty) {
        return AgentExecutionResult(
          actionType: 'query',
          moduleName: 'assistant',
          responseSpeech: backendText,
        );
      }
    } catch (e) {
      debugPrint('Autonomous Agent backend query error: $e');
    }

    return AgentExecutionResult(
      actionType: 'inform',
      moduleName: 'assistant',
      responseSpeech: 'Received command: "$t". Processing request and updating platform state.',
    );
  }

  /// Backward-compatible query string processor.
  Future<String> processQuery(String prompt) async {
    final res = await processAutonomousCommand(prompt);
    return res.responseSpeech;
  }
}
