import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sendero_seguro/models/danger_zone.dart';
import 'package:sendero_seguro/models/safe_route.dart';
import 'package:sendero_seguro/models/report.dart';

class StorageService {
  static const String _dangerZonesKey = 'danger_zones';
  static const String _safeRoutesKey = 'safe_routes';
  static const String _reportsKey = 'reports';

  // Zones de peligro
  Future<List<DangerZone>> getDangerZones() async {
    final prefs = await SharedPreferences.getInstance();
    final zonesJson = prefs.getString(_dangerZonesKey);
    
    if (zonesJson == null) {
      // Inicializar con datos predefinidos
      final defaultZones = _getDefaultDangerZones();
      await saveDangerZones(defaultZones);
      return defaultZones;
    }

    final zonesList = jsonDecode(zonesJson) as List;
    return zonesList.map((json) => DangerZone.fromJson(json)).toList();
  }

  Future<void> saveDangerZones(List<DangerZone> zones) async {
    final prefs = await SharedPreferences.getInstance();
    final zonesJson = jsonEncode(zones.map((z) => z.toJson()).toList());
    await prefs.setString(_dangerZonesKey, zonesJson);
  }

  // Rutas seguras
  Future<List<SafeRoute>> getSafeRoutes() async {
    final prefs = await SharedPreferences.getInstance();
    final routesJson = prefs.getString(_safeRoutesKey);
    
    if (routesJson == null) {
      final defaultRoutes = _getDefaultSafeRoutes();
      await saveSafeRoutes(defaultRoutes);
      return defaultRoutes;
    }

    final routesList = jsonDecode(routesJson) as List;
    return routesList.map((json) => SafeRoute.fromJson(json)).toList();
  }

  Future<void> saveSafeRoutes(List<SafeRoute> routes) async {
    final prefs = await SharedPreferences.getInstance();
    final routesJson = jsonEncode(routes.map((r) => r.toJson()).toList());
    await prefs.setString(_safeRoutesKey, routesJson);
  }

  // Reportes
  Future<List<Report>> getReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = prefs.getString(_reportsKey);
    
    if (reportsJson == null) return [];

    final reportsList = jsonDecode(reportsJson) as List;
    return reportsList.map((json) => Report.fromJson(json)).toList();
  }

  Future<void> saveReport(Report report) async {
    final reports = await getReports();
    reports.add(report);
    await _saveReports(reports);
  }

  Future<void> _saveReports(List<Report> reports) async {
    final prefs = await SharedPreferences.getInstance();
    final reportsJson = jsonEncode(reports.map((r) => r.toJson()).toList());
    await prefs.setString(_reportsKey, reportsJson);
  }

  List<DangerZone> _getDefaultDangerZones() => [
    DangerZone(
      id: '1',
      latitude: 4.1161999958575795,
      longitude: -73.6088337333233,
      radius: 150,
      title: 'Zona Rocosa Inestable',
      description: 'Área con terreno rocoso y posibles desprendimientos.',
      dangers: [
        'Desprendimiento de rocas',
        'Terreno resbaladizo',
        'Visibilidad limitada en curvas',
      ],
      precautions: [
        'Use casco de protección',
        'Mantenga distancia de las paredes rocosas',
        'No camíne durante lluvias',
      ],
      recommendations: [
        'Lleve calzado antideslizante',
        'Camine en grupo',
        'Informe su ubicación a familiares',
      ],
    ),
    DangerZone(
      id: '2',
      latitude: 4.110716544734726,
      longitude: -73.62999691007467,
      radius: 120,
      title: 'Zona de Quebrada',
      description: 'Área cercana a corrientes de agua con riesgo de crecientes.',
      dangers: [
        'Crecientes súbitas',
        'Terreno fangoso',
        'Fauna silvestre',
      ],
      precautions: [
        'No acampe cerca de la quebrada',
        'Esté atento a cambios climáticos',
        'Evite contacto con animales salvajes',
      ],
      recommendations: [
        'Lleve kit de primeros auxilios',
        'Use repelente de insectos',
        'Mantenga alimentos bien guardados',
      ],
    ),
  ];

  List<SafeRoute> _getDefaultSafeRoutes() => [
    SafeRoute(
      id: '1',
      name: 'Sendero del Mirador',
      description: 'Ruta panorámica con vistas espectaculares de la vereda.',
      points: [
        RoutePoint(
          latitude: 4.118, 
          longitude: -73.605, 
          name: 'Inicio - Centro del Pueblo',
          description: 'Punto de partida en la plaza principal'
        ),
        RoutePoint(
          latitude: 4.120, 
          longitude: -73.607, 
          name: 'Puente de Madera',
          description: 'Cruce sobre el río'
        ),
        RoutePoint(
          latitude: 4.125, 
          longitude: -73.610, 
          name: 'Mirador Principal',
          description: 'Vista panorámica de la vereda'
        ),
      ],
      difficulty: 'Fácil',
      estimatedDuration: 2.0,
      imageUrl: 'https://picsum.photos/300/200?random=1',
      attractions: [
        'Vista panorámica del valle',
        'Puente colgante artesanal',
        'Flora nativa',
      ],
      tips: [
        'Mejor hora: temprano en la mañana',
        'Lleve agua suficiente',
        'Cámara para fotos',
      ],
    ),
    SafeRoute(
      id: '2',
      name: 'Ruta de las Cascadas',
      description: 'Sendero que lleva a hermosas cascadas naturales.',
      points: [
        RoutePoint(
          latitude: 4.115, 
          longitude: -73.615, 
          name: 'Entrada del Bosque',
          description: 'Inicio del sendero boscoso'
        ),
        RoutePoint(
          latitude: 4.112, 
          longitude: -73.618, 
          name: 'Primera Cascada',
          description: 'Cascada pequeña ideal para descanso'
        ),
        RoutePoint(
          latitude: 4.108, 
          longitude: -73.622, 
          name: 'Cascada Principal',
          description: 'Cascada de 15 metros de altura'
        ),
      ],
      difficulty: 'Moderada',
      estimatedDuration: 3.5,
      imageUrl: 'https://picsum.photos/300/200?random=2',
      attractions: [
        'Dos cascadas naturales',
        'Piscinas naturales',
        'Diversidad de aves',
      ],
      tips: [
        'Lleve ropa de cambio',
        'Protector solar biodegradable',
        'No deje basura',
      ],
    ),
    SafeRoute(
      id: '3',
      name: 'Camino Ancestral',
      description: 'Ruta histórica utilizada por los antiguos habitantes.',
      points: [
        RoutePoint(
          latitude: 4.122, 
          longitude: -73.600, 
          name: 'Petroglifos',
          description: 'Piedras con grabados ancestrales'
        ),
        RoutePoint(
          latitude: 4.124, 
          longitude: -73.598, 
          name: 'Árbol Centenario',
          description: 'Ceiba de más de 200 años'
        ),
        RoutePoint(
          latitude: 4.127, 
          longitude: -73.595, 
          name: 'Mesa Ceremonial',
          description: 'Sitio de rituales ancestrales'
        ),
      ],
      difficulty: 'Fácil',
      estimatedDuration: 1.5,
      imageUrl: 'https://picsum.photos/300/200?random=3',
      attractions: [
        'Petroglifos indígenas',
        'Árbol sagrado centenario',
        'Sitios arqueológicos',
      ],
      tips: [
        'Respete los sitios sagrados',
        'No toque los petroglifos',
        'Guía local recomendado',
      ],
    ),
  ];
}