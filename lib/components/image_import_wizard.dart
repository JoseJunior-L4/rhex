import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // 'image' package for pixel access
import 'package:remixicon/remixicon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:rhex/l10n/app_localizations.dart';

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

  // Advanced Settings
  bool _isAdvancedMode = false;
  double _offsetX = 0.0;
  double _offsetY = 0.0;
  double _marginTop = 0.0;
  double _marginRight = 0.0;
  double _marginBottom = 0.0;
  double _marginLeft = 0.0;
  double _paddingX = 0.0; // Horizontal padding between cells
  double _paddingY = 0.0; // Vertical padding between cells
  double _cellSpacingX = 0.0; // Additional spacing
  double _cellSpacingY = 0.0;

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
        ShadToaster.of(context).show(
          ShadToast(
            description: Text(
              AppLocalizations.of(
                context,
              )!.toastErrorLoadingImage(e.toString()),
            ),
          ),
        );
      }
    }
  }

  void _extractColors() {
    if (_decodedImage == null) return;

    final image = _decodedImage!;
    final List<Color> colors = [];

    // Calculate effective area dimensions
    final double effectiveWidth =
        image.width.toDouble() - _marginLeft - _marginRight;
    final double effectiveHeight =
        image.height.toDouble() - _marginTop - _marginBottom;

    // Calculate total padding/spacing reduction
    // Padding is internal to cell calculation logic (shrinking the sample area)
    // Spacing is external (gap between cells)
    // Here we'll treat them combined for the grid layout logic as per standard sprite editors
    // Note: Usually "padding" in sprite editors shrinks the sprite within the grid cell,
    // while "spacing" adds gap between grid cells.

    // Spacing reduces the available space for cells *across the grid*
    // Total spacing width = (columns - 1) * spacingX
    final double totalSpacingX = (_columns - 1) * _cellSpacingX;
    final double totalSpacingY = (_rows - 1) * _cellSpacingY;

    // Remaining space for actual cells
    final double availableWidthForCells = effectiveWidth - totalSpacingX;
    final double availableHeightForCells = effectiveHeight - totalSpacingY;

    // Base cell dimensions
    final double cellWidth = availableWidthForCells / _columns;
    final double cellHeight = availableHeightForCells / _rows;

    for (int y = 0; y < _rows; y++) {
      for (int x = 0; x < _columns; x++) {
        // Calculate cell origin
        final double cellLeft =
            _marginLeft + _offsetX + (x * (cellWidth + _cellSpacingX));
        final double cellTop =
            _marginTop + _offsetY + (y * (cellHeight + _cellSpacingY));

        // Apply padding (which shrinks the sampling area from the edges of the cell)
        // Padding X shrinks left and right, Padding Y shrinks top and bottom
        final double sampleRegionLeft = cellLeft + _paddingX;
        final double sampleRegionTop = cellTop + _paddingY;
        final double sampleRegionWidth = cellWidth - (_paddingX * 2);
        final double sampleRegionHeight = cellHeight - (_paddingY * 2);

        // Sample the center of the padded region
        final centerX = (sampleRegionLeft + sampleRegionWidth / 2).floor();
        final centerY = (sampleRegionTop + sampleRegionHeight / 2).floor();

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
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 900;

    return Dialog(
      backgroundColor: ShadTheme.of(context).colorScheme.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ShadTheme.of(context).colorScheme.border),
      ),
      child: Container(
        width: isSmallScreen ? screenSize.width * 0.95 : (screenSize.width * 0.9).clamp(600.0, 1200.0),
        height: isSmallScreen ? screenSize.height * 0.9 : (screenSize.height * 0.9).clamp(400.0, 800.0),
        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
                      AppLocalizations.of(context)!.importWizardTitle,
                      style: ShadTheme.of(context).textTheme.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.importWizardDescription,
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
                  : isSmallScreen
                      ? _buildVerticalLayout(context)
                      : _buildHorizontalLayout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Panel: Image + Overlay
        Expanded(
          flex: 3,
          child: _buildImagePanel(context),
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
              _buildImportButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Column(
      children: [
        // Image Panel (takes available space)
        Expanded(
          flex: 2,
          child: _buildImagePanel(context),
        ),
        const SizedBox(height: 16),
        // Settings and Preview (scrollable on small screens)
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompactGridSettings(context),
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: _buildPreviewGrid(context),
                ),
                const SizedBox(height: 16),
                _buildImportButton(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ShadTheme.of(context).colorScheme.border,
        ),
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
                    offsetX: _offsetX,
                    offsetY: _offsetY,
                    marginTop: _marginTop,
                    marginRight: _marginRight,
                    marginBottom: _marginBottom,
                    marginLeft: _marginLeft,
                    paddingX: _paddingX,
                    paddingY: _paddingY,
                    cellSpacingX: _cellSpacingX,
                    cellSpacingY: _cellSpacingY,
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
    );
  }

  Widget _buildImportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ShadButton(
        child: Text(
          AppLocalizations.of(context)!.actionImportColors,
        ),
        onPressed: () {
          Navigator.of(context).pop(_extractedColors);
        },
      ),
    );
  }

  Widget _buildCompactGridSettings(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.labelRows, style: ShadTheme.of(context).textTheme.small),
              ShadSlider(
                initialValue: _rows.toDouble(),
                min: 1,
                max: 50,
                onChanged: (val) {
                  setState(() => _rows = val.toInt());
                  _extractColors();
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.labelColumns, style: ShadTheme.of(context).textTheme.small),
              ShadSlider(
                initialValue: _columns.toDouble(),
                min: 1,
                max: 50,
                onChanged: (val) {
                  setState(() => _columns = val.toInt());
                  _extractColors();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewGrid(BuildContext context) {
    return GridView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _extractedColors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: _extractedColors[index],
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: ShadTheme.of(context).colorScheme.border,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridSettings(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.labelGridSettings,
                style: ShadTheme.of(
                  context,
                ).textTheme.large.copyWith(fontWeight: FontWeight.w600),
              ),
              // Advanced Toggle
              Row(
                children: [
                  Text(
                    'Advanced',
                    style: ShadTheme.of(context).textTheme.small,
                  ),
                  const SizedBox(width: 8),
                  ShadSwitch(
                    value: _isAdvancedMode,
                    onChanged: (val) {
                      setState(() {
                        _isAdvancedMode = val;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.labelRows,
                style: ShadTheme.of(context).textTheme.small,
              ),
              Text('$_rows', style: ShadTheme.of(context).textTheme.small),
            ],
          ),
          const SizedBox(height: 12),
          ShadSlider(
            initialValue: _rows.toDouble(),
            min: 1,
            max: 50,
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
              Text(
                AppLocalizations.of(context)!.labelColumns,
                style: ShadTheme.of(context).textTheme.small,
              ),
              Text('$_columns', style: ShadTheme.of(context).textTheme.small),
            ],
          ),
          const SizedBox(height: 12),
          ShadSlider(
            initialValue: _columns.toDouble(),
            min: 1,
            max: 50,
            onChanged: (val) {
              setState(() {
                _columns = val.toInt();
              });
              _extractColors();
            },
          ),

          // Advanced Settings Panel
          if (_isAdvancedMode) ...[
            const SizedBox(height: 24),
            _buildAdvancedSettings(context),
          ],

          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.labelGridVisibility,
            style: ShadTheme.of(context).textTheme.small,
          ),
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
      ),
    );
  }

  Widget _buildAdvancedSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: ShadTheme.of(
              context,
            ).colorScheme.muted.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: ShadTheme.of(context).colorScheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Offsets & Margins',
                style: ShadTheme.of(
                  context,
                ).textTheme.small.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // Offset X/Y
              _buildSliderControl(
                label: 'Offset X',
                value: _offsetX,
                min: 0,
                max: 100,
                onChanged: (val) {
                  setState(() => _offsetX = val);
                  _extractColors();
                },
              ),
              _buildSliderControl(
                label: 'Offset Y',
                value: _offsetY,
                min: 0,
                max: 100,
                onChanged: (val) {
                  setState(() => _offsetY = val);
                  _extractColors();
                },
              ),

              const Divider(height: 24),

              // Padding/Spacing
              _buildSliderControl(
                label: 'Padding X',
                value: _paddingX,
                min: 0,
                max: 50,
                onChanged: (val) {
                  setState(() => _paddingX = val);
                  _extractColors();
                },
              ),
              _buildSliderControl(
                label: 'Padding Y',
                value: _paddingY,
                min: 0,
                max: 50,
                onChanged: (val) {
                  setState(() => _paddingY = val);
                  _extractColors();
                },
              ),
              _buildSliderControl(
                label: 'Spacing X',
                value: _cellSpacingX,
                min: 0,
                max: 50,
                onChanged: (val) {
                  setState(() => _cellSpacingX = val);
                  _extractColors();
                },
              ),
              _buildSliderControl(
                label: 'Spacing Y',
                value: _cellSpacingY,
                min: 0,
                max: 50,
                onChanged: (val) {
                  setState(() => _cellSpacingY = val);
                  _extractColors();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderControl({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        SizedBox(
          height: 24,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 4),
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
                AppLocalizations.of(context)!.labelExtractedColors,
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
                    border: Border.all(
                      color: ShadTheme.of(context).colorScheme.border,
                    ),
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
            color: isSelected
                ? ShadTheme.of(context).colorScheme.primary
                : ShadTheme.of(context).colorScheme.border,
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
  final double offsetX;
  final double offsetY;
  final double marginTop;
  final double marginRight;
  final double marginBottom;
  final double marginLeft;
  final double paddingX;
  final double paddingY;
  final double cellSpacingX;
  final double cellSpacingY;

  _GridPainter({
    required this.rows,
    required this.columns,
    required this.color,
    required this.imageSize,
    required this.offsetX,
    required this.offsetY,
    required this.marginTop,
    required this.marginRight,
    required this.marginBottom,
    required this.marginLeft,
    required this.paddingX,
    required this.paddingY,
    required this.cellSpacingX,
    required this.cellSpacingY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scaling to determine where the image actually is within the widget 'size'
    final fitted = applyBoxFit(BoxFit.contain, imageSize, size);
    final destRect = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & size,
    );

    // Calculate scale factor between rendered size and actual image size
    final double scaleX = destRect.width / imageSize.width;
    // scaleY unused as we assume uniform scaling for square pixels/grids generally
    // final double scaleY = destRect.height / imageSize.height;

    // Helper to scale values
    double s(double val) => val * scaleX; // Assuming uniform scaling for now

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint paddingPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Calculate effective area dimensions
    final double effectiveWidth = imageSize.width - marginLeft - marginRight;
    final double effectiveHeight = imageSize.height - marginTop - marginBottom;

    // Calculate total spacing
    final double totalSpacingX = (columns - 1) * cellSpacingX;
    final double totalSpacingY = (rows - 1) * cellSpacingY;

    // Available space for cells
    final double availableWidthForCells = effectiveWidth - totalSpacingX;
    final double availableHeightForCells = effectiveHeight - totalSpacingY;

    final double cellWidth = availableWidthForCells / columns;
    final double cellHeight = availableHeightForCells / rows;

    // Draw Margin Box (Outer boundary of value)
    // final marginRect = Rect.fromLTWH(
    //   destRect.left + s(marginLeft),
    //   destRect.top + s(marginTop),
    //   s(effectiveWidth),
    //   s(effectiveHeight),
    // );
    // Optional: Draw margin boundary
    // canvas.drawRect(marginRect, paint..color = color.withOpacity(0.5));

    // Draw center dots (visual feedback for sampling point)
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        // Calculate cell origin in image space
        final double cellImgLeft =
            marginLeft + offsetX + (x * (cellWidth + cellSpacingX));
        final double cellImgTop =
            marginTop + offsetY + (y * (cellHeight + cellSpacingY));

        // Convert to screen space
        final double screenLeft = destRect.left + s(cellImgLeft);
        final double screenTop = destRect.top + s(cellImgTop);
        final double screenWidth = s(cellWidth);
        final double screenHeight = s(cellHeight);

        final cellRect = Rect.fromLTWH(
          screenLeft,
          screenTop,
          screenWidth,
          screenHeight,
        );

        // Draw Cell Boundary
        canvas.drawRect(cellRect, paint);

        // Draw Padding Box (Sampling Area)
        if (paddingX > 0 || paddingY > 0) {
          final double paddingImgLeft = paddingX;
          final double paddingImgTop = paddingY;
          final double paddingImgWidth = cellWidth - (paddingX * 2);
          final double paddingImgHeight = cellHeight - (paddingY * 2);

          final paddingRect = Rect.fromLTWH(
            screenLeft + s(paddingImgLeft),
            screenTop + s(paddingImgTop),
            s(paddingImgWidth),
            s(paddingImgHeight),
          );
          canvas.drawRect(paddingRect, paddingPaint);

          // Center dot
          final cx = paddingRect.center.dx;
          final cy = paddingRect.center.dy;
          canvas.drawCircle(Offset(cx, cy), 3, dotPaint);
        } else {
          // Center dot
          final cx = cellRect.center.dx;
          final cy = cellRect.center.dy;
          canvas.drawCircle(Offset(cx, cy), 3, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.rows != rows ||
        oldDelegate.columns != columns ||
        oldDelegate.color != color ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.offsetX != offsetX ||
        oldDelegate.offsetY != offsetY ||
        oldDelegate.marginTop != marginTop ||
        oldDelegate.marginRight != marginRight ||
        oldDelegate.marginBottom != marginBottom ||
        oldDelegate.marginLeft != marginLeft ||
        oldDelegate.paddingX != paddingX ||
        oldDelegate.paddingY != paddingY ||
        oldDelegate.cellSpacingX != cellSpacingX ||
        oldDelegate.cellSpacingY != cellSpacingY;
  }
}
