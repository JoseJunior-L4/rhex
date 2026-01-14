import 'package:flutter/material.dart';

class ColorPaletteModel {
  List<Color> colors;

  // Undo/Redo state management
  final List<List<Color>> _history = [];
  int _currentHistoryIndex = -1;

  ColorPaletteModel({required this.colors}) {
    // Save initial state only if we have colors
    _saveState();
  }

  // Save current state to history
  void _saveState() {
    // Remove any redo history if we're not at the end
    if (_currentHistoryIndex < _history.length - 1) {
      _history.removeRange(_currentHistoryIndex + 1, _history.length);
    }

    // Add current state to history
    _history.add(List<Color>.from(colors));
    _currentHistoryIndex = _history.length - 1;

    // Limit history size to prevent memory issues
    if (_history.length > 50) {
      _history.removeAt(0);
      _currentHistoryIndex--;
    }
  }

  void addColor(Color color) {
    colors.add(color);
    _saveState(); // Save AFTER the change
  }

  void removeColorAt(int index) {
    if (index >= 0 && index < colors.length) {
      colors.removeAt(index);
      _saveState(); // Save AFTER the change
    }
  }

  void updateColorAt(int index, Color color) {
    if (index >= 0 && index < colors.length) {
      colors[index] = color;
      _saveState(); // Save AFTER the change
    }
  }

  bool get canUndo => _currentHistoryIndex > 0;

  bool get canRedo => _currentHistoryIndex < _history.length - 1;

  void undo() {
    if (canUndo) {
      _currentHistoryIndex--;
      colors = List<Color>.from(_history[_currentHistoryIndex]);
    }
  }

  void redo() {
    if (canRedo) {
      _currentHistoryIndex++;
      colors = List<Color>.from(_history[_currentHistoryIndex]);
    }
  }

  String getHexColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  List<String> getColorHistory() {
    return colors.map((color) => getHexColor(color)).toList();
  }
}
