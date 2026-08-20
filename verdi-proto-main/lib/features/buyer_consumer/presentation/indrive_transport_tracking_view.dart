import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InDriveChatMessage {
  final String sender; // 'user' or 'driver'
  final String text;
  final DateTime time;

  InDriveChatMessage({required this.sender, required this.text, required this.time});
}

/// InDrive-Style Live Transport Tracking & Direct Driver Messenger for End-Users / Consumers
class InDriveTransportTrackingView extends StatefulWidget {
  final VoidCallback? onBack;
  const InDriveTransportTrackingView({super.key, this.onBack});

  @override
  State<InDriveTransportTrackingView> createState() => _InDriveTransportTrackingViewState();
}

class _InDriveTransportTrackingViewState extends State<InDriveTransportTrackingView> {
  int _tripStage = 2; // 0: Assigned, 1: Pickup, 2: En Route, 3: Arrived
  int _etaMinutes = 8;
  Timer? _etaTimer;

  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<InDriveChatMessage> _messages = [
    InDriveChatMessage(sender: 'driver', text: 'Hello! I have loaded your 2 crates of fresh tomatoes and sweetcorn from Mbare Musika hub.', time: DateTime.now().subtract(const Duration(minutes: 6))),
    InDriveChatMessage(sender: 'user', text: 'Thank you Blessing! Please handle the tomatoes gently.', time: DateTime.now().subtract(const Duration(minutes: 4))),
    InDriveChatMessage(sender: 'driver', text: 'Will do! Everything is cushioned in cold-crate bins. Passing Enterprise Road now, 8 mins away.', time: DateTime.now().subtract(const Duration(minutes: 2))),
  ];

  @override
  void initState() {
    super.initState();
    // Simulate countdown of ETA
    _etaTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_etaMinutes > 1) {
        setState(() {
          _etaMinutes--;
        });
      } else if (_etaMinutes == 1) {
        setState(() {
          _etaMinutes = 0;
          _tripStage = 3;
        });
      }
    });
  }

  @override
  void dispose() {
    _etaTimer?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(InDriveChatMessage(sender: 'user', text: text.trim(), time: DateTime.now()));
      _msgController.clear();
    });

    _scrollToBottom();

    // Driver auto-response simulation after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      String reply = 'Got it! Following your delivery instructions now.';
      if (text.contains('gate') || text.contains('where')) {
        reply = 'I am right around the corner on the main avenue. See you in 2 mins!';
      } else if (text.contains('care') || text.contains('fragile')) {
        reply = 'Don’t worry, cargo is secured with protective straps and thermal blankets.';
      }

      setState(() {
        _messages.add(InDriveChatMessage(sender: 'driver', text: reply, time: DateTime.now()));
      });
      _scrollToBottom();

      // Show in-app push pop-up notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: Color(0xFF10B981),
                child: Icon(Icons.local_shipping, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Driver Blessing: "$reply"', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                if (widget.onBack != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                    onPressed: widget.onBack,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('LIVE IN-DRIVE TRACKING', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 8),
                          Text('Order #VRD-88219', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Fresh Farmgate Delivery • 2 Crates Grade A Produce', style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Color(0xFF10B981), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _etaMinutes > 0 ? 'ETA $_etaMinutes MINS' : 'DRIVER ARRIVED',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Interactive Body: Map Simulation (Top/Left) + Direct Chat (Bottom/Right)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 850;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 5, child: _buildMapAndDriverCard()),
                      Container(width: 1, color: const Color(0xFFE2E8F0)),
                      Expanded(flex: 4, child: _buildMessengerPanel()),
                    ],
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMapAndDriverCard(),
                      const SizedBox(height: 12),
                      SizedBox(height: 480, child: _buildMessengerPanel()),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapAndDriverCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Simulated Interactive GPS Map
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF1E293B)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  // Vector Grid / GPS Simulation Background
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GpsRoutePainter(tripStage: _tripStage),
                    ),
                  ),

                  // Top Overlay Info Tag
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Route: Mbare Farm Hub ➔ Avondale Delivery',
                            style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Live Moving Transporter Vehicle Marker
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF10B981).withOpacity(0.4), blurRadius: 16, spreadRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.local_shipping, color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Driver Profile & Vehicle Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFF0F172A),
                  child: Text('BC', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Blessing Chisora', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('Toyota Hilux 1-Ton • Reg: AFE-9912', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Color(0xFFF59E0B), size: 14),
                          const SizedBox(width: 4),
                          const Text('4.9 (184 trips)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Cold-Chain Verified', style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling Driver Blessing (+263 77 912 4001)...'), backgroundColor: Color(0xFF10B981)),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone, color: Color(0xFF10B981), size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessengerPanel() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Messenger Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline, color: Color(0xFF10B981), size: 18),
                const SizedBox(width: 8),
                Text('Direct Driver Chat', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF0F172A))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                      SizedBox(width: 5),
                      Text('Driver Online', style: TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Message Bubble Stream
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.sender == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF10B981) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: isUser ? Colors.white70 : Colors.grey.shade500,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Quick Prompt Response Chips
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildQuickChip('📍 I am at the gate'),
                _buildQuickChip('🍅 Please handle with care'),
                _buildQuickChip('📞 Please call upon arrival'),
                _buildQuickChip('⏳ Where are you now?'),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Message Input Field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Type a message to driver...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFF10B981)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _sendMessage(_msgController.text),
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A), fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFF1F5F9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        onPressed: () => _sendMessage(label),
      ),
    );
  }
}

class _GpsRoutePainter extends CustomPainter {
  final int tripStage;
  _GpsRoutePainter({required this.tripStage});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw route path line
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.5, size.width * 0.8, size.height * 0.2);

    final routePaint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, routePaint);

    // Origin marker (Farm Gate)
    final originPaint = Paint()..color = const Color(0xFF3B82F6);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), 8, originPaint);

    // Destination marker (Customer Address)
    final destPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 8, destPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
