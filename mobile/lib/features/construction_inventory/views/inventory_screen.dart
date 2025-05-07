import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/construction_inventory/models/inventory_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/inventory_bloc.dart';
import '../blocs/inventory_event.dart';
import '../blocs/inventory_state.dart';

import '../../../shared/widgets/bottom_navigation.dart';
import '../../../shared/themes/styles.dart';
import 'widgets/edit_item_dialog.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  void _loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final int? addressId = prefs.getInt('addressId');

    if (token != null && addressId != null) {
      context.read<InventoryBloc>().add(
            LoadInventoryEvent(token: token, addressId: addressId),
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load inventory: Missing data')),
      );
    }
  }

  void _showEditItemDialog(BuildContext context, InventoryItemModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return EditItemDialog(
          remaining: item.remaining,
          purchased: item.purchased,
          onSave: (newRemaining) {
            context.read<InventoryBloc>().add(
                  UpdateInventoryItemEvent(
                    itemId: item.id,
                    newRemaining: newRemaining,
                  ),
                );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: AppStyles.backgroundDecoration,
          ),
          Container(
            color: AppStyles.filterColor.withOpacity(0.75),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Container(
                  color: AppStyles.transparentWhite,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
                  child: Text(
                    'Construction inventory',
                    style: AppStyles.headerStyle
                        .copyWith(color: Colors.black, fontSize: 22),
                  ),
                ),
                Container(
                  color: AppStyles.transparentWhite,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (query) {
                      context
                          .read<InventoryBloc>()
                          .add(FilterInventoryEvent(query: query));
                    },
                    decoration: InputDecoration(
                      hintText: 'Search building articles...',
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: AppStyles.transparentWhite,
                    child: BlocBuilder<InventoryBloc, InventoryState>(
                      builder: (context, state) {
                        if (state is InventoryLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (state is InventoryError) {
                          return const Center(
                              child: Text('Error fetching inventory items'));
                        } else if (state is NoInventoryFound) {
                          return const Center(
                              child: Text('No items found for the specified address.'));
                        } else if (state is InventoryLoaded) {
                          return ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: state.filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = state.filteredItems[index];
                              return Card(
                                color: Colors.white.withOpacity(0.7),
                                child: ListTile(
                                  title: Text(item.name),
                                  subtitle: Text(
                                    'Bought: ${item.purchased}${item.metrics}  Remaining: ${item.remaining}${item.metrics}',
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit,
                                        color: Colors.grey[800]),
                                    onPressed: () {
                                      _showEditItemDialog(context, item);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return const Center(child: Text('No items found.'));
                      },
                    ),
                  ),
                ),
                BottomNavigation(
                  onTap: (index) {
                    if (index == 0) {
                      Navigator.pushNamed(context, '/calendar');
                    } else if (index == 1) {
                      Navigator.pushNamed(context, '/home');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
