import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../models/geospatial_models.dart';
import '../providers/geospatial_providers.dart';
import '../widgets/task_card.dart';

class ScoutingTasksPage extends ConsumerStatefulWidget {
  const ScoutingTasksPage({super.key});

  @override
  ConsumerState<ScoutingTasksPage> createState() => _ScoutingTasksPageState();
}

class _ScoutingTasksPageState extends ConsumerState<ScoutingTasksPage> {
  final MapController _mapController = MapController();
  LatLng _mapCenter = LatLng(-19.5, 30.5);

  LatLng _getPolygonCenter(List<LatLng> points) {
    double latSum = 0;
    double lngSum = 0;
    for (final p in points) {
      latSum += p.latitude;
      lngSum += p.longitude;
    }
    return LatLng(latSum / points.length, lngSum / points.length);
  }

  void _showAddTaskDialog() {
    final fields = ref.read(geoFieldsProvider);
    if (fields.isEmpty) return;

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final assigneeController = TextEditingController();
    final dateController = TextEditingController();
    String selectedFieldId = fields.first.id;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Schedule Scouting Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Task Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedFieldId,
                      decoration: const InputDecoration(labelText: 'Assign to Field'),
                      items: fields.map((f) {
                        return DropdownMenuItem(value: f.id, child: Text(f.name));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setDialogState(() => selectedFieldId = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: assigneeController,
                      decoration: const InputDecoration(labelText: 'Assignee'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateController,
                      decoration: const InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
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
                    if (title.isEmpty) return;

                    final field = fields.firstWhere((f) => f.id == selectedFieldId);
                    final center = _getPolygonCenter(field.boundary);

                    final newTask = GeoTask(
                      id: 'TSK-${DateTime.now().millisecondsSinceEpoch}',
                      fieldId: selectedFieldId,
                      title: title,
                      description: descController.text.trim(),
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
                  child: const Text('Save Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(geoTasksProvider);
    final fields = ref.watch(geoFieldsProvider);

    final markers = tasks.where((t) => t.position != null).map((task) {
      final completed = task.status.toLowerCase() == 'completed';
      return Marker(
        point: task.position!,
        width: 32,
        height: 32,
        child: Container(
          decoration: BoxDecoration(
            color: completed ? Colors.green.shade600 : Colors.blue.shade600,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          ),
          child: Icon(
            completed ? Icons.check : Icons.assignment_outlined,
            color: Colors.white,
            size: 16,
          ),
        ),
      );
    }).toList();

    // Map overlays of fields in subtle dashed boundaries
    final polygons = fields.map((f) {
      return Polygon(
        points: f.boundary,
        color: Colors.black.withOpacity(0.02),
        borderColor: Colors.black12,
        borderStrokeWidth: 1.0,
      );
    }).toList();

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    final mapWidget = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _mapCenter,
            initialZoom: 7.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.verdi.app',
            ),
            PolygonLayer(polygons: polygons),
            MarkerLayer(markers: markers),
          ],
        ),
      ),
    );

    final listWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Field Scouting Tasks',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showAddTaskDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (tasks.isEmpty)
          const Expanded(
            child: Center(
              child: Text('No scheduled scouting tasks. Click New Task to create one.', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      if (task.position != null) {
                        setState(() {
                          _mapCenter = task.position!;
                        });
                        _mapController.move(task.position!, 13.0);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: TaskCard(
                      task: task,
                      onToggleStatus: () => ref.read(geoTasksProvider.notifier).toggleTaskStatus(task.id),
                      onDelete: () => ref.read(geoTasksProvider.notifier).removeTask(task.id),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Scouting Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: mapWidget),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: listWidget),
                ],
              )
            : Column(
                children: [
                  Expanded(flex: 2, child: mapWidget),
                  const SizedBox(height: 16),
                  Expanded(flex: 3, child: listWidget),
                ],
              ),
      ),
    );
  }
}
