class Report {
  final String id;
  final String title;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String? imageUrl;
  final String status;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.imageUrl,
    this.status = 'Pendiente',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
    'timestamp': timestamp.toIso8601String(),
    'imageUrl': imageUrl,
    'status': status,
  };

  factory Report.fromJson(Map<String, dynamic> json) => Report(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    category: json['category'],
    latitude: json['latitude'],
    longitude: json['longitude'],
    timestamp: DateTime.parse(json['timestamp']),
    imageUrl: json['imageUrl'],
    status: json['status'] ?? 'Pendiente',
  );
}