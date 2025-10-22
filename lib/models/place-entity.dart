class PlaceEntity {
  final String name;
  final String address;
  final double lat;
  final double lon;

  PlaceEntity({
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
  });

  factory PlaceEntity.fromGeoapifyJson(Map<String, dynamic> json) {
    final props = json['properties'] ?? {};
    return PlaceEntity(
      name: props['name'] ?? 'Không có tên',
      address: props['address_line2'] ??
          props['formatted'] ??
          'Không có địa chỉ',
      lat: (props['lat'] ?? 0).toDouble(),
      lon: (props['lon'] ?? 0).toDouble(),
    );
  }
}
