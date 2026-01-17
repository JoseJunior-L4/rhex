import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../components/app_bar_component.dart';
import '../../components/color_grid_component.dart';
import '../../components/sidebar_component.dart';
import '../../components/image_import_wizard.dart';
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
  bool _showHexLabels = true;
  final GlobalKey _gridKey = GlobalKey();

  void _addColor(Color color) {
    setState(() {
      _paletteModel.addColor(color);
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

  void _toggleHexLabels(bool value) {
    setState(() {
      _showHexLabels = value;
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

  Future<void> _open() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        Map<String, dynamic> json = jsonDecode(content);

        setState(() {
          _paletteModel.colors = ColorPaletteModel.fromJson(json).colors;
          if (json.containsKey('gridSize')) {
            _gridSize = json['gridSize'];
          }
          // Reset history on load (optional, but good practice)
          // _paletteModel.clearHistory(); // If you had this method
        });

        if (mounted) {
          ShadToaster.of(context).show(
            const ShadToast(description: Text('Palette loaded successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('Error loading palette: $e')));
      }
    }
  }

  Future<void> _save() async {
    try {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Palette',
        fileName: 'palette.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        // Ensure extension
        if (!outputFile.endsWith('.json')) {
          outputFile += '.json';
        }

        final file = File(outputFile);
        final Map<String, dynamic> data = _paletteModel.toJson();
        data['gridSize'] = _gridSize;

        await file.writeAsString(jsonEncode(data));

        if (mounted) {
          ShadToaster.of(context).show(
            const ShadToast(description: Text('Palette saved successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('Error saving palette: $e')));
      }
    }
  }

  Future<void> _importImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        File file = File(result.files.single.path!);

        if (mounted) {
          final List<Color>? importedColors = await showDialog<List<Color>>(
            context: context,
            barrierDismissible: false, // Force user to close via button
            builder: (context) => ImageImportWizard(file: file),
          );

          if (importedColors != null && importedColors.isNotEmpty) {
            setState(() {
              // Append imported colors
              for (final color in importedColors) {
                _paletteModel.addColor(color);
              }
            });
            ShadToaster.of(context).show(
              ShadToast(
                description: Text(
                  'Imported ${importedColors.length} colors successfully!',
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('Error importing image: $e')));
      }
    }
  }

  Future<void> _export() async {
    try {
      if (_paletteModel.colors.isEmpty) {
        if (mounted) {
          ShadToaster.of(
            context,
          ).show(const ShadToast(description: Text('No colors to export!')));
        }
        return;
      }

      // Capture the widget as an image
      RenderRepaintBoundary boundary =
          _gridKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save the image
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Palette as PNG',
        fileName: 'palette.png',
        type: FileType.custom,
        allowedExtensions: ['png'],
      );

      if (outputFile != null) {
        // Ensure extension
        if (!outputFile.endsWith('.png')) {
          outputFile += '.png';
        }

        final file = File(outputFile);
        await file.writeAsBytes(pngBytes);

        if (mounted) {
          ShadToaster.of(context).show(
            const ShadToast(
              description: Text('Palette exported successfully!'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('Error exporting palette: $e')));
      }
    }
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
                        onImport: _importImage,
                      ),
                      // Color Grid
                      Expanded(
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            child: RepaintBoundary(
                              key: _gridKey,
                              child: ColorGridComponent(
                                colors: _paletteModel.colors,
                                gridSize: _gridSize,
                                onColorTap: (index) {
                                  _editColor(index);
                                },
                                showHexLabels: _showHexLabels,
                              ),
                            ),
                          ),
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
                  showHexLabels: _showHexLabels,
                  onToggleHexLabels: _toggleHexLabels,
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
