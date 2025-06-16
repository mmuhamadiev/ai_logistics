class DriverInfo {
  final String driverCar; // ID of the driver
  final String driverName; // Name of the driver
  final String carTypeName; // Type of car used by the driver

  DriverInfo({
    required this.driverCar,
    required this.driverName,
    required this.carTypeName,
  });

  // Factory constructor for JSON parsing
  factory DriverInfo.fromJson(Map<String, dynamic> json) {
    return DriverInfo(
      driverCar: json['driverCar'],
      driverName: json['driverName'],
      carTypeName: json['carTypeName'],
    );
  }

  // Convert DriverInfo to JSON
  Map<String, dynamic> toJson() {
    return {
      'driverCar': driverCar,
      'driverName': driverName,
      'carTypeName': carTypeName,
    };
  }
}
