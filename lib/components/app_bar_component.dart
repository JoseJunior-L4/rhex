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
  final VoidCallback onHelp;
  final VoidCallback onToggleSidebar;

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final divider = ShadSeparator.horizontal(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.colorScheme.muted,
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
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
                Text('Rhex', style: ShadTheme.of(context).textTheme.h4),
                const Spacer(),
              ],
            ),
          ),
          // Menu bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 1),
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
                            onPressed: onOpen,
                            child: const Text('Open'),
                          ),
                          ShadContextMenuItem(
                            leading: const Icon(Remix.save_line, size: 16),
                            onPressed: onSave,
                            child: const Text('Save'),
                          ),
                          divider,
                          ShadContextMenuItem(
                            leading: const Icon(Remix.image_add_line, size: 16),
                            onPressed: onImport,
                            child: const Text('Import Image'),
                          ),
                          ShadContextMenuItem(
                            leading: const Icon(Remix.download_line, size: 16),
                            onPressed: onExport,
                            child: const Text('Export PNG'),
                          ),
                        ],
                        child: const Text('File'),
                      ),
                      ShadMenubarItem(
                        items: [
                          ShadContextMenuItem(
                            leading: const Icon(
                              Remix.arrow_go_back_line,
                              size: 16,
                            ),
                            onPressed: onUndo,
                            child: const Text('Undo'),
                          ),
                          ShadContextMenuItem(
                            leading: const Icon(
                              Remix.arrow_go_forward_line,
                              size: 16,
                            ),
                            onPressed: onRedo,
                            child: const Text('Redo'),
                          ),
                          divider,
                          ShadContextMenuItem(
                            leading: const Icon(
                              Remix.delete_bin_line,
                              size: 16,
                            ),
                            onPressed: onClear,
                            child: const Text('Clear All'),
                          ),
                        ],
                        child: const Text('Edit'),
                      ),
                      ShadMenubarItem(
                        items: [
                          ShadContextMenuItem(
                            leading: const Icon(Remix.question_line, size: 16),
                            onPressed: onHelp,
                            child: const Text('Help & Shortcuts'),
                          ),
                        ],
                        child: const Text('Help'),
                      ),
                    ],
                  ),
                ),

                // Undo/Redo/Clear buttons
                ShadButton.ghost(
                  onPressed: onUndo,
                  child: const Icon(Remix.arrow_go_back_line, size: 18),
                ),

                ShadButton.ghost(
                  onPressed: onClear,
                  child: const Icon(Remix.delete_bin_line, size: 18),
                ),
                ShadButton.ghost(
                  onPressed: onRedo,
                  child: const Icon(Remix.arrow_go_forward_line, size: 18),
                ),
                ShadButton.ghost(
                  onPressed: onToggleSidebar,
                  child: Icon(Remix.menu_line, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
