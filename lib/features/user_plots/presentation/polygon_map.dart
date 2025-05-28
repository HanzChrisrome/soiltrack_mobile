import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:turf/turf.dart' as turf;

class PolygonMap extends ConsumerWidget {
  final List<LatLng> polygonPoints;
  const PolygonMap({super.key, required this.polygonPoints});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (polygonPoints.isEmpty) {
      return const Center(
        child: Text('No points selected'),
      );
    }

    final center = _findPolygonCenter(polygonPoints);

    final areaInHectares = _calculateAreaInHectares(polygonPoints);

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 19,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        PolygonLayer(
          polygons: [
            Polygon(
              points: polygonPoints,
              color: Colors.green.withOpacity(0.3),
              borderColor: Colors.green,
              borderStrokeWidth: 2,
            ),
          ],
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 70,
              height: 70,
              point: center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 30,
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      '${areaInHectares.toStringAsFixed(2)} ha',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  LatLng _findPolygonCenter(List<LatLng> points) {
    double lat = 0;
    double lng = 0;
    for (var point in points) {
      lat += point.latitude;
      lng += point.longitude;
    }
    lat = lat / points.length;
    lng = lng / points.length;
    return LatLng(lat, lng);
  }

  double _calculateAreaInHectares(List<LatLng> points) {
    // ✅ Corrected: use Position.of()
    final coordinates = points
        .map((point) => turf.Position.of([point.longitude, point.latitude]))
        .toList();

    final polygon = turf.Polygon(
      coordinates: [coordinates],
    );

    final areaInSquareMeters = turf.area(polygon);
    final areaInHectares = areaInSquareMeters! / 10000;
    return areaInHectares;
  }
}
