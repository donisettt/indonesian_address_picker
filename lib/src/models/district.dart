/// Model untuk data Kecamatan
class District {
  final String id;
  final String cityId;
  final String name;

  const District({
    required this.id,
    required this.cityId,
    required this.name,
  });

  /// Create District from JSON
  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'] as String,
      cityId: json['regency_id'] as String, // Note: 'regency_id' di API
      name: json['name'] as String,
    );
  }

  /// Convert District to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'regency_id': cityId,
      'name': name,
    };
  }

  @override
  String toString() => 'District(id: $id, cityId: $cityId, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is District &&
        other.id == id &&
        other.cityId == cityId &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ cityId.hashCode ^ name.hashCode;
}
