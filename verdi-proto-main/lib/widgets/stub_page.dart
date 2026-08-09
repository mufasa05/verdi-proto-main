import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StubPage extends StatelessWidget {
  final String title;
  final String subtitle;

  const StubPage({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction_outlined, size: 72, color: Colors.green.shade700),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}