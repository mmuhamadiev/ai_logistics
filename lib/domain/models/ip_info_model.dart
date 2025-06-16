class IpInfoModel {
  final String ip;
  final String country;
  final String countryCode;
  final double latitude;
  final double longitude;
  final String region;
  final String city;

  IpInfoModel({
    required this.ip,
    required this.country,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.region,
    required this.city,
  });

  factory IpInfoModel.fromJson(Map<String, dynamic> json) {
    return IpInfoModel(
      ip: json['ip'] ?? '',
      country: json['country'] ?? '',
      countryCode: json['countryCode'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      region: json['region'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'country': country,
      'countryCode': countryCode,
      'latitude': latitude,
      'longitude': longitude,
      'region': region,
      'city': city,
    };
  }

  /// Factory method to create an empty/default instance
  factory IpInfoModel.empty() {
    return IpInfoModel(
      ip: '',
      country: '',
      countryCode: '',
      latitude: 0.0,
      longitude: 0.0,
      region: '',
      city: '',
    );
  }
}
