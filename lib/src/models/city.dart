/// Model untuk data Kabupaten/Kota
class City {
  final String id;
  final String provinceId;
  final String name;

  const City({
    required this.id,
    required this.provinceId,
    required this.name,
  });

  /// Create City from JSON
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String,
      provinceId: json['province_id'] as String,
      name: json['name'] as String,
    );
  }

  /// Convert City to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'province_id': provinceId,
      'name': name,
    };
  }

  @override
  String toString() => 'City(id: $id, provinceId: $provinceId, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is City &&
        other.id == id &&
        other.provinceId == provinceId &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ provinceId.hashCode ^ name.hashCode;
}
