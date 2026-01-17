import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ShadeGeneratorDialog extends StatelessWidget {
  final Color baseColor;
  final Function(Color) onAddColor;

  const ShadeGeneratorDialog({
    super.key,
    required this.baseColor,
    required this.onAddColor,
  });

  /// Convert RGB Color to HSL
  HSLColor _toHSL(Color color) {
    return HSLColor.fromColor(color);
  }

  /// Generate tints (lighter variations)
  List<Color> _generateTints() {
    final hsl = _toHSL(baseColor);
    return [
      hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness + 0.3).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness + 0.4).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness + 0.5).clamp(0.0, 1.0)).toColor(),
    ];
  }

  /// Generate shades (darker variations)
  List<Color> _generateShades() {
    final hsl = _toHSL(baseColor);
    return [
      hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness - 0.3).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness - 0.4).clamp(0.0, 1.0)).toColor(),
      hsl.withLightness((hsl.lightness - 0.5).clamp(0.0, 1.0)).toColor(),
    ];
  }

  String _getHexColor(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tints = _generateTints();
    final shades = _generateShades();
    final screenSize = MediaQuery.of(context).size;

    return ShadDialog(
      title: const Text('Shade Generator'),
      description: Text(
        'Generate tints and shades for ${_getHexColor(baseColor)}',
      ),
      constraints: BoxConstraints(
        maxWidth: screenSize.width * 0.7,
        maxHeight: screenSize.height * 0.8,
      ),
      actions: [
        ShadButton.outline(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            // Base Color
            _ColorSection(
              title: 'Base Color',
              colors: [baseColor],
              onAddColor: onAddColor,
            ),
            const SizedBox(height: 24),
            // Tints
            _ColorSection(
              title: 'Tints (Lighter)',
              colors: tints,
              onAddColor: onAddColor,
            ),
            const SizedBox(height: 24),
            // Shades
            _ColorSection(
              title: 'Shades (Darker)',
              colors: shades,
              onAddColor: onAddColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSection extends StatelessWidget {
  final String title;
  final List<Color> colors;
  final Function(Color) onAddColor;

  const _ColorSection({
    required this.title,
    required this.colors,
    required this.onAddColor,
  });

  String _getHexColor(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}'
        .toUpperCase();
  }

  Color _getContrastColor(Color color) {
    final luminance = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: ShadTheme.of(
            context,
          ).textTheme.large.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            return _ColorVariation(
              color: color,
              hexCode: _getHexColor(color),
              contrastColor: _getContrastColor(color),
              onAdd: () {
                onAddColor(color);
                ShadToaster.of(context).show(
                  ShadToast(
                    title: const Text('Color Added'),
                    description: Text(
                      '${_getHexColor(color)} added to palette',
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ColorVariation extends StatefulWidget {
  final Color color;
  final String hexCode;
  final Color contrastColor;
  final VoidCallback onAdd;

  const _ColorVariation({
    required this.color,
    required this.hexCode,
    required this.contrastColor,
    required this.onAdd,
  });

  @override
  State<_ColorVariation> createState() => _ColorVariationState();
}

class _ColorVariationState extends State<_ColorVariation> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered
                ? widget.contrastColor.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            // Hex code
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.contrastColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: widget.contrastColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.hexCode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.contrastColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            // Add button (visible on hover)
            if (_isHovered)
              Center(
                child: ShadButton(
                  size: ShadButtonSize.sm,
                  onPressed: widget.onAdd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Remix.add_line, size: 14, color: widget.color),
                      const SizedBox(width: 4),
                      Text('Add', style: TextStyle(color: widget.color)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
