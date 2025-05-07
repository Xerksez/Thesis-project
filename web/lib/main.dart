import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:web_app/services/login_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'dart:ui' as ui;
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final loginService = LoginService();
  final bool isLoggedIn = await Future.delayed(Duration.zero, loginService.isLoggedIn);
  runApp(BuildBuddyApp(isLoggedIn: isLoggedIn));

  html.window.onError.listen((event) {
    final error = event.toString();
    if (error.contains('The targeted input element must be the active input element')) {
      print('Ignored PointerBinding error: $error');
      event.preventDefault(); 
    } else {
      print('Other error: $error');
    }
  });
}

class BuildBuddyApp extends StatelessWidget {
  final bool isLoggedIn;

  const BuildBuddyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Build Buddy',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: isLoggedIn ? '/home' : '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => LoginScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => HomeScreen());
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('404 - Page not found'),
                ),
              ),
            );
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
