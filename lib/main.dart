import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/palette_creator_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(const ColorPaletteCreatorApp());
}

class ColorPaletteCreatorApp extends StatelessWidget {
  const ColorPaletteCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp(
      title: 'Rhex',
      debugShowCheckedModeBanner: false,
      theme: ShadThemeData(
        colorScheme: ShadSlateColorScheme.light(),
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),
      ),
      home: const PaletteCreatorScreen(),
    );
  }
}
