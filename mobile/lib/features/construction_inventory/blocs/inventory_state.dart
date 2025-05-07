import '../models/inventory_item_model.dart';

/// Abstract base class for inventory states
abstract class InventoryState {}

/// State emitted while loading inventory data
class InventoryLoading extends InventoryState {}

/// State emitted when inventory is successfully loaded
class InventoryLoaded extends InventoryState {
  final List<InventoryItemModel> items; // Full list of items
  final List<InventoryItemModel> filteredItems; // Filtered list for search functionality

  InventoryLoaded({required this.items, required this.filteredItems});

  // Add copyWith for easier state updates
  InventoryLoaded copyWith({
    List<InventoryItemModel>? items,
    List<InventoryItemModel>? filteredItems,
  }) {
    return InventoryLoaded(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
    );
  }
}

/// State emitted when no inventory is found for the specified address
class NoInventoryFound extends InventoryState {}

/// State emitted when an error occurs
class InventoryError extends InventoryState {
  final String message;

  InventoryError(this.message);
}
