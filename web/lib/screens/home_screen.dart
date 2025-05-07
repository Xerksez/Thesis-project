import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'package:web_app/screens/conversations_screen.dart';
import 'package:web_app/screens/inventory_screen.dart';
import 'package:web_app/screens/teams_screen.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? userImageUrl;
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    html.window.onPopState.listen((event) {
      if (ModalRoute.of(context)?.isCurrent ?? false) {
        html.window.history.pushState(null, '', '/home');
        print('Cofanie do logowania zablokowane.');
      }
    });
  }

 Future<void> _loadUserData() async {
  final userId = int.tryParse(
    (html.document.cookie?.split('; ') ?? [])
        .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
        .split('=')[1],
  );

  final token = (html.document.cookie?.split('; ') ?? [])
      .firstWhere((cookie) => cookie.startsWith('userToken='), orElse: () => '')
      .split('=')[1];

  if (userId != null && token.isNotEmpty) {
    try {
      // Pobranie danych użytkownika
      final userResponse = await http.get(
        Uri.parse('https://buildbuddy-api-fwezfydta4atcags.northeurope-01.azurewebsites.net/api/User/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        final name = '${userData['name']} ${userData['surname']}';

        setState(() {
          userName = name;
        });

        // Pobranie zdjęcia użytkownika
        final imageResponse = await http.get(
          Uri.parse('https://buildbuddy-api-fwezfydta4atcags.northeurope-01.azurewebsites.net/api/User/$userId/image'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (imageResponse.statusCode == 200) {
          final imageData = json.decode(imageResponse.body) as List<dynamic>;
          if (imageData.isNotEmpty) {
            final imageUrl = imageData[0] as String;

            // Dodaj unikalny parametr do URL, aby wymusić odświeżenie
            final refreshedImageUrl = '$imageUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}';
            print('Odświeżony URL zdjęcia: $refreshedImageUrl');

            setState(() {
              userImageUrl = refreshedImageUrl;
            });
          } else {
            print('Brak zdjęcia w odpowiedzi API.');
          }
        } else {
          print('Błąd pobierania zdjęcia użytkownika: ${imageResponse.statusCode}');
        }
      } else {
        print('Błąd pobierania danych użytkownika: ${userResponse.statusCode}');
      }
    } catch (e) {
      print('Błąd pobierania danych użytkownika: $e');
    }
  } else {
    print('Nie znaleziono userId lub tokenu w ciasteczkach.');
  }
}

Future<void> _refreshImage(int userId, String token) async {
  try {
    final imageResponse = await http.get(
      Uri.parse('https://buildbuddy-api-fwezfydta4atcags.northeurope-01.azurewebsites.net/api/User/$userId/image'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (imageResponse.statusCode == 200) {
      final imageData = json.decode(imageResponse.body) as List<dynamic>;
      if (imageData.isNotEmpty) {
        final imageUrl = imageData[0] as String;
        final refreshedImageUrl = '$imageUrl?timestamp=${DateTime.now().millisecondsSinceEpoch}';

        print('Odświeżony URL zdjęcia: $refreshedImageUrl');
        setState(() {
          userImageUrl = refreshedImageUrl; // Zaktualizuj URL zdjęcia
        });
      }
    } else { 
      print('Błąd odświeżania zdjęcia użytkownika: ${imageResponse.statusCode}');
    }
  } catch (e) {
    print('Błąd odświeżania zdjęcia użytkownika: $e');
  }
}

  Future<void> _uploadUserImage(Uint8List imageBytes) async {
  final userId = int.tryParse(
    (html.document.cookie?.split('; ') ?? [])
        .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
        .split('=')[1],
  );

  final token = (html.document.cookie?.split('; ') ?? [])
      .firstWhere((cookie) => cookie.startsWith('userToken='), orElse: () => '')
      .split('=')[1];

  if (userId != null && token.isNotEmpty) {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://buildbuddy-api-fwezfydta4atcags.northeurope-01.azurewebsites.net/api/User/$userId/upload-image'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      // Dodaj plik z kluczem "image"
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'image.jpg',
      ));

      print("Wysyłanie zdjęcia użytkownika...");
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Zdjęcie przesłane pomyślnie.');
        // Wymuś odświeżenie interfejsu
        await _refreshImage(userId, token);
      } else {
        print('Błąd przesyłania zdjęcia: ${response.statusCode}');
        print('Treść odpowiedzi: ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      print('Błąd przesyłania zdjęcia: $e');
    }
  } else {
    print('Nie znaleziono userId lub tokenu w ciasteczkach.');
  }
}

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("User's photo"),
          content: userImageUrl != null
              ? Image.network(userImageUrl!, fit: BoxFit.cover)
              : const Icon(
                Icons.person,
                size: 50, // Rozmiar ikony
                color: Colors.grey, // Kolor ikony
              ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
            TextButton(
              onPressed: () {
                html.FileUploadInputElement input = html.FileUploadInputElement()..accept = 'image/*';
                input.click();

                input.onChange.listen((event) async {
                  if (input.files != null && input.files!.isNotEmpty) {
                    final reader = html.FileReader();
                    reader.readAsArrayBuffer(input.files![0]);

                    reader.onLoadEnd.listen((_) {
                      _uploadUserImage(reader.result as Uint8List);
                      Navigator.pop(context);
                    });
                  }
                });
              },
              child: const Text("Change photo"),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    print('Logging out user.');
    html.document.cookie = 'userToken=; path=/; max-age=0';
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        print('Cofanie do logowania zablokowane przez WillPopScope.');
        return false;
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 800,
                minHeight: 700,
                maxWidth: screenWidth < 800 ? 800 : screenWidth,
                maxHeight: screenHeight < 700 ? 700 : screenHeight,
              ),
              child: Container(
                color: Colors.grey[800],
                child: Stack(
                  children: [Positioned(
                      top: 20,
                      left: 20,
                      child: Image.asset(
                        'lib/assets/logo.png',
                        width: 60,
                        height: 60,
                      ),
                    ),
                    Positioned(
  top: 20,
  right: 80, // Umiejscowienie w prawym górnym rogu
  child: Row(
    children: [
      GestureDetector(
        onTap: _showImageDialog, // Kliknięcie otwiera dialog
        child: CircleAvatar(
          radius: 20, // Rozmiar zdjęcia
          backgroundImage: userImageUrl != null ? NetworkImage(userImageUrl!) : null,
          child: userImageUrl == null
              ? const Icon(Icons.person, color: Colors.white, size: 24) // Zastępcza ikona
              : null,
        ),
      ),
      const SizedBox(width: 10), // Odstęp między zdjęciem a nazwą
      Text(
        userName ?? 'Ładowanie...', // Wyświetlenie nazwy użytkownika
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      IconButton(
        icon: const Icon(Icons.logout, color: Colors.white, size: 32),
        onPressed: () => _logout(context),
                          ),
                        ],
                  ),
                ),
               Padding(
                      padding: const EdgeInsets.only(top: 120.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                final userId = int.tryParse(
                              (html.document.cookie?.split('; ') ?? [])
                                  .firstWhere((cookie) => cookie.startsWith('userId='), orElse: () => 'userId=0')
                                  .split('=')[1],
                                );
                               if (userId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TeamsScreen(loggedInUserId: userId),
                                ),
                              );
                            }else {
                                  print('Error: Logged in user ID not found: $userId');
                                }
                              },
                              child: _buildButton(
                                context,
                                'Teams and Projects',
                                Icons.people, // Ikonka ludzi
                                Icons.apartment, // Ikonka budynku
                                const Color.fromARGB(87, 61, 70, 192),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TasksScreen()),
                              ),
                              child: _buildButton(
                                context,
                                'Tasks',
                                Icons.task,
                                null,
                                const Color.fromARGB(36, 38, 132, 209),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => InventoryScreen()),
                              ),
                              child: _buildButton(
                                context,
                                'Inventory',
                                Icons.inventory,
                                null,
                                const Color.fromARGB(106, 33, 149, 243),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ConversationsScreen()),
                              ),
                              child: _buildButton(
                                context,
                                'Chats',
                                Icons.chat,
                                null,
                                const Color.fromARGB(255, 76, 135, 175),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: screenWidth,
                        height: screenHeight * 0.6,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('lib/assets/homeback.png'),
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
        );
  }

  Widget _buildButton(
    BuildContext context,
    String title,
    IconData mainIcon,
    IconData? secondaryIcon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(mainIcon, size: 32, color: Colors.white),
              if (secondaryIcon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(secondaryIcon, size: 32, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
