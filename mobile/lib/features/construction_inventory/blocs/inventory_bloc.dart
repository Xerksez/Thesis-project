import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/construction_inventory/models/inventory_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/inventory_service.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryService inventoryService;

  InventoryBloc({required this.inventoryService}) : super(InventoryLoading()) {
    on<LoadInventoryEvent>(_handleLoadInventoryEvent);
    on<FilterInventoryEvent>(_handleFilterInventoryEvent);
    on<UpdateInventoryItemEvent>(_handleUpdateInventoryItemEvent);
  }

  Future<void> _handleLoadInventoryEvent(
      LoadInventoryEvent event, Emitter<InventoryState> emit) async {
    emit(InventoryLoading());

    // Try loading data from the cache
    final cachedItems = await _loadFromCache();
    if (cachedItems.isNotEmpty) {
      emit(InventoryLoaded(items: cachedItems, filteredItems: cachedItems));
    }

    // Load data from the backend
    try {
      final items = await inventoryService.fetchInventoryItems(
        event.token,
        event.addressId,
      );

      if (items.isEmpty) {
        emit(NoInventoryFound());
      } else {
        // Save to cache
        await _saveToCache(items);

        emit(InventoryLoaded(items: items, filteredItems: items));
      }
    } catch (e) {
      if (cachedItems.isEmpty) {
        emit(InventoryError('Failed to load inventory items: $e'));
      }
    }
  }

  void _handleFilterInventoryEvent(
      FilterInventoryEvent event, Emitter<InventoryState> emit) {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      final filteredItems = currentState.items
          .where((item) =>
              item.name.toLowerCase().contains(event.query.toLowerCase()))
          .toList();
      emit(currentState.copyWith(filteredItems: filteredItems));
    }
  }

  Future<void> _handleUpdateInventoryItemEvent(
      UpdateInventoryItemEvent event, Emitter<InventoryState> emit) async {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        print('[InventoryBloc] Error: Missing token');
        return;
      }

      final updatedItems = currentState.items.map((item) {
        if (item.id == event.itemId) {
          return item.copyWith(remaining: event.newRemaining);
        }
        return item;
      }).toList();
      emit(currentState.copyWith(items: updatedItems, filteredItems: updatedItems));

      try {
        await inventoryService.updateInventoryItem(token, event.itemId, event.newRemaining);
      } catch (e) {
        print('[InventoryBloc] Failed to update inventory item: $e');
        emit(currentState); // Revert to the previous state
      }
    }
  }

  Future<void> _saveToCache(List<InventoryItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString('inventory_cache', jsonData);
  }

  Future<List<InventoryItemModel>> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('inventory_cache');

    if (cachedData != null) {
      final List<dynamic> decodedData = jsonDecode(cachedData);
      return decodedData
          .map((item) => InventoryItemModel.fromJson(item))
          .toList();
    }

    return [];
  }
}
