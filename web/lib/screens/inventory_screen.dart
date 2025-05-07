import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart';
import 'package:web_app/config/config.dart';
import 'package:web_app/models/inventory_item_model.dart';
import 'package:web_app/services/inventory_service.dart';
import 'package:web_app/themes/styles.dart';
import 'package:universal_html/html.dart' as html;

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Map<String, dynamic>> addresses = [];
  Map<int, List<InventoryItemModel>> inventory = {}; // Store InventoryItemModel instead of Map
  bool _isLoading = true;
  bool _isError = false;

  final InventoryService inventoryService = InventoryService(); // Instance of InventoryService

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  /// Get the token from cookies
  String? _getTokenFromCookies() {
    final cookies = html.document.cookie?.split('; ') ?? [];
    for (final cookie in cookies) {
      if (cookie.startsWith('userToken=')) {
        return cookie.substring('userToken='.length);
      }
    }
    return null;
  }

 Future<void> _fetchData() async {
  try {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    // Retrieve the token from cookies
    final token = _getTokenFromCookies();
    if (token == null) {
      throw Exception('User token is missing from cookies. Please log in again.');
    }

    // Retrieve userId from cookies
    final userId = _getCookieValue('userId');
    if (userId == null) {
      throw Exception('User ID is missing from cookies. Please log in again.');
    }

    // Fetch addresses for the user
    addresses = await InventoryService.getAddressesForUser(int.parse(userId));
    print('[InventoryScreen] Addresses fetched: $addresses');

    // Fetch inventory for each address
    for (final address in addresses) {
      final addressId = address['addressId'];
      final items = await inventoryService.fetchInventoryItems(addressId);
      inventory[addressId] = items; // Store as InventoryItemModel list
    }
  } catch (e) {
    setState(() {
      _isError = true;
    });
    print('[InventoryScreen] Error fetching data: $e');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}
String? _getCookieValue(String key) {
  final cookies = html.window.document.cookie;
  if (cookies != null) {
    for (final cookie in cookies.split(';')) {
      final parts = cookie.split('=');
      if (parts[0].trim() == key) {
        return parts[1].trim();
      }
    }
  }
  return null;
}


 Future<void> _addItem(int addressId) async {
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  String selectedMetric = 'kg'; // Default metric
  final List<String> metricsList = ['kg', 'm²', 'm³', 'pcs', 'l', 'g', 'mm', 'cm', 'm', 'ml'];

 await showDialog(
  context: context,
  builder: (context) {
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: AppStyles.transparentWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Text('Add Item', style: AppStyles.headerStyle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                cursorColor: AppStyles.cursorColor,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  hintText: 'Quantity',
                  hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                cursorColor: AppStyles.cursorColor,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedMetric,
                items: metricsList.map((metric) {
                  return DropdownMenuItem(
                    value: metric,
                    child: Text(metric),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMetric = value ?? 'kg';
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select Metric',
                  hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Black text color for Cancel
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && quantityController.text.isNotEmpty) {
                final newItem = {
                  'name': nameController.text,
                  'quantityMax': int.parse(quantityController.text),
                  'metrics': selectedMetric,
                  'quantityLeft': int.parse(quantityController.text),
                  'addressId': addressId,
                };

                final token = _getTokenFromCookies();
                if (token == null) {
                  print('Error: Token not found.');
                  return;
                }

                await inventoryService.addBuildingArticle(newItem);
                Navigator.pop(context);
                await _fetchData();
              }
            },
            style: AppStyles.buttonStyle(),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  },
);

}


 Future<void> _editItem(int itemId, InventoryItemModel item) async {
  final nameController = TextEditingController(text: item.name);
  final purchasedController = TextEditingController(text: item.purchased.toString());
  final remainingController = TextEditingController(text: item.remaining.toString());
  String selectedMetric = item.metrics;
  final List<String> metricsList = ['kg', 'm²', 'm³', 'pcs', 'l', 'g', 'mm', 'cm', 'm', 'ml'];

 await showDialog(
  context: context,
  builder: (context) {
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: AppStyles.transparentWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Text('Edit Item', style: AppStyles.headerStyle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter name',
                  hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                cursorColor: AppStyles.cursorColor,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: purchasedController,
                decoration: InputDecoration(
                  hintText: 'Enter max quantity',
                  hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                cursorColor: AppStyles.cursorColor,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedMetric,
                items: metricsList.map((metric) {
                  return DropdownMenuItem(
                    value: metric,
                    child: Text(metric),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMetric = value ?? item.metrics;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Select Metric',
                  hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: remainingController,
                decoration: InputDecoration(
                  hintText: 'Enter remaining quantity',
                  hintStyle: const TextStyle(color: Colors.black), // Black placeholder text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                cursorColor: AppStyles.cursorColor,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black, // Black text color for Cancel
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  purchasedController.text.isNotEmpty &&
                  remainingController.text.isNotEmpty) {
                final token = _getTokenFromCookies(); // Retrieve token from cookies
                if (token == null) {
                  print('Error: Token not found in cookies.');
                  return;
                }

                await inventoryService.updateInventoryItem(
                  itemId,
                  name: nameController.text,
                  purchased: double.parse(purchasedController.text),
                  metrics: selectedMetric,
                  remaining: double.parse(remainingController.text),
                );

                Navigator.pop(context);
                await _fetchData();
              }
            },
            style: AppStyles.buttonStyle(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  },
);

}



 Future<void> _deleteItem(int itemId) async {
  final token = _getTokenFromCookies();
  if (token == null) {
    print('Error: Token not found.');
    return;
  }

  await inventoryService.deleteBuildingArticle(itemId);
  await _fetchData();
}


  @override
Widget build(BuildContext context) {
  if (_isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  if (_isError) {
    return const Center(
      child: Text(
        'Failed to load data',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  return Scaffold(
    appBar: AppBar(
      title: const Text('Manage Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: const Color.fromARGB(144, 81, 85, 87),
      actions: [
    IconButton(
      icon: const Icon(Icons.refresh, color: Colors.white),
      onPressed: _fetchData, // Trigger refresh function
      tooltip: 'Refresh',
    ),
  ],
    ),
    body: Container(
      decoration: AppStyles.backgroundDecoration,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: addresses.map((address) {
          final addressId = address['addressId'];
          final addressName = address['name'];
          final addressInventory = inventory[addressId] ?? [];

          return Card(
            color: AppStyles.transparentWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    addressName,
                    style: AppStyles.headerStyle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppStyles.primaryBlue),
                    onPressed: () => _addItem(addressId),
                  ),
                ],
              ),
              children: addressInventory.isEmpty
                  ? [
                      const ListTile(
                        title: Text(
                          'No items in this inventory',
                          style: AppStyles.textStyle,
                        ),
                      ),
                    ]
                  : addressInventory.map((item) {
                      return ListTile(
                        title: Text(
                          item.name,
                          style: AppStyles.textStyle,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Max Quantity: ${item.purchased}'),
                            Text('Quantity Left: ${item.remaining}'),
                            Text('Metrics: ${item.metrics}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editItem(item.id, item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color.fromARGB(255, 0, 0, 0)),
                              onPressed: () => _deleteItem(item.id),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
            ),
          );
        }).toList(),
      ),
    ),
  );
}

}
