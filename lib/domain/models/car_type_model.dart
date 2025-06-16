class CarTypeModel {
  final String name;
  final double height; // In meters
  final double length; // In meters
  final double width; // In meters
  final double maxWeight; // In tons
  final int capacity; // Number of Euro pallets
  final List<String> loadingMethods;

  const CarTypeModel({
    required this.name,
    required this.height,
    required this.length,
    required this.width,
    required this.maxWeight,
    required this.capacity,
    required this.loadingMethods,
  });

  // Static data for car types
  static const List<CarTypeModel> carTypes = [
    CarTypeModel(
      name: "MEGA",
      height: 3.0,
      length: 13.6,
      width: 2.48,
      maxWeight: 25.0,
      capacity: 34,
      loadingMethods: ["Rear", "Side", "Top"],
    ),
    CarTypeModel(
      name: "TAUTLINER_PLANA",
      height: 2.62, // Side height
      length: 13.6,
      width: 2.46,
      maxWeight: 24.0,
      capacity: 34,
      loadingMethods: ["Rear", "Side", "Top"],
    ),
    CarTypeModel(
      name: "Frigo",
      height: 2.6, // Side height
      length: 13.4,
      width: 2.46,
      maxWeight: 22.0,
      capacity: 33,
      loadingMethods: ["Rear"],
    ),
  ];

  // Find a CarTypeModel by name
  static CarTypeModel? getByName(String name) {
    return carTypes.firstWhere(
          (carType) => carType.name == name,
    );
  }
}
