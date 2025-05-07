class InventoryItemModel {
  final int id;
  final String name;
  final double purchased; // Represents the quantityMax
  final String metrics;
  final double remaining; // Represents the quantityLeft
  final int addressId;

  InventoryItemModel({
    required this.id,
    required this.name,
    required this.purchased, // Represents the total quantity purchased
    required this.metrics,
    required this.remaining, // Represents the quantity left
    required this.addressId,
  });

  /// Factory constructor to create an instance from JSON data
  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown', // Default to 'Unknown' if null
      purchased: (json['quantityMax'] as num?)?.toDouble() ?? 0.0, // Safely parse as double
      metrics: json['metrics'] as String? ?? '', // Default to an empty string if null
      remaining: (json['quantityLeft'] as num?)?.toDouble() ?? 0.0, // Safely parse as double
      addressId: json['addressId'] as int? ?? 0, // Default to 0 if null
    );
  }

  /// Convert the instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantityMax': purchased, // Map purchased to quantityMax
      'metrics': metrics,
      'quantityLeft': remaining, // Map remaining to quantityLeft
      'addressId': addressId,
    };
  }

  /// Create a copy of the instance with updated values
  InventoryItemModel copyWith({
    int? id,
    String? name,
    double? purchased,
    String? metrics,
    double? remaining,
    int? addressId,
  }) {
    return InventoryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      purchased: purchased ?? this.purchased,
      metrics: metrics ?? this.metrics,
      remaining: remaining ?? this.remaining,
      addressId: addressId ?? this.addressId,
    );
  }
}
