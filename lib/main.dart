import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Locale('en', '');

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('es', ''), // Spanish
      ],
      home: MyHomePage(onLocaleChange: _setLocale),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function(Locale) onLocaleChange;

  MyHomePage({required this.onLocaleChange});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Contact> _contacts = []; // Initialize _contacts list

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) {
      getContacts();
    });
  }

  Future<void> requestPermissions() async {
    await [
      Permission.contacts,
      Permission.camera,
      Permission.storage,
    ].request();
  }

  Future<void> getContacts() async {
    if (await Permission.contacts.isGranted) {
      try {
        Iterable<Contact> contacts = await ContactsService.getContacts();
        setState(() {
          _contacts = contacts.toList(); // Update _contacts list
        });
        for (var contact in contacts) {
          print(contact.displayName);
        }
      } catch (e) {
        print('Error fetching contacts: $e');
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      // Handle the picked image
      print('Picked image: ${pickedFile.path}');
    }
  }

  Widget _buildContactItem(Contact contact) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundImage: AssetImage('assets/images/default_profile.png'),
        radius: 20,
      ),
      title: Text(contact.displayName ?? ''),
      onTap: () {
        // Handle contact tap if needed
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var localization = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.translate('title')),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 2, 95, 57),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Handle edit profile photo action
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(localization
                                          .translate('select_from_gallery')),
                                      onTap: () {
                                        Navigator.pop(
                                            context); // Close the bottom sheet
                                        pickImage(ImageSource
                                            .gallery); // Pick from gallery
                                      },
                                    ),
                                    ListTile(
                                      title: Text(localization
                                          .translate('take_a_photo')),
                                      onTap: () {
                                        Navigator.pop(
                                            context); // Close the bottom sheet
                                        pickImage(
                                            ImageSource.camera); // Take a photo
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage(
                              'assets/images/profile_placeholder.png'), // Placeholder image
                          // You can replace AssetImage with NetworkImage for an online image
                        ),
                      ),
                      SizedBox(height: 5),
                      const Text(
                        'seth_77',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: 2),
                      const Text(
                        'sethamen250@gmail.com',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: Icon(Icons.language,
                          color: const Color.fromARGB(255, 230, 8, 8)),
                      onPressed: () {
                        // Show language selection dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                  localization.translate('select_language')),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildLanguageOption(
                                      localization, 'English', 'en'),
                                  _buildLanguageOption(
                                      localization, 'Spanish', 'es'),
                                  // Add more languages as needed
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          Contact contact = _contacts[index];
          return _buildContactItem(contact);
        },
      ),
    );
  }

  Widget _buildLanguageOption(
      AppLocalizations localization, String languageName, String languageCode) {
    return ListTile(
      title: Text(languageName),
      onTap: () {
        Locale newLocale = Locale(languageCode, '');
        widget.onLocaleChange(newLocale);
        Navigator.pop(context); // Close the dialog
      },
    );
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/lang/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
    } catch (e) {
      print('Error loading localization for ${locale.languageCode}: $e');
      _localizedStrings = {}; // Fallback to empty map if loading fails
    }

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? '';
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
