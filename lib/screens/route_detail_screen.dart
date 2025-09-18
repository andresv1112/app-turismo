import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sendero_seguro/models/safe_route.dart';

class RouteDetailScreen extends StatefulWidget {
  final SafeRoute route;

  const RouteDetailScreen({
    super.key,
    required this.route,
  });

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMapElements();
  }

  void _setupMapElements() {
    // Crear marcadores para cada punto de la ruta
    _markers = widget.route.points.asMap().entries.map((entry) {
      final index = entry.key;
      final point = entry.value;
      
      return Marker(
        markerId: MarkerId('point_$index'),
        position: LatLng(point.latitude, point.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          index == 0 
            ? BitmapDescriptor.hueGreen
            : index == widget.route.points.length - 1
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueBlue,
        ),
        infoWindow: InfoWindow(
          title: point.name ?? 'Punto ${index + 1}',
          snippet: point.description,
        ),
      );
    }).toSet();

    // Crear la línea de la ruta
    if (widget.route.points.length > 1) {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: widget.route.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList(),
          color: Colors.blue,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      };
    } else {
      _polylines = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.route.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.route.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(widget.route.difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getDifficultyColor(widget.route.difficulty),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          widget.route.difficulty,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: _getDifficultyColor(widget.route.difficulty),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        '${widget.route.estimatedDuration.toStringAsFixed(1)} horas',
                        Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.location_on,
                        '${widget.route.points.length} puntos',
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.route.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    '🗺️ Mapa de la Ruta',
                    _buildMapView(),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    '🎯 Atracciones',
                    _buildAttractionsList(),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    '💡 Consejos',
                    _buildTipsList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildMapView() {
    if (widget.route.points.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No hay puntos de ruta disponibles'),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.route.points.first.latitude,
              widget.route.points.first.longitude,
            ),
            zoom: 14,
          ),
          markers: _markers,
          polylines: _polylines
              .map((polyline) => polyline.copyWith(
                    colorParam: Theme.of(context).colorScheme.primary,
                  ))
              .toSet(),
          mapType: MapType.terrain,
        ),
      ),
    );
  }

  Widget _buildAttractionsList() {
    return Column(
      children: widget.route.attractions.map((attraction) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.star,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                attraction,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildTipsList() {
    return Column(
      children: widget.route.tips.map((tip) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                tip,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
        return Colors.green;
      case 'moderada':
        return Colors.orange;
      case 'difícil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}