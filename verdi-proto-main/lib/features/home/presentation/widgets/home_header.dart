import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../state/agent_state.dart';
import '../../../../state/app_state.dart';

class HomeHeader extends ConsumerWidget {
  final String greeting;
  final String farmerName;
  final String location;
  final String roleLabel;

  const HomeHeader({
    super.key,
    required this.greeting,
    required this.farmerName,
    required this.location,
    required this.roleLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 480;
    final agentState = ref.watch(agentProvider);
    final agentNotifier = ref.read(agentProvider.notifier);
    final appState = ref.watch(appStateProvider);
    final appNotifier = ref.read(appStateProvider.notifier);

    const avatar = CircleAvatar(
      radius: 24,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.agriculture_outlined,
        color: Color(0xFF16A34A),
        size: 26,
      ),
    );

    final details = Column(
      crossAxisAlignment: isNarrow ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $farmerName',
          style: GoogleFonts.inter(
            fontSize: isNarrow ? 20 : 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          '$roleLabel dashboard • $location',
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.92),
            fontWeight: FontWeight.w500,
            fontSize: isNarrow ? 12 : 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        const _LiveClockWidget(),
      ],
    );

    final currencySelector = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white38),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AppCurrency>(
          value: appState.currency,
          isDense: true,
          menuMaxHeight: 200,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
          dropdownColor: const Color(0xFF0F172A),
          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
          onChanged: (c) {
            if (c != null) appNotifier.setCurrency(c);
          },
          items: AppCurrency.values.map((c) {
            return DropdownMenuItem<AppCurrency>(
              value: c,
              child: Text('${c.flag} ${c.code}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            );
          }).toList(),
        ),
      ),
    );

    final agentModeToggle = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: agentState.isAgentModeOn
            ? const Color(0xFF22C55E).withOpacity(0.25)
            : Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: agentState.isAgentModeOn ? const Color(0xFF4ADE80) : Colors.white24,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            agentState.isAgentModeOn ? Icons.record_voice_over : Icons.voice_over_off,
            color: agentState.isAgentModeOn ? const Color(0xFF4ADE80) : Colors.white70,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            agentState.isAgentModeOn ? 'Agent ON' : 'Agent OFF',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Switch(
            value: agentState.isAgentModeOn,
            onChanged: (_) => agentNotifier.toggleAgentMode(),
            activeColor: const Color(0xFF4ADE80),
            activeTrackColor: const Color(0xFF15803D),
            inactiveThumbColor: Colors.white70,
            inactiveTrackColor: Colors.white24,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF0F766E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: isNarrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    avatar,
                    currencySelector,
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: details),
                    const SizedBox(width: 8),
                    agentModeToggle,
                  ],
                ),
              ],
            )
          : Row(
              children: [
                avatar,
                const SizedBox(width: 12),
                Expanded(child: details),
                const SizedBox(width: 12),
                currencySelector,
                const SizedBox(width: 10),
                agentModeToggle,
              ],
            ),
    );
  }
}

class _LiveClockWidget extends StatefulWidget {
  const _LiveClockWidget();

  @override
  State<_LiveClockWidget> createState() => _LiveClockWidgetState();
}

class _LiveClockWidgetState extends State<_LiveClockWidget> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${_now.hour.toString().padLeft(2, '0')}:${_now.minute.toString().padLeft(2, '0')}:${_now.second.toString().padLeft(2, '0')}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.access_time_rounded, color: Colors.white70, size: 13),
        const SizedBox(width: 4),
        Text(
          timeStr,
          style: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
