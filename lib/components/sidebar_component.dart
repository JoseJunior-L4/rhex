import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:rhex/l10n/app_localizations.dart';
import '../models/color_palette_model.dart';

class SidebarComponent extends StatefulWidget {
  final List<PaletteItem> items;
  final int gridSize;
  final Function(Color) onAddColor;
  final Function(int, Color) onColorUpdate;
  final Function(int) onGridSizeChange;
  final bool showHexLabels;
  final Function(bool) onToggleHexLabels;
  final Color? initialColor;
  final ValueChanged<Color>? onInputColorChange;

  const SidebarComponent({
    super.key,
    required this.items,
    required this.gridSize,
    required this.onAddColor,
    required this.onColorUpdate,
    required this.onGridSizeChange,
    required this.showHexLabels,
    required this.onToggleHexLabels,
    this.initialColor,
    this.onInputColorChange,
  });

  @override
  State<SidebarComponent> createState() => _SidebarComponentState();
}

class _SidebarComponentState extends State<SidebarComponent> {
  final TextEditingController _hexController = TextEditingController();
  final ScrollController _historyScrollController = ScrollController();
  Color _currentColor = const Color(0xFF000000);

  @override
  void initState() {
    super.initState();
    if (widget.initialColor != null) {
      _currentColor = widget.initialColor!;
    }
    _hexController.text = _getHexColor(_currentColor);
  }

  void _updateCurrentColor(Color color) {
    setState(() {
      _currentColor = color;
      _hexController.text = _getHexColor(color);
    });
    widget.onInputColorChange?.call(color);
  }

