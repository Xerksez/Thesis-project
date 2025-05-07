import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BuildOption extends StatelessWidget {
  final String title;
  final dynamic addressId; // Change to dynamic to handle both int and String
  final VoidCallback onTap;

  const BuildOption({
    super.key,
    required this.title,
    required this.addressId, // Accept dynamic type
    required this.onTap,
  });

  Future<void> _cacheAddressId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('addressId', addressId.toString()); // Convert to String
    print('Cached addressId: ${addressId.toString()}'); // Debug log
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4.0)],
        ),
        child: SizedBox(
          height: 50,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            onTap: () async {
              await _cacheAddressId(); 
              onTap();
            },
          ),
        ),
      ),
    );
  }
}