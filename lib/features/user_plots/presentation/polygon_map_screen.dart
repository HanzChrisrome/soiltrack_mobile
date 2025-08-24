import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';

class PolygonMapScreen extends ConsumerStatefulWidget {
  const PolygonMapScreen({super.key});

  @override
  _PolygonMapScreenState createState() => _PolygonMapScreenState();
}

class _PolygonMapScreenState extends ConsumerState<PolygonMapScreen> {
  final MapControllerImpl _mapController = MapControllerImpl();
  List<LatLng> polygonPoints = [];

  // Change to hold polygon with name pairs
  List<MapEntry<String, List<LatLng>>> existingPolygons = [];
  List<LatLng>? selectedPolygon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePolygons();
    });
  }

  Future<void> _initializePolygons() async {
    final soilState = ref.read(soilDashboardProvider);
    final plots = soilState.userPlots;
    final selectedId = soilState.selectedPlotId;

    final polygons = _extractOtherPolygons(plots);

    final selectedPlot = plots.firstWhere(
      (plot) => plot['plot_id'] == selectedId,
      orElse: () => {},
    );

    final raw = selectedPlot['polygons'];
    if (raw != null) {
      try {
        final parsed = raw is String ? jsonDecode(raw) : raw;

        selectedPolygon = (parsed as List)
            .map<LatLng?>((coord) {
              if (coord is List &&
                  coord.length == 2 &&
                  coord[0] is num &&
                  coord[1] is num) {
                return LatLng(
                  (coord[0] as num).toDouble(),
                  (coord[1] as num).toDouble(),
                );
              } else if (coord is Map &&
                  coord.containsKey('lat') &&
                  coord.containsKey('lng') &&
                  coord['lat'] is num &&
                  coord['lng'] is num) {
                return LatLng(
                  (coord['lat'] as num).toDouble(),
                  (coord['lng'] as num).toDouble(),
                );
              }
              return null;
            })
            .whereType<LatLng>()
            .toList();

        if (selectedPolygon!.length < 3) {
          NotifierHelper.logError(
            'Selected polygon has fewer than 3 points: $selectedPolygon',
          );
          selectedPolygon = null;
        }
      } catch (e) {
        NotifierHelper.logError(
          'Error parsing selected plot polygon: $e - Raw: $raw',
        );
      }
    }

    await Future.delayed(const Duration(milliseconds: 300));

    if (selectedPolygon != null && selectedPolygon!.length >= 3) {
      final bounds = LatLngBounds.fromPoints(selectedPolygon!);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    } else if (polygons.isNotEmpty) {
      final allPoints = polygons.expand((entry) => entry.value).toList();
      final bounds = LatLngBounds.fromPoints(allPoints);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    } else {
      _mapController.move(LatLng(14.95901725, 120.8968935), 17);
    }

    setState(() {
      existingPolygons = polygons;
    });
  }

  @override
  Widget build(BuildContext context) {
    final soilDashboardNotifier = ref.read(soilDashboardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tap to Draw Polygon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (polygonPoints.length >= 3) {
                soilDashboardNotifier.uploadPolygon(context, polygonPoints);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Need at least 3 points to form a polygon'),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                polygonPoints.clear();
              });
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(14.95901725, 120.8968935),
          initialZoom: 17,
          onTap: (tapPosition, latlng) {
            setState(() {
              polygonPoints.add(latlng);
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          PolygonLayer(
            polygons: [
              // Existing polygons polygons in blue
              ...existingPolygons.map(
                (entry) => Polygon(
                  points: entry.value,
                  color: Colors.blue.withOpacity(0.3),
                  borderColor: Colors.blue,
                  borderStrokeWidth: 2,
                ),
              ),

              // Selected polygon in orange
              if (selectedPolygon != null)
                Polygon(
                  points: selectedPolygon!,
                  color: Colors.orange.withOpacity(0.4),
                  borderColor: Colors.orange,
                  borderStrokeWidth: 3,
                ),

              // Polygon currently being drawn in green
              if (polygonPoints.length >= 3)
                Polygon(
                  points: polygonPoints,
                  color: Colors.green.withOpacity(0.4),
                  borderColor: Colors.green,
                  borderStrokeWidth: 3,
                ),
            ],
          ),
          MarkerLayer(
            markers: [
              ...existingPolygons.expand((entry) sync* {
                // Points markers
                for (var point in entry.value) {
                  yield Marker(
                    width: 30,
                    height: 30,
                    point: point,
                    child: const Icon(
                      Icons.circle,
                      color: Colors.blue,
                      size: 12,
                    ),
                  );
                }
                // Label marker at center of polygon
                final center = _calculateBoundingCenter(entry.value);
                yield Marker(
                  point: center,
                  width: 120,
                  height: 30,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),

              // Markers for selected polygon points
              if (selectedPolygon != null)
                ...selectedPolygon!.map(
                  (point) => Marker(
                    width: 30,
                    height: 30,
                    point: point,
                    child: const Icon(
                      Icons.circle,
                      color: Colors.orange,
                      size: 14,
                    ),
                  ),
                ),

              // Markers for polygon points being drawn
              ...polygonPoints.map(
                (point) => Marker(
                  width: 30,
                  height: 30,
                  point: point,
                  child: const Icon(
                    Icons.circle,
                    color: Colors.red,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<MapEntry<String, List<LatLng>>> _extractOtherPolygons(
      List<Map<String, dynamic>> plots) {
    List<MapEntry<String, List<LatLng>>> result = [];

    for (var plot in plots) {
      final raw = plot['polygons'];
      if (raw == null) continue;

      try {
        final parsed = raw is String ? jsonDecode(raw) : raw;

        final polygon = (parsed as List)
            .map<LatLng?>((coord) {
              if (coord is List &&
                  coord.length == 2 &&
                  coord[0] != null &&
                  coord[1] != null &&
                  coord[0] is num &&
                  coord[1] is num) {
                return LatLng(
                  (coord[0] as num).toDouble(),
                  (coord[1] as num).toDouble(),
                );
              } else if (coord is Map &&
                  coord.containsKey('lat') &&
                  coord.containsKey('lng') &&
                  coord['lat'] is num &&
                  coord['lng'] is num) {
                return LatLng(
                  (coord['lat'] as num).toDouble(),
                  (coord['lng'] as num).toDouble(),
                );
              }
              return null;
            })
            .whereType<LatLng>()
            .toList();

        if (polygon.length >= 3) {
          final plotName = plot['plot_name']?.toString() ?? 'Unnamed Plot';
          result.add(MapEntry(plotName, polygon));
        } else {
          NotifierHelper.logError(
            'Polygon has fewer than 3 points: $polygon from raw: $raw',
          );
        }
      } catch (e) {
        NotifierHelper.logError('Error parsing polygon: $e - Raw: $raw');
      }
    }

    return result;
  }

  LatLng _calculateBoundingCenter(List<LatLng> points) {
    if (points.isEmpty) {
      return LatLng(0, 0);
    }

    double minLat = points[0].latitude;
    double maxLat = points[0].latitude;
    double minLng = points[0].longitude;
    double maxLng = points[0].longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
  }
}
