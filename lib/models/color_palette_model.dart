import 'package:flutter/material.dart';
import 'dart:math';

class PaletteItem {
  final String id;
  final Color color;

  PaletteItem({required this.id, required this.color});

  // Helper to create a new item with a unique ID
  static PaletteItem create(Color color) {
    // Simple unique ID generation without external dependencies
    final String id =
        '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(10000)}';
    return PaletteItem(id: id, color: color);
  }
}

class ColorPaletteModel {
  List<PaletteItem> items;

  // Undo/Redo state management
  final List<List<PaletteItem>> _history = [];
  int _currentHistoryIndex = -1;

  ColorPaletteModel({required this.items}) {
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
    _history.add(List<PaletteItem>.from(items));
    _currentHistoryIndex = _history.length - 1;

    // Limit history size to prevent memory issues
    if (_history.length > 50) {
      _history.removeAt(0);
      _currentHistoryIndex--;
    }
  }

  void addColor(Color color) {
    items.add(PaletteItem.create(color));
    _saveState(); // Save AFTER the change
  }

  void updateColor(int index, Color color) {
    if (index >= 0 && index < items.length) {
      // Preserve the ID, just update the color
      items[index] = PaletteItem(id: items[index].id, color: color);
      _saveState();
    }
  }

  void reorderColor(int oldIndex, int newIndex) {
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    _saveState();
  }

  void removeColorAt(int index) {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      _saveState(); // Save AFTER the change
    }
  }

  void clear() {
    items.clear();
    _saveState();
  }

  bool get canUndo => _currentHistoryIndex > 0;

  bool get canRedo => _currentHistoryIndex < _history.length - 1;

  void undo() {
    if (canUndo) {
      _currentHistoryIndex--;
      // Create copy of the list
      items = List<PaletteItem>.from(_history[_currentHistoryIndex]);
    }
  }

  void redo() {
    if (canRedo) {
      _currentHistoryIndex++;
      items = List<PaletteItem>.from(_history[_currentHistoryIndex]);
    }
  }

  // Clear history and set current state as the new baseline
  void clearHistory() {
    _history.clear();
    _currentHistoryIndex = -1;
    _saveState();
  }

  // Load colors (used when restoring from persistence or opening files)
  // This replaces all colors and resets the history
  void loadColors(List<Color> newColors) {
    items.clear();
    items.addAll(newColors.map((c) => PaletteItem.create(c)));
    clearHistory();
  }

  // Get history for persistence - we convert back to colors
  List<List<Color>> getHistoryColors() {
    return _history
        .map((snapshot) => snapshot.map((item) => item.color).toList())
        .toList();
  }

  int getHistoryIndex() => _currentHistoryIndex;

  // Restore history from persistence
  void restoreHistory(List<List<Color>> savedHistory, int savedIndex) {
    _history.clear();
    // Re-create items for history.
    // Note: IDs will change on restore which is acceptable for session restoration
    _history.addAll(
      savedHistory.map(
        (snapshot) => snapshot.map((c) => PaletteItem.create(c)).toList(),
      ),
    );
    // Also restore current items
    if (savedIndex >= 0 && savedIndex < _history.length) {
      items = List<PaletteItem>.from(_history[savedIndex]);
      _currentHistoryIndex = savedIndex;
    } else {
      // Fallback
      _currentHistoryIndex = _history.length - 1;
    }
  }

  String getHexColor(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  Map<String, dynamic> toJson() {
    return {'colors': items.map((item) => item.color.toARGB32()).toList()};
  }

  factory ColorPaletteModel.fromJson(Map<String, dynamic> json) {
    final colors = (json['colors'] as List)
        .map((c) => Color(c as int))
        .toList();
    return ColorPaletteModel(
      items: colors.map((c) => PaletteItem.create(c)).toList(),
    );
  }

  // Helper to get simple color list for UI parts that might still rely on it temporarily
  List<Color> get colors => items.map((i) => i.color).toList();
}
