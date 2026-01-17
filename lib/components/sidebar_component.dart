import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SidebarComponent extends StatefulWidget {
  final List<Color> colors;
  final int gridSize;
  final Function(Color) onAddColor;
  final Function(int, Color) onColorUpdate;
  final Function(int) onGridSizeChange;
  final bool showHexLabels;
  final Function(bool) onToggleHexLabels;

  const SidebarComponent({
    super.key,
    required this.colors,
    required this.gridSize,
    required this.onAddColor,
    required this.onColorUpdate,
    required this.onGridSizeChange,
    required this.showHexLabels,
    required this.onToggleHexLabels,
  });

  @override
  State<SidebarComponent> createState() => _SidebarComponentState();
}

class _SidebarComponentState extends State<SidebarComponent> {
  final TextEditingController _hexController = TextEditingController();
  Color _currentColor = const Color(0xFF000000);

  @override
  void initState() {
    super.initState();
    _hexController.text = '#000000';
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = _currentColor;

        return AlertDialog(
          title: const Text('Pick a color'),
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
              child: const Text('Select'),
              onPressed: () {
                setState(() {
                  _currentColor = pickerColor;
                  _hexController.text =
                      '#${pickerColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getHexColor(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _showBatchAddDialog() async {
    final TextEditingController batchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShadDialog(
          title: const Text('Batch Add Colors'),
          description: const Text(
            'Paste hex codes (one per line). Format: #RRGGBB or RRGGBB',
          ),
          actions: [
            ShadButton.outline(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ShadButton(
              child: const Text('Process'),
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
              title: const Text('Invalid Color Found'),
              description: Text(
                'Line ${i + 1}: "$line" is not a valid hex code.',
              ),
              actions: [
                ShadButton.outline(
                  child: const Text('Stop All'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                ShadButton(
                  child: const Text('Skip & Continue'),
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
                  ? 'Added $processedCount valid colors. Processing stopped.'
                  : 'Successfully added $processedCount colors!',
            ),
          ),
        );
      } else if (!processingStopped) {
        ShadToaster.of(context).show(
          const ShadToast(description: Text('No valid colors found to add.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200, width: 1)),
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
                  'Color Input',
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
                          if (value.length == 7 && value.startsWith('#')) {
                            try {
                              final color = Color(
                                int.parse(value.substring(1), radix: 16) +
                                    0xFF000000,
                              );
                              setState(() {
                                _currentColor = color;
                              });
                            } catch (e) {
                              // Invalid hex color
                            }
                          }
                        },
                        onSubmitted: (value) {
                          // Allow submission with Enter key after typing/pasting
                          if (value.length == 7 && value.startsWith('#')) {
                            try {
                              final color = Color(
                                int.parse(value.substring(1), radix: 16) +
                                    0xFF000000,
                              );
                              setState(() {
                                _currentColor = color;
                                _hexController.text = value.toUpperCase();
                              });
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
                            color: Colors.grey.shade300,
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
                Text(
                  'Color History',
                  style: ShadTheme.of(context).textTheme.muted.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Show empty state or horizontal scrollable history
                widget.colors.isEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No colors in history yet',
                            style: ShadTheme.of(context).textTheme.muted
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 60,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: widget.colors.reversed.map((color) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentColor = color;
                                      _hexController.text = _getHexColor(color);
                                    });
                                  },
                                  child: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
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
                      'Grid Size',
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
                ShadSlider(
                  initialValue: widget.gridSize.toDouble(),
                  min: 1,
                  max: 16,
                  onChanged: (value) {
                    widget.onGridSizeChange(value.toInt());
                  },
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
                  'Show Hex Labels',
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
                  child: ShadButton(
                    backgroundColor: Colors.black,
                    onPressed: () {
                      widget.onAddColor(_currentColor);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Remix.add_line, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Add Color',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
                      children: const [
                        Icon(Remix.list_check_2, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Batch Add',
                          style: TextStyle(
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

          const SizedBox(height: 24),

          // Instructions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InstructionItem(
                  icon: Remix.circle_fill,
                  text: 'Click the color circle to open the color picker',
                ),
                const SizedBox(height: 8),
                _InstructionItem(
                  icon: Remix.hashtag,
                  text: 'Type hex codes directly or select from history',
                ),
                const SizedBox(height: 8),
                _InstructionItem(
                  icon: Remix.layout_grid_line,
                  text: 'Adjust grid size to organize your palette',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InstructionItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: ShadTheme.of(context).textTheme.muted.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}
