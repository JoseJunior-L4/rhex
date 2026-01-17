import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:rhex/l10n/app_localizations.dart';

class AppBarComponent extends StatefulWidget {
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onOpen;
  final VoidCallback onSave;
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onClear;
  final VoidCallback onHelp;
  final VoidCallback onToggleSidebar;
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  const AppBarComponent({
    super.key,
    required this.onUndo,
    required this.onRedo,
    required this.onOpen,
    required this.onSave,
    required this.onExport,
    required this.onImport,
    required this.onClear,
    required this.onHelp,
    required this.onToggleSidebar,
    required this.onToggleTheme,
    required this.themeMode,
    required this.locale,
    required this.onLocaleChanged,
  });

  @override
  State<AppBarComponent> createState() => _AppBarComponentState();
}

class _AppBarComponentState extends State<AppBarComponent> {
  final ShadPopoverController _popoverController = ShadPopoverController();

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final divider = ShadSeparator.horizontal(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.colorScheme.muted,
    );
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row with logo and title
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Logo
                Image.asset('assets/icons/app_icon.png', width: 32, height: 32),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context)!.appTitle,
                  style: ShadTheme.of(context).textTheme.h4,
                ),
                const Spacer(),
              ],
            ),
          ),
          // Menu bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: theme.colorScheme.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ShadMenubar(
                    border: ShadBorder.none,
                    items: [
                      ShadMenubarItem(
                        items: [
                          ShadContextMenuItem(
                            leading: const Icon(
                              Remix.folder_open_line,
                              size: 16,
                            ),
                            onPressed: widget.onOpen,
                            child: Text(AppLocalizations.of(context)!.menuOpen),
                          ),
                          ShadContextMenuItem(
                            leading: const Icon(Remix.save_line, size: 16),
                            onPressed: widget.onSave,
                            child: Text(AppLocalizations.of(context)!.menuSave),
                          ),
                          divider,
                          ShadContextMenuItem(
                            leading: const Icon(Remix.image_add_line, size: 16),
                            onPressed: widget.onImport,
                            child: Text(
                              AppLocalizations.of(context)!.menuImportImage,
                            ),
                          ),
                          ShadContextMenuItem(
                            leading: const Icon(Remix.download_line, size: 16),
                            onPressed: widget.onExport,
                            child: Text(
                              AppLocalizations.of(context)!.menuExportPng,
                            ),
                          ),
                        ],
                        child: Text(AppLocalizations.of(context)!.menuFile),
                      ),
                      ShadMenubarItem(
                        items: [
                          ShadContextMenuItem(
                            leading: const Icon(
                              Remix.arrow_go_back_line,
                              size: 16,
                            ),
                            onPressed: widget.onUndo,
                            child: Text(AppLocalizations.of(context)!.menuUndo),
                          ),
                          ShadContextMenuItem(
                            leading: const Icon(
                              Remix.arrow_go_forward_line,
                              size: 16,
                            ),
                            onPressed: widget.onRedo,
                            child: Text(AppLocalizations.of(context)!.menuRedo),
                          ),
                          divider,
                          ShadContextMenuItem(
                            leading: const Icon(
                              Remix.delete_bin_line,
                              size: 16,
                            ),
                            onPressed: widget.onClear,
                            child: Text(
                              AppLocalizations.of(context)!.menuClearAll,
                            ),
                          ),
                        ],
                        child: Text(AppLocalizations.of(context)!.menuEdit),
                      ),
                      ShadMenubarItem(
                        items: [
                          ShadContextMenuItem(
                            leading: const Icon(Remix.question_line, size: 16),
                            onPressed: widget.onHelp,
                            child: Text(
                              AppLocalizations.of(context)!.menuHelpShortcuts,
                            ),
                          ),
                        ],
                        child: Text(AppLocalizations.of(context)!.menuHelp),
                      ),
                    ],
                  ),
                ),

                // Undo/Redo/Clear buttons
                ShadButton.ghost(
                  onPressed: widget.onUndo,
                  child: const Icon(Remix.arrow_go_back_line, size: 18),
                ),

                ShadButton.ghost(
                  onPressed: widget.onClear,
                  child: const Icon(Remix.delete_bin_line, size: 18),
                ),
                ShadButton.ghost(
                  onPressed: widget.onRedo,
                  child: const Icon(Remix.arrow_go_forward_line, size: 18),
                ),
                ShadButton.ghost(
                  onPressed: widget.onToggleSidebar,
                  child: Icon(Remix.menu_line, size: 18),
                ),
                ShadPopover(
                  controller: _popoverController,
                  child: ShadButton.ghost(
                    child: const Icon(Remix.earth_line, size: 18),
                    onPressed: () {
                      _popoverController.toggle();
                    },
                  ),
                  popover: (context) => SizedBox(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadButton.ghost(
                          onPressed: () {
                            widget.onLocaleChanged(const Locale('en'));
                            _popoverController.toggle();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'English',
                                style: widget.locale.languageCode == 'en'
                                    ? const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )
                                    : null,
                              ),
                              if (widget.locale.languageCode == 'en')
                                const Icon(Remix.check_line, size: 16),
                            ],
                          ),
                        ),
                        ShadButton.ghost(
                          onPressed: () {
                            widget.onLocaleChanged(const Locale('pt'));
                            _popoverController.toggle();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Português',
                                style: widget.locale.languageCode == 'pt'
                                    ? const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      )
                                    : null,
                              ),
                              if (widget.locale.languageCode == 'pt')
                                const Icon(Remix.check_line, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ShadButton.ghost(
                  onPressed: widget.onToggleTheme,
                  child: Icon(
                    widget.themeMode == ThemeMode.dark
                        ? Remix.sun_line
                        : Remix.moon_line,
                    size: 18,
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
