import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyColors = 'rhex_colors';
  static const String _keyGridSize = 'rhex_grid_size';
  static const String _keyShowHex = 'rhex_show_hex';
  static const String _keyCurrentColor = 'rhex_current_color';
  static const String _keyHistory = 'rhex_history';
  static const String _keyHistoryIndex = 'rhex_history_index';

  Future<void> savePaletteState({
    required List<Color> colors,
    required int gridSize,
    required bool showHexLabels,
    required Color currentColor,
    required List<List<Color>> history,
    required int historyIndex,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Use toARGB32() as .value is deprecated
    final colorValues = colors.map((c) => c.toARGB32()).toList();

    // Serialize history - list of lists of color values
    final historyValues = history
        .map((snapshot) => snapshot.map((c) => c.toARGB32()).toList())
        .toList();

    await Future.wait([
      prefs.setString(_keyColors, jsonEncode(colorValues)),
      prefs.setInt(_keyGridSize, gridSize),
      prefs.setBool(_keyShowHex, showHexLabels),
      prefs.setInt(_keyCurrentColor, currentColor.toARGB32()),
      prefs.setString(_keyHistory, jsonEncode(historyValues)),
      prefs.setInt(_keyHistoryIndex, historyIndex),
    ]);
  }

  Future<Map<String, dynamic>> loadPaletteState() async {
    final prefs = await SharedPreferences.getInstance();

    List<Color> colors = [];
    int gridSize = 4;
    bool showHexLabels = true;
    Color currentColor = const Color(0xFF000000);
    List<List<Color>> history = [];
    int historyIndex = -1;

    final String? colorsJson = prefs.getString(_keyColors);
    if (colorsJson != null) {
      try {
        final List<dynamic> colorValues = jsonDecode(colorsJson);
        colors = colorValues.map((v) => Color(v as int)).toList();
      } catch (e) {
        debugPrint('Error parsing saved colors: $e');
      }
    }

    gridSize = prefs.getInt(_keyGridSize) ?? 4;
    showHexLabels = prefs.getBool(_keyShowHex) ?? true;

    final int? currentColorValue = prefs.getInt(_keyCurrentColor);
    if (currentColorValue != null) {
      currentColor = Color(currentColorValue);
    }

    // Load history
    final String? historyJson = prefs.getString(_keyHistory);
    if (historyJson != null) {
      try {
        final List<dynamic> historyData = jsonDecode(historyJson);
        history = historyData.map((snapshot) {
          final List<dynamic> snapshotData = snapshot as List;
          return snapshotData.map((v) => Color(v as int)).toList();
        }).toList();
      } catch (e) {
        debugPrint('Error parsing saved history: $e');
      }
    }

    historyIndex = prefs.getInt(_keyHistoryIndex) ?? -1;

    return {
      'colors': colors,
      'gridSize': gridSize,
      'showHexLabels': showHexLabels,
      'currentColor': currentColor,
      'history': history,
      'historyIndex': historyIndex,
    };
  }
}
