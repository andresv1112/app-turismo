class SafeRoute {
  final String id;
  final String name;
  final String description;
  final List<RoutePoint> points;
  final String difficulty;
  final double estimatedDuration; // en horas
  final String imageUrl;
  final List<String> attractions;
  final List<String> tips;

  SafeRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.difficulty,
    required this.estimatedDuration,
    required this.imageUrl,
    required this.attractions,
    required this.tips,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'points': points.map((p) => p.toJson()).toList(),
    'difficulty': difficulty,
    'estimatedDuration': estimatedDuration,
    'imageUrl': imageUrl,
    'attractions': attractions,
    'tips': tips,
  };

  factory SafeRoute.fromJson(Map<String, dynamic> json) => SafeRoute(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    points: (json['points'] as List).map((p) => RoutePoint.fromJson(p)).toList(),
    difficulty: json['difficulty'],
    estimatedDuration: json['estimatedDuration'],
    imageUrl: json['imageUrl'],
    attractions: List<String>.from(json['attractions']),
    tips: List<String>.from(json['tips']),
  );
}

class RoutePoint {
  final double latitude;
  final double longitude;
  final String? name;
  final String? description;

  RoutePoint({
    required this.latitude,
    required this.longitude,
    this.name,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'name': name,
    'description': description,
  };

  factory RoutePoint.fromJson(Map<String, dynamic> json) => RoutePoint(
    latitude: json['latitude'],
    longitude: json['longitude'],
    name: json['name'],
    description: json['description'],
  );
}