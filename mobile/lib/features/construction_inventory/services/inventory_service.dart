import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/features/construction_inventory/models/inventory_item_model.dart';
import 'package:mobile/shared/config/config.dart';

class InventoryService {
  // Wspólna funkcja do wykonywania żądań HTTP
  Future<http.Response> _makeRequest(
      String url, String method, String token, {String? body}) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    if (body != null) {
      headers['Content-Type'] = 'application/json-patch+json';
    }

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(Uri.parse(url), headers: headers);
      case 'PATCH':
        return await http.patch(Uri.parse(url), headers: headers, body: body);
      default:
        throw Exception('[InventoryService] Unsupported HTTP method: $method');
    }
  }

  // Pobieranie elementów inwentarza
  Future<List<InventoryItemModel>> fetchInventoryItems(
      String token, int addressId) async {
    try {
      final url = AppConfig.getInventoryEndpoint(addressId);
      print('[InventoryService] Fetching inventory from: $url');

      final response = await _makeRequest(url, 'GET', token);

      print('[InventoryService] Response status: ${response.statusCode}');
      if (response.statusCode == 404) {
        print('[InventoryService] No items found for the specified address.');
        return [];
      }

      if (response.statusCode != 200) {
        print('[InventoryService] Response body (Error): ${response.body}');
        throw Exception(
            '[InventoryService] Failed to fetch inventory items. Status: ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      final items =
          data.map((item) => InventoryItemModel.fromJson(item)).toList();
      print('[InventoryService] Successfully fetched ${items.length} items.');
      return items;
    } catch (e) {
      print('[InventoryService] Error fetching inventory items: $e');
      throw Exception(
          '[InventoryService] Failed to fetch inventory items. Error: $e');
    }
  }

  // Aktualizacja ilości
  Future<void> updateInventoryItem(
      String token, int itemId, double newRemaining) async {
    final url = AppConfig.getUpdateInventoryEndpoint(itemId);
    print('[InventoryService] Updating inventory item at: $url');

    final body = jsonEncode([
      {
        'op': 'replace',
        'path': '/quantityLeft',
        'value': newRemaining
      }
    ]);

    try {
      final response = await _makeRequest(url, 'PATCH', token, body: body);

      print('[InventoryService] Response status: ${response.statusCode}');
      print('[InventoryService] Response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            '[InventoryService] Failed to update inventory item. Status: ${response.statusCode}');
      }

      print('[InventoryService] Inventory item updated successfully.');
    } catch (e) {
      print('[InventoryService] Error updating inventory item: $e');
      throw Exception(
          '[InventoryService] Failed to update inventory item. Error: $e');
    }
  }
}
