import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../components/app_bar_component.dart';
import '../../components/color_grid_component.dart';
import '../../components/sidebar_component.dart';
import '../../models/color_palette_model.dart';

class PaletteCreatorScreen extends StatefulWidget {
  const PaletteCreatorScreen({super.key});

  @override
  State<PaletteCreatorScreen> createState() => _PaletteCreatorScreenState();
}

class _PaletteCreatorScreenState extends State<PaletteCreatorScreen> {
  final ColorPaletteModel _paletteModel = ColorPaletteModel(
    colors: [], // Start with empty palette
  );

  int _gridSize = 4;

  void _addColor(Color color) {
    setState(() {
      _paletteModel.addColor(color);
    });
  }

  void _removeColor(int index) {
    setState(() {
      _paletteModel.removeColorAt(index);
    });
  }

  void _updateColor(int index, Color color) {
    setState(() {
      _paletteModel.updateColorAt(index, color);
    });
  }

  void _updateGridSize(int size) {
    setState(() {
      _gridSize = size;
    });
  }

  void _undo() {
    setState(() {
      _paletteModel.undo();
    });
  }

  void _redo() {
    setState(() {
      _paletteModel.redo();
    });
  }

  void _open() {
    // Implement open functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Open functionality')));
  }

  void _save() {
    // Implement save functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved successfully!')));
  }

  void _export() {
    // Implement export functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Export functionality')));
  }

  void _editColor(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = _paletteModel.colors[index];

        return AlertDialog(
          title: const Text('Edit Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ShadButton(
              child: const Text('Update'),
              onPressed: () {
                _updateColor(index, pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
            const _UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyY):
            const _RedoIntent(),
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyZ,
        ): const _RedoIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _UndoIntent: CallbackAction<_UndoIntent>(
            onInvoke: (_) {
              if (_paletteModel.canUndo) {
                _undo();
              }
              return null;
            },
          ),
          _RedoIntent: CallbackAction<_RedoIntent>(
            onInvoke: (_) {
              if (_paletteModel.canRedo) {
                _redo();
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Row(
              children: [
                // Main content area
                Expanded(
                  child: Column(
                    children: [
                      // App Bar
                      AppBarComponent(
                        onUndo: _undo,
                        onRedo: _redo,
                        onOpen: _open,
                        onSave: _save,
                        onExport: _export,
                      ),
                      // Color Grid
                      Expanded(
                        child: ColorGridComponent(
                          colors: _paletteModel.colors,
                          gridSize: _gridSize,
                          onColorTap: (index) {
                            _editColor(index);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Sidebar
                SidebarComponent(
                  colors: _paletteModel.colors,
                  gridSize: _gridSize,
                  onAddColor: _addColor,
                  onColorUpdate: _updateColor,
                  onGridSizeChange: _updateGridSize,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Intent classes for keyboard shortcuts
class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _RedoIntent extends Intent {
  const _RedoIntent();
}
