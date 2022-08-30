class UserLocation {
  final double? latitude;
  final double? longitude;
  UserLocation({
    this.latitude,
    this.longitude,
  });

  UserLocation copyWith({
    double? latitude,
    double? longitude,
  }) {
    return UserLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() =>
      'UserLocation(latitude: $latitude, longitude: $longitude)';

  @override
  bool operator ==(covariant UserLocation other) {
    if (identical(this, other)) return true;

    return other.latitude == latitude && other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
