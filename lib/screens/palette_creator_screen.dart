import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../components/app_bar_component.dart';
import '../../components/color_grid_component.dart';
import '../../components/sidebar_component.dart';
import '../../components/image_import_wizard.dart';
import '../../components/shade_generator_dialog.dart';
import '../../components/help_dialog.dart';
import '../../models/color_palette_model.dart';
import '../../services/storage_service.dart';
import '../../l10n/app_localizations.dart';

class PaletteCreatorScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  const PaletteCreatorScreen({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
    required this.locale,
    required this.onLocaleChanged,
  });

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

  void _deleteColor(int index) {
    setState(() {
      _paletteModel.removeColorAt(index);
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
    setState(() {
      _currentInputColor = color;
    });
    _persistState();

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
          title: Text(AppLocalizations.of(context)!.dialogClearTitle),
          description: Text(
            AppLocalizations.of(context)!.dialogClearDescription,
          ),
          actions: [
            ShadButton.outline(
              child: Text(AppLocalizations.of(context)!.actionCancel),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ShadButton.destructive(
              child: Text(AppLocalizations.of(context)!.actionClear),
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
        ShadToaster.of(context).show(
          ShadToast(
            description: Text(
              AppLocalizations.of(context)!.toastPaletteCleared,
            ),
          ),
        );
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

          if (!mounted) return;

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
    if (_paletteModel.colors.isEmpty) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(const ShadToast(description: Text('No colors to export!')));
      }
      return;
    }

    // Show format selection dialog
    final format = await showDialog<String>(
      context: context,
      builder: (context) => ShadDialog(
        title: Text(AppLocalizations.of(context)!.dialogExportTitle),
        description: Text(AppLocalizations.of(context)!.dialogExportDescription),
        actions: [
          ShadButton.outline(
            child: Text(AppLocalizations.of(context)!.actionCancel),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ExportOption(
              icon: Remix.image_line,
              title: 'PNG Image',
              description: 'High-quality image of your palette grid',
              onTap: () => Navigator.of(context).pop('png'),
            ),
            const SizedBox(height: 8),
            _ExportOption(
              icon: Remix.code_s_slash_line,
              title: 'CSS Variables',
              description: 'CSS custom properties (--color-1, --color-2, ...)',
              onTap: () => Navigator.of(context).pop('css'),
            ),
            const SizedBox(height: 8),
            _ExportOption(
              icon: Remix.tailwind_css_fill,
              title: 'Tailwind Config',
              description: 'Colors object for tailwind.config.js',
              onTap: () => Navigator.of(context).pop('tailwind'),
            ),
            const SizedBox(height: 8),
            _ExportOption(
              icon: Remix.file_text_line,
              title: 'Hex List',
              description: 'Plain text list of hex codes (one per line)',
              onTap: () => Navigator.of(context).pop('text'),
            ),
          ],
        ),
      ),
    );

    if (format == null) return;

    try {
      switch (format) {
        case 'png':
          await _exportAsPng();
          break;
        case 'css':
          await _exportAsCss();
          break;
        case 'tailwind':
          await _exportAsTailwind();
          break;
        case 'text':
          await _exportAsText();
          break;
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('Error exporting palette: $e')));
      }
    }
  }

  Future<void> _exportAsPng() async {
    RenderRepaintBoundary boundary =
        _gridKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Palette as PNG',
      fileName: 'palette.png',
      type: FileType.custom,
      allowedExtensions: ['png'],
    );

    if (outputFile != null) {
      if (!outputFile.endsWith('.png')) {
        outputFile += '.png';
      }
      final file = File(outputFile);
      await file.writeAsBytes(pngBytes);
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(description: Text('Palette exported as PNG!')),
        );
      }
    }
  }

  String _colorToHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  Future<void> _exportAsCss() async {
    final buffer = StringBuffer();
    buffer.writeln(':root {');
    for (int i = 0; i < _paletteModel.colors.length; i++) {
      final hex = _colorToHex(_paletteModel.colors[i]);
      buffer.writeln('  --color-${i + 1}: $hex;');
    }
    buffer.writeln('}');

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Palette as CSS',
      fileName: 'palette.css',
      type: FileType.custom,
      allowedExtensions: ['css'],
    );

    if (outputFile != null) {
      if (!outputFile.endsWith('.css')) {
        outputFile += '.css';
      }
      final file = File(outputFile);
      await file.writeAsString(buffer.toString());
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(description: Text('Palette exported as CSS!')),
        );
      }
    }
  }

  Future<void> _exportAsTailwind() async {
    final buffer = StringBuffer();
    buffer.writeln('// Add to your tailwind.config.js theme.extend.colors');
    buffer.writeln('const palette = {');
    for (int i = 0; i < _paletteModel.colors.length; i++) {
      final hex = _colorToHex(_paletteModel.colors[i]);
      final comma = i < _paletteModel.colors.length - 1 ? ',' : '';
      buffer.writeln("  'color-${i + 1}': '$hex'$comma");
    }
    buffer.writeln('};');

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Palette as Tailwind Config',
      fileName: 'palette-tailwind.js',
      type: FileType.custom,
      allowedExtensions: ['js'],
    );

    if (outputFile != null) {
      if (!outputFile.endsWith('.js')) {
        outputFile += '.js';
      }
      final file = File(outputFile);
      await file.writeAsString(buffer.toString());
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(description: Text('Palette exported as Tailwind config!')),
        );
      }
    }
  }

  Future<void> _exportAsText() async {
    final buffer = StringBuffer();
    for (final color in _paletteModel.colors) {
      buffer.writeln(_colorToHex(color));
    }

    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Palette as Text',
      fileName: 'palette.txt',
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (outputFile != null) {
      if (!outputFile.endsWith('.txt')) {
        outputFile += '.txt';
      }
      final file = File(outputFile);
      await file.writeAsString(buffer.toString());
      if (mounted) {
        ShadToaster.of(context).show(
          const ShadToast(description: Text('Palette exported as text!')),
        );
      }
    }
  }

  void _editColor(int index) {
    // Set the current input color to the selected color
    setState(() {
      _currentInputColor = _paletteModel.colors[index];
    });
    _persistState();

    Color pickerColor = _paletteModel.colors[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ShadDialog(
              title: Text(AppLocalizations.of(context)!.dialogEditColorTitle),
              description: Text(AppLocalizations.of(context)!.dialogEditColorDescription),
              actions: [
                ShadButton.outline(
                  child: Text(AppLocalizations.of(context)!.actionCancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ShadButton(
                  child: Text(AppLocalizations.of(context)!.actionUpdate),
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
              child: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (Color color) {
                    setDialogState(() {
                      pickerColor = color;
                    });
                  },
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
            );
          },
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
            backgroundColor: ShadTheme.of(context).colorScheme.background,
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
                            onToggleTheme: widget.onToggleTheme,
                            themeMode: widget.themeMode,
                            locale: widget.locale,
                            onLocaleChanged: widget.onLocaleChanged,
                          ),
                          // Color Grid
                          Expanded(
                            child: ColorGridComponent(
                              scrollController: _mainGridScrollController,
                              globalKey: _gridKey,
                              colors: _paletteModel.colors,
                              gridSize: _gridSize,
                              onColorTap: (index) {
                                _editColor(index);
                              },
                              onColorRightClick: _showShadeGenerator,
                              onColorDelete: _deleteColor,
                              onReorder: _reorderColor,
                              showHexLabels: _showHexLabels,
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

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: ShadTheme.of(context).colorScheme.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ShadTheme.of(context).textTheme.p.copyWith(fontWeight: FontWeight.w600)),
                    Text(description, style: ShadTheme.of(context).textTheme.muted),
                  ],
                ),
              ),
              Icon(Remix.arrow_right_s_line, color: ShadTheme.of(context).colorScheme.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }
}
