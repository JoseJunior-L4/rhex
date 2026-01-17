import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HelpDialog extends StatefulWidget {
  const HelpDialog({super.key});

  @override
  State<HelpDialog> createState() => _HelpDialogState();
}

class _HelpDialogState extends State<HelpDialog> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ShadDialog(
      title: const Text('Help & Shortcuts'),
      constraints: BoxConstraints(
        maxWidth: screenSize.width * 0.8,
        maxHeight: screenSize.height * 0.8,
      ),
      actions: [
        ShadButton(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Container(
        width: screenSize.width * 0.8,
        height: screenSize.height * 0.8,
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sidebar
            SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NavButton(
                    label: 'Shortcuts',
                    icon: Remix.keyboard_line,
                    isSelected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  const SizedBox(height: 4),
                  _NavButton(
                    label: 'General Usage',
                    icon: Remix.book_open_line,
                    isSelected: _selectedIndex == 1,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 32),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: _selectedIndex == 0
                    ? const _ShortcutsView()
                    : const _UsageView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ShadButton(
      // Use ghost variant for unselected, outline/secondary for selected to distinguish
      backgroundColor: isSelected
          ? ShadTheme.of(context).colorScheme.secondary
          : Colors.transparent,
      foregroundColor: isSelected
          ? null
          : ShadTheme.of(context).colorScheme.foreground,
      shadows: isSelected ? null : [],
      hoverBackgroundColor: isSelected
          ? null
          : ShadTheme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
      onPressed: onTap,
      child: Row(
        children: [Icon(icon, size: 16), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}

class _ShortcutsView extends StatelessWidget {
  const _ShortcutsView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ShortcutCategory(
          title: 'File Operations',
          items: [
            _ShortcutItem(keys: ['Ctrl', 'N'], description: 'Add New Color'),
            _ShortcutItem(
              keys: ['Ctrl', 'S'],
              description: 'Save Palette (JSON)',
            ),
            _ShortcutItem(
              keys: ['Ctrl', 'O'],
              description: 'Open Palette (JSON)',
            ),
            _ShortcutItem(keys: ['Ctrl', 'E'], description: 'Export as PNG'),
            _ShortcutItem(keys: ['Ctrl', 'I'], description: 'Import Image'),
          ],
        ),
        const SizedBox(height: 24),
        _ShortcutCategory(
          title: 'Edit & View',
          items: [
            _ShortcutItem(keys: ['Ctrl', 'Z'], description: 'Undo'),
            _ShortcutItem(keys: ['Ctrl', 'Y'], description: 'Redo'),
            _ShortcutItem(
              keys: ['Ctrl', 'Shift', 'Z'],
              description: 'Redo (Alternative)',
            ),
            _ShortcutItem(
              keys: ['Ctrl', 'Del'],
              description: 'Clear All Colors',
            ),
            _ShortcutItem(keys: ['F1'], description: 'Show Help'),
          ],
        ),
      ],
    );
  }
}

class _UsageView extends StatelessWidget {
  const _UsageView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Adding Colors', style: ShadTheme.of(context).textTheme.large),
        const SizedBox(height: 8),
        Text(
          '• Type a hex code in the sidebar (e.g. #FF5500) and press Enter.\n'
          '• Click the color preview box to open a visual color picker.\n'
          '• Use the "Add Color" button to add the current color to your grid.\n'
          '• Click the Dice icon to generate a random color.',
          style: ShadTheme.of(context).textTheme.muted.copyWith(height: 1.6),
        ),
        const SizedBox(height: 24),
        Text('Managing the Grid', style: ShadTheme.of(context).textTheme.large),
        const SizedBox(height: 8),
        Text(
          '• Click any color tile in the grid to Edit or Delete it.\n'
          '• Use the Grid Size slider to change how many columns are displayed.\n'
          '• Toggle "Show Hex Labels" to hide/show text overlays.',
          style: ShadTheme.of(context).textTheme.muted.copyWith(height: 1.6),
        ),
        const SizedBox(height: 24),
        Text('Import & Export', style: ShadTheme.of(context).textTheme.large),
        const SizedBox(height: 8),
        Text(
          '• Import Image: Extract a palette from any image file.\n'
          '• Save/Open: Save your work as a .json file to work on later.\n'
          '• Export PNG: Generate a high-quality image of your palette.',
          style: ShadTheme.of(context).textTheme.muted.copyWith(height: 1.6),
        ),
      ],
    );
  }
}

class _ShortcutCategory extends StatelessWidget {
  final String title;
  final List<_ShortcutItem> items;

  const _ShortcutCategory({required this.title, required this.items});

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
        ...items.map(
          (item) =>
              Padding(padding: const EdgeInsets.only(bottom: 8.0), child: item),
        ),
      ],
    );
  }
}

class _ShortcutItem extends StatelessWidget {
  final List<String> keys;
  final String description;

  const _ShortcutItem({required this.keys, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: keys.map((key) {
              final isLast = key == keys.last;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ShadTheme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: ShadTheme.of(context).colorScheme.border,
                      ),
                    ),
                    child: Text(
                      key,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '+',
                        style: ShadTheme.of(context).textTheme.muted,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 16),
        Text(description, style: ShadTheme.of(context).textTheme.muted),
      ],
    );
  }
}
