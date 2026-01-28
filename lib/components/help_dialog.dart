import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:rhex/l10n/app_localizations.dart';

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
      title: Text(AppLocalizations.of(context)!.menuHelpShortcuts),
      constraints: BoxConstraints(
        maxWidth: screenSize.width * 0.8,
        maxHeight: screenSize.height * 0.8,
      ),
      actions: [
        ShadButton(
          child: Text(AppLocalizations.of(context)!.actionClose),
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
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NavButton(
                    label: AppLocalizations.of(context)!.helpTabShortcuts,
                    icon: Remix.keyboard_line,
                    isSelected: _selectedIndex == 0,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  const SizedBox(height: 4),
                  _NavButton(
                    label: AppLocalizations.of(context)!.helpTabUsage,
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
          ? ShadTheme.of(context).colorScheme.primary
          : ShadTheme.of(context).colorScheme.foreground,
      shadows: isSelected ? null : [],
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
          title: AppLocalizations.of(context)!.helpShortcutFileOps,
          items: [
            _ShortcutItem(
              keys: ['Ctrl', 'N'],
              description: AppLocalizations.of(
                context,
              )!.helpShortcutAddNewColor,
            ),
            _ShortcutItem(
              keys: ['Ctrl', 'S'],
              description: AppLocalizations.of(
                context,
              )!.helpShortcutSavePalette,
            ),
            _ShortcutItem(
              keys: ['Ctrl', 'O'],
              description: AppLocalizations.of(
                context,
              )!.helpShortcutOpenPalette,
            ),
            _ShortcutItem(
              keys: ['Ctrl', 'E'],
              description: AppLocalizations.of(context)!.helpShortcutExportPng,
            ),
            _ShortcutItem(
              keys: ['Ctrl', 'I'],
              description: AppLocalizations.of(
                context,
              )!.helpShortcutImportImage,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ShortcutCategory(
          title: AppLocalizations.of(context)!.helpShortcutEditView,
          items: [
            _ShortcutItem(
              keys: ['Ctrl', 'Z'],
              description: AppLocalizations.of(context)!.helpShortcutUndo,
            ),
            _ShortcutItem(
              keys: ['Ctrl', 'Y'],
              description: AppLocalizations.of(context)!.helpShortcutRedo,
            ),
            _ShortcutItem(
              keys: ['Ctrl', 'Shift', 'Z'],
              description: AppLocalizations.of(context)!.helpShortcutRedoAlt,
            ),
            _ShortcutItem(
              keys: ['Ctrl', 'Del'],
              description: AppLocalizations.of(context)!.helpShortcutClearAll,
            ),
            _ShortcutItem(
              keys: ['F1'],
              description: AppLocalizations.of(context)!.helpShortcutShowHelp,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _ShortcutCategory(
          title: AppLocalizations.of(context)!.helpShortcutColorEditing,
          items: [
            _ShortcutItem(
              keys: ['Right Click'],
              description: AppLocalizations.of(
                context,
              )!.helpShortcutGenerateShades,
            ),
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
        Text(
          AppLocalizations.of(context)!.helpSectionAddingColors,
          style: ShadTheme.of(context).textTheme.large,
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.helpSectionAddingColorsContent,
          style: ShadTheme.of(context).textTheme.muted.copyWith(height: 1.6),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.helpSectionManagingGrid,
          style: ShadTheme.of(context).textTheme.large,
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.helpSectionManagingGridContent,
          style: ShadTheme.of(context).textTheme.muted.copyWith(height: 1.6),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.helpSectionImportExport,
          style: ShadTheme.of(context).textTheme.large,
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.helpSectionImportExportContent,
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