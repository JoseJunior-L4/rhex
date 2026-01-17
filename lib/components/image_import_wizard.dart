import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // 'image' package for pixel access
import 'package:remixicon/remixicon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ImageImportWizard extends StatefulWidget {
  final File file;

  const ImageImportWizard({super.key, required this.file});

  @override
  State<ImageImportWizard> createState() => _ImageImportWizardState();
}

class _ImageImportWizardState extends State<ImageImportWizard> {
  // Config state
  int _rows = 5;
  int _columns = 5;
  Color _gridColor = Colors.green;
  bool _isLoading = true;

  // Image state
  ui.Image? _uiImage; // For rendering
  img.Image? _decodedImage; // For pixel data extraction

  // Result state
  List<Color> _extractedColors = [];

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() => _isLoading = true);

    try {
      final bytes = await widget.file.readAsBytes();

      // Decode for rendering (dart:ui)
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;

      // Decode for processing (image package)
      // We run this in an isolate or just async if it's fast enough,
      // but for simplicity here we'll just await it.
      // compute() creates an Isolate which is better for heavy lifting.
      final decodedImage = await compute(img.decodeImage, bytes);

      if (mounted) {
        setState(() {
          _uiImage = uiImage;
          _decodedImage = decodedImage;
          _isLoading = false;
        });
        _extractColors();
      }
    } catch (e) {
      if (mounted) {
        // Handle error (could close dialog or show toast)
        Navigator.of(context).pop();
        ShadToaster.of(
          context,
        ).show(ShadToast(description: Text('Failed to load image: $e')));
      }
    }
  }

  void _extractColors() {
    if (_decodedImage == null) return;

    final image = _decodedImage!;
    final List<Color> colors = [];

    final cellWidth = image.width / _columns;
    final cellHeight = image.height / _rows;

    for (int y = 0; y < _rows; y++) {
      for (int x = 0; x < _columns; x++) {
        // Sample the center of the cell
        final centerX = (x * cellWidth + cellWidth / 2).floor();
        final centerY = (y * cellHeight + cellHeight / 2).floor();

        // Ensure bounds
        final safeX = centerX.clamp(0, image.width - 1);
        final safeY = centerY.clamp(0, image.height - 1);

        final pixel = image.getPixel(safeX, safeY);

        // Convert 'image' package pixel (rgba/bgra) to Flutter Color
        // img.Pixel access depends on version, usually r, g, b, a props
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        // Alpha might be 255 if opaque
        final a = pixel.a.toInt();

        // Skip transparent or near-transparent pixels
        if (a > 10) {
          colors.add(Color.fromARGB(a, r, g, b));
        }
      }
    }

    setState(() {
      _extractedColors = colors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 1000,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Palette from Image',
                      style: ShadTheme.of(context).textTheme.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Adjust grid to capture colors',
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Remix.close_line),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Panel: Image + Overlay
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRect(
                              child: InteractiveViewer(
                                minScale: 0.1,
                                maxScale: 5.0,
                                child: Center(
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      if (_uiImage == null) {
                                        return const SizedBox();
                                      }

                                      // Calculate fitted dimensions to match standard BoxFit.contain logic
                                      // so we can draw the grid accurately over it.
                                      final imgSize = Size(
                                        _uiImage!.width.toDouble(),
                                        _uiImage!.height.toDouble(),
                                      );

                                      return CustomPaint(
                                        foregroundPainter: _GridPainter(
                                          rows: _rows,
                                          columns: _columns,
                                          color: _gridColor,
                                          imageSize: imgSize,
                                        ),
                                        child: RawImage(
                                          image: _uiImage,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),

                        // Right Panel: Settings
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGridSettings(context),
                              const SizedBox(height: 24),
                              _buildPreview(context),
                              const Spacer(),
                              SizedBox(
                                width: double.infinity,
                                child: ShadButton(
                                  child: const Text('Import Colors'),
                                  onPressed: () {
                                    Navigator.of(context).pop(_extractedColors);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grid Settings',
          style: ShadTheme.of(
            context,
          ).textTheme.large.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        // Rows
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Rows', style: ShadTheme.of(context).textTheme.small),
            Text('$_rows', style: ShadTheme.of(context).textTheme.small),
          ],
        ),
        ShadSlider(
          initialValue: _rows.toDouble(),
          min: 1,
          max: 20,
          onChanged: (val) {
            setState(() {
              _rows = val.toInt();
            });
            _extractColors();
          },
        ),
        const SizedBox(height: 12),

        // Columns
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Columns', style: ShadTheme.of(context).textTheme.small),
            Text('$_columns', style: ShadTheme.of(context).textTheme.small),
          ],
        ),
        ShadSlider(
          initialValue: _columns.toDouble(),
          min: 1,
          max: 20,
          onChanged: (val) {
            setState(() {
              _columns = val.toInt();
            });
            _extractColors();
          },
        ),

        const SizedBox(height: 24),
        Text('Grid Visibility', style: ShadTheme.of(context).textTheme.small),
        const SizedBox(height: 8),
        Row(
          children: [
            _ColorOption(
              color: Colors.green,
              isSelected: _gridColor == Colors.green,
              onTap: () => setState(() => _gridColor = Colors.green),
            ),
            const SizedBox(width: 8),
            _ColorOption(
              color: Colors.red,
              isSelected: _gridColor == Colors.red,
              onTap: () => setState(() => _gridColor = Colors.red),
            ),
            const SizedBox(width: 8),
            _ColorOption(
              color: Colors.white,
              isSelected: _gridColor == Colors.white,
              onTap: () => setState(() => _gridColor = Colors.white),
            ),
            const SizedBox(width: 8),
            _ColorOption(
              color: Colors.black,
              isSelected: _gridColor == Colors.black,
              onTap: () => setState(() => _gridColor = Colors.black),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Extracted Colors',
                style: ShadTheme.of(
                  context,
                ).textTheme.large.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${_extractedColors.length}',
                style: ShadTheme.of(context).textTheme.muted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: _extractedColors.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: _extractedColors[index],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black12),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int rows;
  final int columns;
  final Color color;
  final Size imageSize;

  _GridPainter({
    required this.rows,
    required this.columns,
    required this.color,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scaling to determine where the image actually is within the widget 'size'
    // 'size' is the CustomPaint size (widget size)
    // 'imageSize' is the actual pixel dimensions of the image

    // FittedSizes calculates how BoxFit.contain scales and positions the content
    final fitted = applyBoxFit(BoxFit.contain, imageSize, size);
    final destRect = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & size,
    );

    // We only draw inside destRect
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw vertical lines
    final cellWidth = destRect.width / columns;
    for (int i = 0; i <= columns; i++) {
      final x = destRect.left + i * cellWidth;
      canvas.drawLine(
        Offset(x, destRect.top),
        Offset(x, destRect.bottom),
        paint,
      );
    }

    // Draw horizontal lines
    final cellHeight = destRect.height / rows;
    for (int i = 0; i <= rows; i++) {
      final y = destRect.top + i * cellHeight;
      canvas.drawLine(
        Offset(destRect.left, y),
        Offset(destRect.right, y),
        paint,
      );
    }

    // Draw center dots (visual feedback for sampling point)
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        final cx = destRect.left + (j * cellWidth) + (cellWidth / 2);
        final cy = destRect.top + (i * cellHeight) + (cellHeight / 2);
        canvas.drawCircle(Offset(cx, cy), 2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.columns != columns ||
        oldDelegate.color != color ||
        oldDelegate.imageSize != imageSize;
  }
}
