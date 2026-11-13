class SolarPlan {
  const SolarPlan({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.capacity,
    this.imageUrl,
    this.features = const [],
  });

  final String id;
  final String name;
  final String category;
  final String description;
  final String? capacity;
  final String? imageUrl;
  final List<String> features;

  String get categoryLabel {
    switch (category.toLowerCase()) {
      case 'residential':
        return 'Residential';
      case 'commercial':
        return 'Commercial';
      default:
        return category.isEmpty
            ? 'Solar solution'
            : '${category[0].toUpperCase()}${category.substring(1)}';
    }
  }

  factory SolarPlan.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    final features = rawFeatures is List
        ? rawFeatures.map((value) => value.toString()).toList(growable: false)
        : const <String>[];

    final rawImageUrl = json['image_url'];
    final imageUrl = rawImageUrl is String && rawImageUrl.trim().isNotEmpty
        ? rawImageUrl.trim()
        : null;

    final rawCapacity = json['capacity'];
    final capacity = rawCapacity is String && rawCapacity.trim().isNotEmpty
        ? rawCapacity.trim()
        : null;

    return SolarPlan(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Solar solution',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      capacity: capacity,
      imageUrl: imageUrl,
      features: features,
    );
  }
}
