import 'package:flutter/material.dart';
import 'section_header.dart';

class VerdiPageScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget>? actions;

  const VerdiPageScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: MediaQuery.of(context).size.width < 600 ? const EdgeInsets.all(12) : const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SectionHeader(
                        title: title,
                        subtitle: subtitle,
                      ),
                    ),
                    ...?actions,
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}