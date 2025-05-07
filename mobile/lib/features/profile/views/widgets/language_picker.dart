import 'package:flutter/material.dart';
import 'package:mobile/shared/localization/language_list.dart';

class LanguagePicker extends StatelessWidget {
  final Function(String) onLanguageSelected;

  const LanguagePicker({super.key, required this.onLanguageSelected});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: languages.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(languages[index]['name']!),
          trailing: Text(languages[index]['code']!),
          onTap: () {
            onLanguageSelected(languages[index]['code']!);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
