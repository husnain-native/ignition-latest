class SpaceModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double pricePerHour;
  final int capacity;
  final List<String> amenities;
  final String type; // Private Office, Meeting Room, etc.
  final bool isAvailable;

  SpaceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.pricePerHour,
    required this.capacity,
    required this.amenities,
    required this.type,
    this.isAvailable = true,
  });

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    return SpaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      capacity: json['capacity'] as int,
      amenities: List<String>.from(json['amenities'] as List),
      type: json['type'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'pricePerHour': pricePerHour,
      'capacity': capacity,
      'amenities': amenities,
      'type': type,
      'isAvailable': isAvailable,
    };
  }
}
