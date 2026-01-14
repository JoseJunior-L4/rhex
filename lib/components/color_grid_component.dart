import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class ColorGridComponent extends StatelessWidget {
  final List<Color> colors;
  final int gridSize;
  final Function(int) onColorTap;

  const ColorGridComponent({
    super.key,
    required this.colors,
    required this.gridSize,
    required this.onColorTap,
  });

  String _getHexColor(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    // Show empty state message when no colors
    if (colors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Remix.palette_line, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No colors yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click "Add Color" in the sidebar to start building your palette',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          childAspectRatio: 1.0,
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
        ),
        itemCount: colors.length,
        itemBuilder: (context, index) {
          return ColorTile(
            color: colors[index],
            hexCode: _getHexColor(colors[index]),
            onTap: () => onColorTap(index),
          );
        },
      ),
    );
  }
}

class ColorTile extends StatefulWidget {
  final Color color;
  final String hexCode;
  final VoidCallback onTap;

  const ColorTile({
    super.key,
    required this.color,
    required this.hexCode,
    required this.onTap,
  });

  @override
  State<ColorTile> createState() => _ColorTileState();
}

class _ColorTileState extends State<ColorTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(_isHovered ? 8 : 0),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(_isHovered ? 12 : 0),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            children: [
              // Hex code overlay (bottom-left) - Always visible
              Positioned(
                left: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getContrastColor(widget.color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _getContrastColor(widget.color).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.hexCode,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getContrastColor(widget.color),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              // Hover indicator
              if (_isHovered)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getContrastColor(widget.color).withOpacity(0.1),
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
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
