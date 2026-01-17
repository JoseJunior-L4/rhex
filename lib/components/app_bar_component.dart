import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppBarComponent extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onOpen;
  final VoidCallback onSave;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onClear;

  const AppBarComponent({
    super.key,
    required this.onUndo,
    required this.onRedo,
    required this.onOpen,
    required this.onSave,
    required this.onExport,
    required this.onImport,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // Logo and Title
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                    Color(0xFFEC4899),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Remix.palette_line,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Color Palette Creator',
              style: ShadTheme.of(context).textTheme.h4,
            ),
            const Spacer(),
            // Action buttons
            _ActionButton(
              icon: Remix.arrow_go_back_line,
              label: 'Undo',
              onPressed: onUndo,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Remix.arrow_go_forward_line,
              label: 'Redo',
              onPressed: onRedo,
            ),
            _ActionButton(
              icon: Remix.delete_bin_line,
              label: 'Clear',
              onPressed: onClear,
            ),
            const SizedBox(width: 16),
            _ActionButton(
              icon: Remix.folder_open_line,
              label: 'Open',
              onPressed: onOpen,
            ),

            const SizedBox(width: 8),
            _ActionButton(
              icon: Remix.image_add_line,
              label: 'Import',
              onPressed: onImport,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Remix.save_line,
              label: 'Save',
              onPressed: onSave,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Remix.download_line,
              label: 'Export',
              onPressed: onExport,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 16,
        color: ShadTheme.of(context).textTheme.muted.color,
      ),
      label: Text(label, style: ShadTheme.of(context).textTheme.muted),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
