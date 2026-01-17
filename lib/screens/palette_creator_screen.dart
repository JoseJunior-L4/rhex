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
import '../../components/shade_generator_dialog.dart';
import '../../components/help_dialog.dart';
import '../../models/color_palette_model.dart';
import '../../services/storage_service.dart';

class PaletteCreatorScreen extends StatefulWidget {
  const PaletteCreatorScreen({super.key});

  @override
  State<PaletteCreatorScreen> createState() => _PaletteCreatorScreenState();
}

class _PaletteCreatorScreenState extends State<PaletteCreatorScreen> {
  final ColorPaletteModel _paletteModel = ColorPaletteModel(
    colors: [], // Start with empty palette
  );
  final StorageService _storageService = StorageService();

  int _gridSize = 4;
  bool _showHexLabels = true;
  bool _isImporting = false;
  Color _currentInputColor = const Color(0xFF000000); // Default color
  bool _isSidebarCollapsed = false;
  final GlobalKey _gridKey = GlobalKey();
  final ScrollController _mainGridScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final state = await _storageService.loadPaletteState();
    if (mounted) {
      setState(() {
        _paletteModel.colors = state['colors'];
        _gridSize = state['gridSize'];
        _showHexLabels = state['showHexLabels'];
        if (state['currentColor'] != null) {
          _currentInputColor = state['currentColor'];
        }
        // Restore history if available
        if (state['history'] != null && state['historyIndex'] != null) {
          _paletteModel.restoreHistory(
            state['history'] as List<List<Color>>,
            state['historyIndex'] as int,
          );
        }
        _isSidebarCollapsed = state['sidebarCollapsed'] ?? false;
      });
    }
  }

  void _persistState() {
    _storageService.savePaletteState(
      colors: _paletteModel.colors,
      gridSize: _gridSize,
      showHexLabels: _showHexLabels,
      currentColor: _currentInputColor,
      history: _paletteModel.getHistory(),
      historyIndex: _paletteModel.getHistoryIndex(),
      sidebarCollapsed: _isSidebarCollapsed,
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
    _persistState();
  }

  void _addColor(Color color) {
    setState(() {
      _paletteModel.addColor(color);
    });
    _persistState();
  }

  void _updateColor(int index, Color color) {
    setState(() {
      _paletteModel.updateColor(index, color);
    });
    _persistState();
  }

  @override
  void dispose() {
    _mainGridScrollController.dispose();
    super.dispose();
  }

  void _updateGridSize(int size) {
    setState(() {
      _gridSize = size;
    });
    _persistState();
  }

  void _reorderColor(int oldIndex, int newIndex) {
    setState(() {
      _paletteModel.reorderColor(oldIndex, newIndex);
    });
    _persistState();
  }

  void _toggleHexLabels(bool value) {
    setState(() {
      _showHexLabels = value;
    });
    _persistState();
  }

  void _showShadeGenerator(int index) {
    final color = _paletteModel.colors[index];
    showDialog(
      context: context,
      builder: (context) => ShadeGeneratorDialog(
        baseColor: color,
        onAddColor: (generatedColor) {
          _addColor(generatedColor);
        },
      ),
    );
  }

  void _undo() {
    setState(() {
      _paletteModel.undo();
    });
    _persistState();
  }

  void _redo() {
    setState(() {
      _paletteModel.redo();
    });
    _persistState();
  }

  Future<void> _clearPalette() async {
    if (_paletteModel.colors.isEmpty) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return ShadDialog(
          title: const Text('Clear Palette?'),
          description: const Text(
            'Are you sure you want to remove all colors? This action can be undone.',
          ),
          actions: [
            ShadButton.outline(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ShadButton.destructive(
              child: const Text('Clear All'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _paletteModel.clear();
      });
      _persistState();
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(const ShadToast(description: Text('Palette cleared')));
      }
    }
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
          _paletteModel.loadColors(ColorPaletteModel.fromJson(json).colors);
          if (json.containsKey('gridSize')) {
            _gridSize = json['gridSize'];
          }
        });
        _persistState();

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
    if (_isImporting) return; // Prevent spam

    setState(() {
      _isImporting = true;
    });

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
            _persistState();
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
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
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
    // Set the current input color to the selected color
    setState(() {
      _currentInputColor = _paletteModel.colors[index];
    });
    _persistState();

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
                setState(() {
                  _currentInputColor = pickerColor;
                });
                _persistState();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showHelp() {
    showDialog(context: context, builder: (context) => const HelpDialog());
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
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.delete):
            const _ClearIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.backspace):
            const _ClearIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const _SaveIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyO):
            const _OpenIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyI):
            const _ImportIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE):
            const _ExportIntent(),
        LogicalKeySet(LogicalKeyboardKey.f1): const _HelpIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.slash):
            const _HelpIntent(),
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
          _ClearIntent: CallbackAction<_ClearIntent>(
            onInvoke: (_) {
              _clearPalette();
              return null;
            },
          ),
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) {
              _save();
              return null;
            },
          ),
          _OpenIntent: CallbackAction<_OpenIntent>(
            onInvoke: (_) {
              _open();
              return null;
            },
          ),
          _ImportIntent: CallbackAction<_ImportIntent>(
            onInvoke: (_) {
              _importImage();
              return null;
            },
          ),
          _ExportIntent: CallbackAction<_ExportIntent>(
            onInvoke: (_) {
              _export();
              return null;
            },
          ),
          _HelpIntent: CallbackAction<_HelpIntent>(
            onInvoke: (_) {
              _showHelp();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Auto-collapse sidebar on small screens
                final bool shouldAutoCollapse = constraints.maxWidth < 1024;

                return Row(
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
                            onClear: _clearPalette,
                            onHelp: _showHelp,
                            onToggleSidebar: _toggleSidebar,
                          ),
                          // Color Grid
                          Expanded(
                            child: Scrollbar(
                              controller: _mainGridScrollController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _mainGridScrollController,
                                child: RepaintBoundary(
                                  key: _gridKey,
                                  child: ColorGridComponent(
                                    colors: _paletteModel.colors,
                                    gridSize: _gridSize,
                                    onColorTap: (index) {
                                      _editColor(index);
                                    },
                                    onColorRightClick: _showShadeGenerator,
                                    onReorder: _reorderColor,
                                    showHexLabels: _showHexLabels,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sidebar with animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width:
                          (_isSidebarCollapsed && !shouldAutoCollapse) ||
                              shouldAutoCollapse
                          ? 0
                          : 300,
                      child:
                          _isSidebarCollapsed && !shouldAutoCollapse ||
                              shouldAutoCollapse
                          ? const SizedBox.shrink()
                          : SidebarComponent(
                              colors: _paletteModel.colors,
                              gridSize: _gridSize,
                              onAddColor: _addColor,
                              onColorUpdate: _updateColor,
                              onGridSizeChange: _updateGridSize,
                              showHexLabels: _showHexLabels,
                              onToggleHexLabels: _toggleHexLabels,
                              initialColor: _currentInputColor,
                              onInputColorChange: (color) {
                                _currentInputColor = color;
                                _persistState();
                              },
                            ),
                    ),
                  ],
                );
              },
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

class _ClearIntent extends Intent {
  const _ClearIntent();
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

class _OpenIntent extends Intent {
  const _OpenIntent();
}

class _ImportIntent extends Intent {
  const _ImportIntent();
}

class _ExportIntent extends Intent {
  const _ExportIntent();
}

class _HelpIntent extends Intent {
  const _HelpIntent();
}
