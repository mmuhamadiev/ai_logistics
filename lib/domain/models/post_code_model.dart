class PostalCode {
  final String countryCode;
  final String postalCode;
  final String name;
  String? code;
  final double latitude;
  final double longitude;

  PostalCode({
    required this.countryCode,
    required this.postalCode,
    required this.name,
    this.code,
    required this.latitude,
    required this.longitude,
  });

  // Factory constructor to create PostalCode from a map (Firestore or JSON)
  factory PostalCode.fromMap(Map<String, dynamic> map) {
    return PostalCode(
      countryCode: map['country_code'].toString(),
      postalCode: map['postalcode'].toString(),
      name: map['name'],
      code: map['code'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  // Convert PostalCode to a map (Firestore or JSON)
  Map<String, dynamic> toMap() {
    return {
      'country_code': countryCode,
      'postalcode': postalCode,
      'name': name,
      'code': code,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Factory constructor to create PostalCode from JSON
  factory PostalCode.fromJson(Map<String, dynamic> json) {
    return PostalCode(
      countryCode: json['countryCode'],
      postalCode: json['postalCode'],
      name: json['name'],
      code: json['code'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  // Convert PostalCode to JSON
  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'postalCode': postalCode,
      'name': name,
      'code': code,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
