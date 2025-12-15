/// Model untuk data Kelurahan/Desa
class Village {
  final String id;
  final String districtId;
  final String name;

  const Village({
    required this.id,
    required this.districtId,
    required this.name,
  });

  /// Create Village from JSON
  factory Village.fromJson(Map<String, dynamic> json) {
    return Village(
      id: json['id'] as String,
      districtId: json['district_id'] as String,
      name: json['name'] as String,
    );
  }

  /// Convert Village to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'district_id': districtId,
      'name': name,
    };
  }

  @override
  String toString() => 'Village(id: $id, districtId: $districtId, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Village &&
        other.id == id &&
        other.districtId == districtId &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ districtId.hashCode ^ name.hashCode;
}
