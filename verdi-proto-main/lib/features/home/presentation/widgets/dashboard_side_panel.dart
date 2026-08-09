import 'package:flutter/material.dart';

class DashboardSidePanel extends StatelessWidget {
  const DashboardSidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _PanelCard(
            title: 'Today at a glance',
            child: Column(
              children: const [
                _SideStat(label: 'Pending messages', value: '4'),
                _SideStat(label: 'Unconfirmed orders', value: '2'),
                _SideStat(label: 'Weather risk', value: 'Low'),
                _SideStat(label: 'Transport match', value: '3 nearby'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _PanelCard(
            title: 'Nearby market tips',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Tip(text: 'Post tomatoes before 10 AM for faster buyer response.'),
                _Tip(text: 'Bundle maize with transport to improve conversion.'),
                _Tip(text: 'Use crop photos in listings to increase trust.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _PanelCard(
            title: 'Saved shortcuts',
            child: Column(
              children: const [
                _ShortcutTile(label: 'Open marketplace'),
                _ShortcutTile(label: 'Check logistics'),
                _ShortcutTile(label: 'Review analytics'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _PanelCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SideStat extends StatelessWidget {
  final String label;
  final String value;

  const _SideStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _Tip extends StatelessWidget {
  final String text;

  const _Tip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final String label;

  const _ShortcutTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.arrow_forward_ios, size: 16),
      title: Text(label),
      onTap: () {},
    );
  }
}