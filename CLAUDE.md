# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Rhex is a minimal hex color palette manager built with Flutter. It supports desktop (Windows, Linux, macOS), mobile (Android, iOS), and web platforms.

## Common Commands

```bash
flutter pub get                # Install dependencies
flutter analyze                # Run linter
flutter test                   # Run tests
flutter run                    # Run the app
flutter gen-l10n               # Regenerate localization files after editing .arb files
flutter build <platform>       # Build for windows/linux/macos/android/ios/web
```

## Architecture

### Entry Points
- `lib/main.dart` - App initialization, theme/locale management, ShadcnUI setup with Poppins font

### Core Structure
```
lib/
├── screens/palette_creator_screen.dart  # Main screen with keyboard shortcuts
├── models/color_palette_model.dart      # Color list + undo/redo (50 history limit)
├── services/storage_service.dart        # SharedPreferences persistence (rhex_* keys)
├── components/                          # UI components
│   ├── app_bar_component.dart           # Toolbar menus
│   ├── color_grid_component.dart        # Reorderable color grid
│   ├── sidebar_component.dart           # Color input panel
│   ├── image_import_wizard.dart         # Extract colors from images
│   └── shade_generator_dialog.dart      # Generate shades/tints
└── l10n/                                # Localization (English, Portuguese)
```

### Data Flow
User interaction -> PaletteCreatorScreen -> ColorPaletteModel -> StorageService -> SharedPreferences

### Key Dependencies
- **shadcn_ui** - UI component library
- **flutter_colorpicker** - Color picker dialogs
- **reorderable_grid_view** - Drag-to-reorder grid
- **image** - Image processing for color extraction

## Localization

Translation files are in `lib/l10n/app_en.arb` (template) and `lib/l10n/app_pt.arb`. After editing, run `flutter gen-l10n` to regenerate Dart classes.

## Keyboard Shortcuts

Defined in `palette_creator_screen.dart` via Intent/Actions:
- Ctrl+Z (undo), Ctrl+Y/Ctrl+Shift+Z (redo)
- Ctrl+S (save), Ctrl+O (open)
- Ctrl+I (import image), Ctrl+E (export PNG)
- Ctrl+Delete/Backspace (clear), F1/Ctrl+/ (help)

## Storage Keys

All SharedPreferences keys use `rhex_` prefix: colors, grid_size, show_hex, current_color, history, history_index, sidebar_collapsed, theme_mode, locale.
