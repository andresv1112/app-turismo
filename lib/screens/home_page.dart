import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sendero_seguro/services/location_service.dart';
import 'package:sendero_seguro/services/storage_service.dart';
import 'package:sendero_seguro/models/danger_zone.dart';
import 'package:sendero_seguro/screens/routes_screen.dart';
import 'package:sendero_seguro/screens/reports_screen.dart';
import 'package:sendero_seguro/widgets/danger_zone_dialog.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  List<DangerZone> _dangerZones = [];
  Set<Circle> _circles = {};
  Set<Marker> _markers = {};
  StreamSubscription<Position>? _positionStream;
  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService.instance;
  int _selectedIndex = 0;
  bool _isDangerDialogOpen = false;
  String? _lastAlertedZoneId;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadDangerZones();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final status = await _locationService.requestLocationPermission();
    if (!mounted) return;

    if (status == PermissionStatus.permanentlyDenied) {
      _showPermissionDialog(status);
      return;
    }

    if (status != PermissionStatus.granted && status != PermissionStatus.limited) {
      _showPermissionDialog(status);
      return;
    }

    final position = await _locationService.getCurrentLocation(requestPermission: false);
    if (position != null && mounted) {
      setState(() => _currentPosition = position);
      _startLocationTracking();
    }
  }

  void _startLocationTracking() {
    _positionStream = _locationService.getLocationStream().listen((position) {
      if (mounted) {
        setState(() => _currentPosition = position);
        _checkDangerZones(position);
        _updateMapCamera(position);
      }
    });
  }

  void _checkDangerZones(Position position) {
    DangerZone? detectedZone;

    for (final zone in _dangerZones) {
      if (_locationService.isInsideDangerZone(position, zone)) {
        detectedZone = zone;
        break;
      }
    }

    if (detectedZone == null) {
      _lastAlertedZoneId = null;
      return;
    }

    if (_isDangerDialogOpen) {
      return;
    }

    if (_lastAlertedZoneId == detectedZone.id) {
      return;
    }

    _showDangerZoneAlert(detectedZone);
  }

  void _showDangerZoneAlert(DangerZone zone) {
    if (_isDangerDialogOpen) {
      return;
    }

    _isDangerDialogOpen = true;
    _lastAlertedZoneId = zone.id;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DangerZoneDialog(zone: zone),
    ).whenComplete(() {
      _isDangerDialogOpen = false;

      if (!mounted) {
        return;
      }

      if (_currentPosition != null) {
        _checkDangerZones(_currentPosition!);
      }
    });
  }

  void _updateMapCamera(Position position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
  }

  Future<void> _loadDangerZones() async {
    final zones = await _storageService.getDangerZones();
    if (mounted) {
      setState(() {
        _dangerZones = zones;
        _updateMapElements();
      });
    }
  }

  void _updateMapElements() {
    _circles = _dangerZones.map((zone) => Circle(
      circleId: CircleId(zone.id),
      center: LatLng(zone.latitude, zone.longitude),
      radius: zone.radius,
      strokeColor: Colors.red.withValues(alpha: 0.8),
      strokeWidth: 2,
      fillColor: Colors.red.withValues(alpha: 0.2),
    )).toSet();

    _markers = _dangerZones.map((zone) => Marker(
      markerId: MarkerId('danger_${zone.id}'),
      position: LatLng(zone.latitude, zone.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: '⚠️ ${zone.title}',
        snippet: zone.description,
      ),
      onTap: () => _showDangerZoneAlert(zone),
    )).toSet();

    if (_currentPosition != null) {
      _markers.add(Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(
          title: '📍 Mi Ubicación',
          snippet: 'Estás aquí',
        ),
      ));
    }
  }

  void _showPermissionDialog(PermissionStatus status) {
    final isPermanentlyDenied = status == PermissionStatus.permanentlyDenied;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permisos de Ubicación'),
        content: Text(
          isPermanentlyDenied
              ? 'Parece que el permiso de ubicación está bloqueado. Ábrelo en los ajustes del dispositivo para habilitarlo y poder mostrarte las zonas de peligro cercanas.'
              : 'Esta aplicación necesita acceso a tu ubicación para mostrarte las zonas de peligro cercanas y mantenerte seguro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (isPermanentlyDenied) {
                await openAppSettings();
                if (!mounted) return;
                await _initializeLocation();
              } else {
                await _initializeLocation();
              }
            },
            child: Text(isPermanentlyDenied ? 'Abrir ajustes' : 'Permitir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🥾 Sendero Seguro'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _currentPosition != null ? () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  15,
                ),
              );
            } : null,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildMapView(),
          const RoutesScreen(),
          const ReportsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: 'Rutas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    if (_currentPosition == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Obteniendo ubicación...'),
          ],
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        zoom: 14,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      circles: _circles,
      markers: _markers,
      mapType: MapType.hybrid,
      onTap: (latLng) {
        // Opcional: agregar funcionalidad al tocar el mapa
      },
    );
  }
}