class FilterModel {
  final double maxRadius; // Radius in km for proximity filtering
  final double pricePerKmThreshold; // Minimum price per km

  FilterModel({
    required this.maxRadius,
    required this.pricePerKmThreshold,
  });

  // Default values for the filter
  factory FilterModel.defaultFilters() {
    return FilterModel(
      maxRadius: 200.0,
      pricePerKmThreshold: 2.0,
    );
  }

  // CopyWith method for immutability
  FilterModel copyWith({
    double? maxRadius,
    double? pricePerKmThreshold,
  }) {
    return FilterModel(
      maxRadius: maxRadius ?? this.maxRadius,
      pricePerKmThreshold: pricePerKmThreshold ?? this.pricePerKmThreshold,
    );
  }

  // Convert to JSON (useful for storing settings or passing to API)
  Map<String, dynamic> toJson() {
    return {
      'maxRadius': maxRadius,
      'pricePerKmThreshold': pricePerKmThreshold,
    };
  }

  // Create a FilterModel from JSON (useful for loading saved settings)
  factory FilterModel.fromJson(Map<String, dynamic> json) {
    return FilterModel(
      maxRadius: json['maxRadius'],
      pricePerKmThreshold: json['pricePerKmThreshold'],
    );
  }
}
