import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/register/views/widgets/phone_number_field.dart';
import 'package:mobile/features/register/views/widgets/styled_text_field.dart';
import 'package:mobile/shared/localization/language_list.dart';
import 'package:mobile/shared/themes/styles.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import '../models/user_model_register.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterBloc(),
      child: BlocListener<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful!')),
            );
            Navigator.pop(context);
          } else if (state is RegisterFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Registration failed: ${state.error}')),
            );
          }
        },
        child: const RegisterForm(),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telephoneNrController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedCountryCode = '+48';
  String? _selectedLanguageCode;

  // Password validation regex
  final _passwordRegex = RegExp(r'^(?=.*[!@#$%^&*(),.?":{}|<>])(?=.*\d)(?=.*[A-Z]).{8,}$');

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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  const Text('Register', style: AppStyles.formTitleStyle),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        StyledTextField(
                          controller: _nameController,
                          labelText: 'Name',
                        ),
                        const SizedBox(height: 12),
                        StyledTextField(
                          controller: _surnameController,
                          labelText: 'Surname',
                        ),
                        const SizedBox(height: 12),
                        StyledTextField(
                          controller: _emailController,
                          labelText: 'E-mail',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        PhoneNumberField(
                          controller: _telephoneNrController,
                          selectedCountryCode: _selectedCountryCode,
                          onCountryCodeChanged: (code) {
                            setState(() {
                              _selectedCountryCode = code;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        StyledTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            } else if (!_passwordRegex.hasMatch(value)) {
                              return 'The password must contain at least 8 characters, including 1 digit, 1 special character, and 1 uppercase letter.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          readOnly: true,
                          onTap: () async {
                            final selectedLanguage = await showModalBottomSheet<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  color: const Color.fromARGB(181, 0, 0, 0),
                                  child: ListView(
                                    children: languages.map((lang) {
                                      return ListTile(
                                        title: Text(
                                          lang['name']!,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        onTap: () {
                                          Navigator.pop(context, lang['code']);
                                        },
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            );
                            if (selectedLanguage != null) {
                              setState(() {
                                _selectedLanguageCode = selectedLanguage;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Choose preferred language',
                            labelStyle: TextStyle(color: _selectedLanguageCode == null ? Colors.grey : Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          controller: TextEditingController(
                            text: _selectedLanguageCode != null
                                ? languages.firstWhere((lang) => lang['code'] == _selectedLanguageCode)['name']
                                : '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: AppStyles.buttonStyle(),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final user = User(
                          id: 0,
                          name: _nameController.text,
                          surname: _surnameController.text,
                          mail: _emailController.text,
                          telephoneNr: '$_selectedCountryCode${_telephoneNrController.text}',
                          password: _passwordController.text,
                          userImageUrl: "string",
                          preferredLanguage: _selectedLanguageCode ?? "en",
                          roleId: 0, // Default role assignment
                          roleName: "string", // Default role name
                          powerLevel: 0, // Default power level
                        );

                        context.read<RegisterBloc>().add(RegisterSubmitted(user));
                      }
                    },
                    child: const Text('REGISTER'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
