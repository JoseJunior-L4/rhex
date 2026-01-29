import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

class ColorGridComponent extends StatelessWidget {
  final List<Color> colors;
  final int gridSize;
  final Function(int) onColorTap;
  final Function(int)? onColorRightClick;
  final Function(int)? onColorDelete;
  final Function(int, int) onReorder;
  final bool showHexLabels;
  final ScrollController? scrollController;
  final GlobalKey<State<StatefulWidget>>? globalKey;

  const ColorGridComponent({
    super.key,
    required this.colors,
    required this.gridSize,
    required this.onColorTap,
    this.onColorRightClick,
    this.onColorDelete,
    required this.onReorder,
    this.showHexLabels = true,
    this.scrollController,
    this.globalKey,
  });

  String _getHexColor(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    // Show empty state message when no colors
    if (colors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Remix.palette_line, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No colors yet', style: ShadTheme.of(context).textTheme.h3),
            const SizedBox(height: 8),
            Text(
              'Click "Add Color" in the sidebar to start building your palette',
              style: ShadTheme.of(context).textTheme.muted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Scrollbar(
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        child: RepaintBoundary(
          key: globalKey,
          child: ReorderableGridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridSize,
              childAspectRatio: 1.0,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: colors.length,
            onReorder: onReorder,
            itemBuilder: (context, index) {
              return ColorTile(
                key: ValueKey('color_${colors[index].toARGB32()}_$index'),
                color: colors[index],
                hexCode: _getHexColor(colors[index]),
                onTap: () => onColorTap(index),
                onRightClick: onColorRightClick != null
                    ? () => onColorRightClick!(index)
                    : null,
                onDelete: onColorDelete != null
                    ? () => onColorDelete!(index)
                    : null,
                showHexLabels: showHexLabels,
              );
            },
          ),
        ),
      ),
    );
  }
}

class ColorTile extends StatefulWidget {
  final Color color;
  final String hexCode;
  final VoidCallback onTap;
  final VoidCallback? onRightClick;
  final VoidCallback? onDelete;
  final bool showHexLabels;

  const ColorTile({
    super.key,
    required this.color,
    required this.hexCode,
    required this.onTap,
    this.onRightClick,
    this.onDelete,
    required this.showHexLabels,
  });

  @override
  State<ColorTile> createState() => _ColorTileState();
}

class _ColorTileState extends State<ColorTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTap: widget.onRightClick,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? Matrix4.identity()
              : Matrix4.diagonal3Values(1.005, 1.005, 1.0),
          transformAlignment: Alignment.center,
          margin: EdgeInsets.all(_isHovered ? 8 : 0),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(_isHovered ? 8 : 0),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Hex code overlay (bottom-left) - click to copy
              if (widget.showHexLabels)
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: widget.hexCode));
                          ShadToaster.of(context).show(
                            ShadToast(
                              description: Text('Copied ${widget.hexCode}'),
                            ),
                          );
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.copy,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getContrastColor(
                                widget.color,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _getContrastColor(
                                  widget.color,
                                ).withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.hexCode,
                                  style: ShadTheme.of(context).textTheme.small.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: _getContrastColor(widget.color),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Remix.file_copy_line,
                                  size: 12,
                                  color: _getContrastColor(widget.color).withValues(alpha: 0.7),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Delete button (top-right) - only on hover
              if (_isHovered && widget.onDelete != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _getContrastColor(widget.color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Remix.delete_bin_line,
                          color: _getContrastColor(widget.color),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              // Hover indicator (center edit icon)
              if (_isHovered)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getContrastColor(
                        widget.color,
                      ).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Remix.edit_2_line,
                      color: _getContrastColor(widget.color),
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate relative luminance
    final luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
