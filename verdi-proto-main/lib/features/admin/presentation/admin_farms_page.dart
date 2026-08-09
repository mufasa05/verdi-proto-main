import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:verdi/core/ai_data/ai_data_providers.dart';
import 'package:verdi/core/ai_data/ai_data_repository.dart';
import 'package:verdi/features/geospatial/models/geospatial_models.dart';

class AdminFarmsPage extends ConsumerWidget {
  const AdminFarmsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(aiDataRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin — Farms')),
      body: FutureBuilder<List<GeoFarm>>(
        future: repo.fetchAllFarms(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          final farms = snap.data ?? [];
          if (farms.isEmpty) return const Center(child: Text('No farms available'));
          return ListView.builder(
            itemCount: farms.length,
            itemBuilder: (context, idx) {
              final farm = farms[idx];
              return Card(
                child: ListTile(
                  title: Text(farm.name),
                  subtitle: Text('Owner: ${farm.owner} — ${farm.region}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'export') {
                        await _exportFarm(context, repo, farm);
                      } else if (v == 'view') {
                        final fields = await repo.fetchFields(farm.id);
                        if (!context.mounted) return;
                        await showDialog<void>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text('Fields — ${farm.name}'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView(children: fields.map((f) => ListTile(title: Text(f.name), subtitle: Text('${f.crop} • ${f.hectares} ha • health ${f.healthScore}'))).toList()),
                            ),
                            actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
                          ),
                        );
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'view', child: Text('View fields')),
                      PopupMenuItem(value: 'export', child: Text('Export JSON')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _exportFarm(BuildContext context, AiDataRepository repo, GeoFarm farm) async {
    final fields = await repo.fetchFields(farm.id);
    final obj = {
      'farm': {
        'id': farm.id,
        'name': farm.name,
        'owner': farm.owner,
        'region': farm.region,
      },
      'fields': fields.map((f) => {
        'id': f.id,
        'name': f.name,
        'crop': f.crop,
        'hectares': f.hectares,
        'healthScore': f.healthScore,
        'status': f.status,
      }).toList(),
    };

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/export_farm_${farm.id}.json');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(obj));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to ${file.path}')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }
}
