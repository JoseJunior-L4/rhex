import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:rhex/services/storage_service.dart';
import 'screens/palette_creator_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rhex/l10n/app_localizations.dart';

void main() {
  runApp(const ColorPaletteCreatorApp());
}

class ColorPaletteCreatorApp extends StatefulWidget {
  const ColorPaletteCreatorApp({super.key});

  @override
  State<ColorPaletteCreatorApp> createState() => _ColorPaletteCreatorAppState();
}

class _ColorPaletteCreatorAppState extends State<ColorPaletteCreatorApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale; // Null means system default
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final mode = await _storageService.loadThemeMode();
    final locale = await _storageService.loadLocale();
    setState(() {
      _themeMode = mode;
      _locale = locale;
    });
  }

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
    _storageService.saveThemeMode(_themeMode);
  }

  void _changeLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
    _storageService.saveLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'Rhex',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('pt'), // Portuguese
      ],
      locale: _locale,
      themeMode: _themeMode,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: ShadSlateColorScheme.light(),
        textTheme: ShadTextTheme(family: 'Poppins'),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: ShadSlateColorScheme.dark(),
        textTheme: ShadTextTheme(family: 'Poppins'),
      ),
      home: PaletteCreatorScreen(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
        locale: _locale ?? const Locale('en'),
        onLocaleChanged: _changeLocale,
      ),
    );
  }
}
