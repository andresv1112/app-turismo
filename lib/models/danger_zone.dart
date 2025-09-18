class DangerZone {
  final String id;
  final double latitude;
  final double longitude;
  final double radius; // Radio en metros
  final String title;
  final String description;
  final List<String> dangers;
  final List<String> precautions;
  final List<String> recommendations;

  DangerZone({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.title,
    required this.description,
    required this.dangers,
    required this.precautions,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'latitude': latitude,
    'longitude': longitude,
    'radius': radius,
    'title': title,
    'description': description,
    'dangers': dangers,
    'precautions': precautions,
    'recommendations': recommendations,
  };

  factory DangerZone.fromJson(Map<String, dynamic> json) => DangerZone(
    id: json['id'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    radius: json['radius'],
    title: json['title'],
    description: json['description'],
    dangers: List<String>.from(json['dangers']),
    precautions: List<String>.from(json['precautions']),
    recommendations: List<String>.from(json['recommendations']),
  );
}