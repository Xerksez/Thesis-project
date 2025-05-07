abstract class InventoryEvent {}

class LoadInventoryEvent extends InventoryEvent {
  final String token;
  final int addressId;

  LoadInventoryEvent({required this.token, required this.addressId});
}

class FilterInventoryEvent extends InventoryEvent {
  final String query;

  FilterInventoryEvent({required this.query});
}

class UpdateInventoryItemEvent extends InventoryEvent {
  final int itemId;
  final double newRemaining;

  UpdateInventoryItemEvent({required this.itemId, required this.newRemaining});
}