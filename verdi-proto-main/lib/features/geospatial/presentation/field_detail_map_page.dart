import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/geospatial_models.dart';
import '../providers/geospatial_providers.dart';
import '../widgets/observation_card.dart';
import '../widgets/task_card.dart';

class FieldDetailMapPage extends ConsumerStatefulWidget {
  final String fieldId;

  const FieldDetailMapPage({super.key, required this.fieldId});

  @override
  ConsumerState<FieldDetailMapPage> createState() => _FieldDetailMapPageState();
}

class _FieldDetailMapPageState extends ConsumerState<FieldDetailMapPage> {
  final MapController _mapController = MapController();

  // Find center of polygon coordinates
  LatLng _getPolygonCenter(List<LatLng> points) {
    double latSum = 0;
    double lngSum = 0;
    for (final p in points) {
      latSum += p.latitude;
      lngSum += p.longitude;
    }
    return LatLng(latSum / points.length, lngSum / points.length);
  }

  void _showAddTaskDialog(String fieldId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final assigneeController = TextEditingController();
    final dateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Schedule Scouting Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Task Title', hintText: 'e.g. Inspect drainage'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description', hintText: 'What needs to be done...'),
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: assigneeController,
                  decoration: const InputDecoration(labelText: 'Assignee Name', hintText: 'e.g. Joshua N.'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Due Date', hintText: 'YYYY-MM-DD'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null) {
                      dateController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                if (title.isEmpty) return;

                final field = ref.read(geoFieldsProvider).firstWhere((f) => f.id == fieldId);
                final center = _getPolygonCenter(field.boundary);

                final newTask = GeoTask(
                  id: 'TSK-${DateTime.now().millisecondsSinceEpoch}',
                  fieldId: fieldId,
                  title: title,
                  description: desc,
                  position: center,
                  assignee: assigneeController.text.isEmpty ? 'Unassigned' : assigneeController.text.trim(),
                  status: 'Pending',
                  dueDate: dateController.text.isEmpty ? '2026-06-30' : dateController.text.trim(),
                );

                ref.read(geoTasksProvider.notifier).addTask(newTask);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Schedule'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(geoFieldsProvider);
    final zones = ref.watch(geoZonesProvider);
    final observations = ref.watch(geoObservationsProvider);
    final tasks = ref.watch(geoTasksProvider);
    final settings = ref.watch(geoLayerSettingsProvider);

    final field = fields.firstWhere((f) => f.id == widget.fieldId, orElse: () => fields.first);
    final fieldCenter = _getPolygonCenter(field.boundary);

    final fieldZones = zones.where((z) => z.fieldId == field.id).toList();
    final fieldObs = observations.where((o) => o.fieldId == field.id).toList();
    final fieldTasks = tasks.where((t) => t.fieldId == field.id).toList();

    // Map overlay items
    final polygons = <Polygon>[
      Polygon(
        points: field.boundary,
        color: const Color(0xFF16A34A).withOpacity(0.12),
        borderColor: const Color(0xFF16A34A),
        borderStrokeWidth: 3,
        isFilled: true,
      ),
    ];

    // Add subzones as dashed outline polygons inside
    for (final zone in fieldZones) {
      polygons.add(
        Polygon(
          points: zone.boundary,
          color: Colors.blue.withOpacity(0.08),
          borderColor: Colors.blue,
          borderStrokeWidth: 1.5,
          isFilled: true,
        ),
      );
    }

    // Interactive observation and task markers
    final markers = <Marker>[];
    for (final obs in fieldObs) {
      final severityColor = obs.severity == 'High' ? Colors.red : obs.severity == 'Medium' ? Colors.orange : Colors.blue;
      markers.add(
        Marker(
          point: obs.position,
          width: 32,
          height: 32,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: severityColor, width: 2),
            ),
            child: Icon(Icons.bug_report, color: severityColor, size: 16),
          ),
        ),
      );
    }

    for (final task in fieldTasks) {
      if (task.position != null) {
        markers.add(
          Marker(
            point: task.position!,
            width: 30,
            height: 30,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(Icons.assignment_outlined, color: Colors.white, size: 14),
            ),
          ),
        );
      }
    }

    // Historical NDVI crop health chart data (mock progression)
    final chartData = [
      _NdviData('May 01', 0.65),
      _NdviData('May 15', 0.72),
      _NdviData('Jun 01', 0.78),
      _NdviData('Jun 15', 0.82),
      _NdviData('Jun 24', field.healthScore),
    ];

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 950;

    final tileUrl = settings.showSatellite
        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    final leftMapSection = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: fieldCenter,
              initialZoom: 13.8,
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                userAgentPackageName: 'com.verdi.app',
              ),
              PolygonLayer(polygons: polygons),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
              ),
              child: const Text('Field Bounds & Local Pins', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );

    final rightPanelSection = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            children: [
              Text(
                field.name,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddTaskDialog(field.id),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Crop: ${field.crop} • Hectares: ${field.hectares.toStringAsFixed(1)} ha • NDVI: ${field.healthScore.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // NDVI Chart
          Container(
            height: 180,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: SfCartesianChart(
              title: const ChartTitle(
                text: 'Historical NDVI Health Trend',
                textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              primaryXAxis: const CategoryAxis(),
              series: <CartesianSeries<_NdviData, String>>[
                LineSeries<_NdviData, String>(
                  dataSource: chartData,
                  xValueMapper: (_NdviData data, _) => data.date,
                  yValueMapper: (_NdviData data, _) => data.ndvi,
                  color: const Color(0xFF16A34A),
                  width: 3.5,
                  markerSettings: const MarkerSettings(isVisible: true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Scouting pins
          Text(
            'Field Observations (${fieldObs.length})',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (fieldObs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No scouting observations registered for this field.', style: TextStyle(color: Colors.grey)),
            )
          else
            Column(
              children: fieldObs.map((obs) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ObservationCard(
                    observation: obs,
                    onDelete: () => ref.read(geoObservationsProvider.notifier).removeObservation(obs.id),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),

          // Active Tasks
          Text(
            'Linked Tasks (${fieldTasks.length})',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (fieldTasks.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('No active tasks scheduled on this field.', style: TextStyle(color: Colors.grey)),
            )
          else
            Column(
              children: fieldTasks.map((task) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskCard(
                    task: task,
                    onToggleStatus: () => ref.read(geoTasksProvider.notifier).toggleTaskStatus(task.id),
                    onDelete: () => ref.read(geoTasksProvider.notifier).removeTask(task.id),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${field.name} Detail Map'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: leftMapSection),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: rightPanelSection),
                  ],
                )
              : Column(
                  children: [
                    Expanded(flex: 2, child: leftMapSection),
                    const SizedBox(height: 16),
                    Expanded(flex: 3, child: rightPanelSection),
                  ],
                ),
        ),
      ),
    );
  }
}

class _NdviData {
  final String date;
  final double ndvi;

  _NdviData(this.date, this.ndvi);
}
