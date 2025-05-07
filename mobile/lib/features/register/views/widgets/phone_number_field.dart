import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:mobile/shared/themes/styles.dart';
import 'package:mobile/shared/utils/validators.dart';  // Importujemy walidator

class PhoneNumberField extends StatelessWidget {
  final TextEditingController controller;
  final String selectedCountryCode;
  final ValueChanged<String> onCountryCodeChanged;

  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (Country country) {
                onCountryCodeChanged('+${country.phoneCode}');
              },
            );
          },
          child: Container(
            height: 56,
            width: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                selectedCountryCode,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: Colors.white),
            decoration: AppStyles.inputFieldStyle(hintText: 'Telephone number'),
            validator: Validator.validatePhoneNumber,  // Użycie walidatora
          ),
        ),
      ],
    );
  }
}