  @override
  void dispose() {
    _hexController.dispose();
    _historyScrollController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = _currentColor;

        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.labelPickColor),
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
              child: Text(AppLocalizations.of(context)!.actionSelect),
              onPressed: () {
                _updateCurrentColor(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getHexColor(Color color) {
    return '#${(color.r * 255).round().toRadixString(16).padLeft(2, '0')}${(color.g * 255).round().toRadixString(16).padLeft(2, '0')}${(color.b * 255).round().toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Future<void> _showBatchAddDialog() async {
    final TextEditingController batchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShadDialog(
          title: Text(AppLocalizations.of(context)!.dialogBatchAddTitle),
          description: Text(
            AppLocalizations.of(context)!.dialogBatchAddDescription,
          ),
          actions: [
            ShadButton.outline(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ShadButton(
              child: Text(AppLocalizations.of(context)!.actionProcess),
              onPressed: () async {
                Navigator.of(context).pop(); // Close input dialog
                await _processBatchColors(batchController.text);
              },
            ),
          ],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ShadInput(
                controller: batchController,
                maxLines: 8,
                minLines: 4,
                placeholder: const Text('#FF0000\n00FF00\n#0000FF'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processBatchColors(String text) async {
    List<String> lines = text.split('\n');
    List<Color> validColors = [];
    bool processingStopped = false;

    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      if (line.isEmpty) continue;

      // Clean # if exists
      String cleanHex = line.replaceAll('#', '').toUpperCase();

      // Validate
      bool isValid = false;
      if (cleanHex.length == 6) {
        try {
          int.parse(cleanHex, radix: 16);
          isValid = true;
        } catch (e) {
          isValid = false;
        }
      }

      if (isValid) {
        validColors.add(Color(int.parse('FF$cleanHex', radix: 16)));
      } else {
        // Show Error Dialog
        bool? shouldSkip = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return ShadDialog(
              title: Text(
                AppLocalizations.of(context)!.dialogInvalidColorTitle,
              ),
              description: Text(
                AppLocalizations.of(
                  context,
                )!.dialogInvalidColorDescription(i + 1, line),
              ),
              actions: [
                ShadButton.outline(
                  child: Text(AppLocalizations.of(context)!.actionStopAll),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ShadButton(
                  child: Text(AppLocalizations.of(context)!.actionSkipContinue),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          },
        );

        if (shouldSkip != true) {
          processingStopped = true;
          break; // Stop processing
        }
      }
    }

    // Add valid colors found so far
    for (var color in validColors) {
      widget.onAddColor(color);
    }

    if (mounted) {
      int processedCount = validColors.length;
      if (processedCount > 0) {
        ShadToaster.of(context).show(
          ShadToast(
            description: Text(
              processingStopped
                  ? AppLocalizations.of(
                      context,
                    )!.toastBatchProcessingStopped(processedCount)
                  : AppLocalizations.of(
                      context,
                    )!.toastBatchSuccess(processedCount),
            ),
          ),
        );
        if (!processingStopped) {
          ShadToaster.of(context).show(
            ShadToast(
              description: Text(
                AppLocalizations.of(context)!.toastBatchNoColors,
              ),
            ),
          );
        }
      }
    }
  }

  void _addRandomColor() {
    final random = Random();
    final color = Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
    _updateCurrentColor(color);
    widget.onAddColor(color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.background,
        border: Border(
          left: BorderSide(
            color: ShadTheme.of(context).colorScheme.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color Input Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.labelColorInput,
                  style: ShadTheme.of(context).textTheme.muted.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ShadInput(
                        controller: _hexController,
                        placeholder: const Text('#000000'),
                        onChanged: (value) {
                          String cleanHex = value
                              .replaceAll('#', '')
                              .trim()
                              .toUpperCase();
                          if (cleanHex.length == 6) {
                            try {
                              final color = Color(
                                int.parse(cleanHex, radix: 16) + 0xFF000000,
                              );
                              _updateCurrentColor(color);
                            } catch (e) {
                              // Invalid hex color
                            }
                          }
                        },
                        onSubmitted: (value) {
                          String cleanHex = value
                              .replaceAll('#', '')
                              .trim()
                              .toUpperCase();
                          if (cleanHex.length == 6) {
                            try {
                              final color = Color(
                                int.parse(cleanHex, radix: 16) + 0xFF000000,
                              );
                              _updateCurrentColor(color);
                              widget.onAddColor(color);
                              // Update text to formatted hex on submit if it was raw
                              if (!value.startsWith('#') || value.length != 7) {
                                _hexController.text = _getHexColor(color);
                              }
                            } catch (e) {
                              // Invalid hex color, reset to current color
                              _hexController.text = _getHexColor(_currentColor);
                            }
                          } else {
                            // Invalid format, reset to current color
                            _hexController.text = _getHexColor(_currentColor);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showColorPicker,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _currentColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: ShadTheme.of(context).colorScheme.border,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Color History Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.sidebarHistory,
                      style: ShadTheme.of(context).textTheme.muted.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    // History Scroll Controls
                    if (widget.items.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ShadIconButton.ghost(
                              icon: const Icon(
                                Remix.arrow_left_s_line,
                                size: 16,
                              ),
                              onPressed: () {
                                _historyScrollController.animateTo(
                                  _historyScrollController.offset - 60,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                            const SizedBox(width: 4),
                            ShadIconButton.ghost(
                              icon: const Icon(
                                Remix.arrow_right_s_line,
                                size: 16,
                              ),
                              onPressed: () {
                                _historyScrollController.animateTo(
                                  _historyScrollController.offset + 60,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Show empty state or horizontal scrollable history
                widget.items.isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.labelNoHistory,
                            style: ShadTheme.of(context).textTheme.muted
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 60,
                        child: SingleChildScrollView(
                          controller: _historyScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: widget.items.reversed.map((item) {
                              return _ColorHistoryItem(
                                color: item.color,
                                onTap: () {
                                  _updateCurrentColor(item.color);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Grid Size Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.sidebarGridSize,
                      style: ShadTheme.of(context).textTheme.muted.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${widget.gridSize}',
                          style: ShadTheme.of(context).textTheme.muted.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '16',
                          style: ShadTheme.of(context).textTheme.muted,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _GridSizeSlider(
                  gridSize: widget.gridSize,
                  onChanged: widget.onGridSizeChange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // View Options Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.sidebarHexLabels,
                  style: ShadTheme.of(context).textTheme.muted.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                ShadSwitch(
                  value: widget.showHexLabels,
                  onChanged: widget.onToggleHexLabels,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Add Color Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Row(
                    children: [
                      // Add Color Button
                      Expanded(
                        child: ShadButton(
                          backgroundColor: ShadTheme.of(
                            context,
                          ).textTheme.muted.color,
                          onPressed: () {
                            widget.onAddColor(_currentColor);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Remix.add_line, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.sidebarAddColor,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Dice Button (Random Color)
                      SizedBox(
                        width: 44,
                        child: ShadButton.outline(
                          onPressed: _addRandomColor,
                          padding: EdgeInsets.zero,
                          child: const Icon(Remix.dice_line, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ShadButton.outline(
                    onPressed: _showBatchAddDialog,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Remix.list_check_2, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)!.actionBatchAdd,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorHistoryItem extends StatefulWidget {
  final Color color;
  final VoidCallback onTap;

  const _ColorHistoryItem({required this.color, required this.onTap});

  @override
  State<_ColorHistoryItem> createState() => _ColorHistoryItemState();
}

class _ColorHistoryItemState extends State<_ColorHistoryItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            transform: _isHovered
                ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
                : Matrix4.identity(),
            // Align center to make the scale effect grow from center
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered
                    ? ShadTheme.of(context).colorScheme.primary
                    : ShadTheme.of(context).colorScheme.border,
                width: _isHovered ? 2 : 1,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridSizeSlider extends StatefulWidget {
  final int gridSize;
  final ValueChanged<int> onChanged;

  const _GridSizeSlider({required this.gridSize, required this.onChanged});

  @override
  State<_GridSizeSlider> createState() => _GridSizeSliderState();
}

class _GridSizeSliderState extends State<_GridSizeSlider> {
  // We use this key to force ShadSlider to rebuild only when necessary.
  // We want to rebuild it when 'gridSize' changes EXTERNALLY (e.g. initial load),
  // but NOT when it changes due to our own dragging.
  late int _localValue;
  late Key _sliderKey;

  @override
  void initState() {
    super.initState();
    _localValue = widget.gridSize;
    _sliderKey = ValueKey(widget.gridSize);
  }

  @override
  void didUpdateWidget(_GridSizeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the widget prop changed, and it DOES NOT match our current local value,
    // it means it changed externally (e.g. Undo/Redo/Persistence).
    // so we must force a rebuild.
    if (widget.gridSize != _localValue) {
      _localValue = widget.gridSize;
      _sliderKey = ValueKey('forced_${widget.gridSize}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadSlider(
      key: _sliderKey,
      initialValue: widget.gridSize.toDouble(),
      min: 1,
      max: 16,
      onChanged: (value) {
        _localValue = value.toInt();
        widget.onChanged(_localValue);
      },
    );
  }
}
