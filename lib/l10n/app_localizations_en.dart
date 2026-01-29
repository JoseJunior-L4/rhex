// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Rhex';

  @override
  String get menuFile => 'File';

  @override
  String get menuOpen => 'Open';

  @override
  String get menuSave => 'Save';

  @override
  String get menuImportImage => 'Import Image';

  @override
  String get menuExportPng => 'Export PNG';

  @override
  String get menuEdit => 'Edit';

  @override
  String get menuUndo => 'Undo';

  @override
  String get menuRedo => 'Redo';

  @override
  String get menuClearAll => 'Clear All';

  @override
  String get menuHelp => 'Help';

  @override
  String get menuHelpShortcuts => 'Help & Shortcuts';

  @override
  String get sidebarGridSize => 'Grid Size';

  @override
  String get sidebarHexLabels => 'Hex Labels';

  @override
  String get sidebarAddColor => 'Add Color';

  @override
  String get sidebarHistory => 'History';

  @override
  String get dialogClearTitle => 'Clear Palette?';

  @override
  String get dialogClearDescription =>
      'Are you sure you want to remove all colors? This action can be undone.';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClear => 'Clear All';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionUpdate => 'Update';

  @override
  String get toastPaletteCleared => 'Palette cleared';

  @override
  String get toastPaletteLoaded => 'Palette loaded successfully!';

  @override
  String toastErrorLoading(Object error) {
    return 'Error loading palette: $error';
  }

  @override
  String get toastPaletteSaved => 'Palette saved successfully!';

  @override
  String toastErrorSaving(Object error) {
    return 'Error saving palette: $error';
  }

  @override
  String toastImportedColors(Object count) {
    return 'Imported $count colors successfully!';
  }

  @override
  String get toastNoColorsExport => 'No colors to export!';

  @override
  String get toastPaletteExported => 'Palette exported successfully!';

  @override
  String toastErrorExporting(Object error) {
    return 'Error exporting palette: $error';
  }

  @override
  String get dialogEditColorTitle => 'Edit Color';

  @override
  String get dialogEditColorDescription =>
      'Choose a new color for this palette slot';

  @override
  String get dialogShadeGeneratorTitle => 'Shade Generator';

  @override
  String get labelBaseColor => 'Base Color';

  @override
  String get labelTints => 'Tints';

  @override
  String get labelShades => 'Shades';

  @override
  String get importWizardTitle => 'Import Image';

  @override
  String get labelSelectImage => 'Select Image';

  @override
  String get labelMaxColors => 'Max Colors';

  @override
  String get actionExtractColors => 'Extract Colors';

  @override
  String get actionImport => 'Import';

  @override
  String get helpShortcutFileOps => 'File Operations';

  @override
  String get helpShortcutEditView => 'Edit & View';

  @override
  String get helpShortcutColorEditing => 'Color Editing';

  @override
  String get helpShortcutAddNewColor => 'Add New Color';

  @override
  String get helpShortcutSavePalette => 'Save Palette (JSON)';

  @override
  String get helpShortcutOpenPalette => 'Open Palette (JSON)';

  @override
  String get helpShortcutExportPng => 'Export as PNG';

  @override
  String get helpShortcutImportImage => 'Import Image';

  @override
  String get helpShortcutUndo => 'Undo';

  @override
  String get helpShortcutRedo => 'Redo';

  @override
  String get helpShortcutRedoAlt => 'Redo (Alternative)';

  @override
  String get helpShortcutClearAll => 'Clear All Colors';

  @override
  String get helpShortcutShowHelp => 'Show Help';

  @override
  String get helpShortcutGenerateShades => 'Generate Tints & Shades';

  @override
  String get helpTabShortcuts => 'Keyboard Shortcuts';

  @override
  String get helpTabUsage => 'General Usage';

  @override
  String get helpUsageTitle => 'Welcome to Rhex';

  @override
  String get helpUsageDescription =>
      'A minimal and keyboard-first color palette manager for developers and designers.';

  @override
  String get helpUsageItem1 =>
      'Click the color circle to open the color picker';

  @override
  String get helpUsageItem2 => 'Type hex codes directly or select from history';

  @override
  String get helpUsageItem3 => 'Adjust grid size to organize your palette';

  @override
  String get helpUsageItem4 =>
      'Right-click any color to generate tints and shades';

  @override
  String get helpUsageItem5 => 'Drag and drop to reorder colors';

  @override
  String get labelColorInput => 'Color Input';

  @override
  String get labelPickColor => 'Pick a color';

  @override
  String get actionSelect => 'Select';

  @override
  String get actionProcess => 'Process';

  @override
  String get actionStopAll => 'Stop All';

  @override
  String get actionSkipContinue => 'Skip & Continue';

  @override
  String get actionBatchAdd => 'Batch Add';

  @override
  String get dialogBatchAddTitle => 'Batch Add Colors';

  @override
  String get dialogBatchAddDescription =>
      'Paste hex codes (one per line). Format: #RRGGBB or RRGGBB';

  @override
  String get dialogInvalidColorTitle => 'Invalid Color Found';

  @override
  String dialogInvalidColorDescription(Object content, Object line) {
    return 'Line $line: \"$content\" is not a valid hex code.';
  }

  @override
  String toastBatchProcessingStopped(Object count) {
    return 'Added $count valid colors. Processing stopped.';
  }

  @override
  String toastBatchSuccess(Object count) {
    return 'Successfully added $count colors!';
  }

  @override
  String get toastBatchNoColors => 'No valid colors found to add.';

  @override
  String get labelNoHistory => 'No colors in history yet';

  @override
  String get actionClose => 'Close';

  @override
  String get helpSectionAddingColors => 'Adding Colors';

  @override
  String get helpSectionAddingColorsContent =>
      '• Type a hex code in the sidebar (e.g. #FF5500) and press Enter.\n• Click the color preview box to open a visual color picker.\n• Use the \"Add Color\" button to add the current color to your grid.\n• Click the Dice icon to generate a random color.';

  @override
  String get helpSectionManagingGrid => 'Managing the Grid';

  @override
  String get helpSectionManagingGridContent =>
      '• Click any color tile in the grid to Edit or Delete it.\n• Use the Grid Size slider to change how many columns are displayed.\n• Toggle \"Show Hex Labels\" to hide/show text overlays.';

  @override
  String get helpSectionImportExport => 'Import & Export';

  @override
  String get helpSectionImportExportContent =>
      '• Import Image: Extract a palette from any image file.\n• Save/Open: Save your work as a .json file to work on later.\n• Export PNG: Generate a high-quality image of your palette.';

  @override
  String dialogShadeGeneratorDescription(Object hex) {
    return 'Generate tints and shades for $hex';
  }

  @override
  String get labelTintsLighter => 'Tints (Lighter)';

  @override
  String get labelShadesDarker => 'Shades (Darker)';

  @override
  String get toastColorAdded => 'Color Added';

  @override
  String toastColorAddedMessage(Object hex) {
    return '$hex added to palette';
  }

  @override
  String toastErrorLoadingImage(Object error) {
    return 'Failed to load image: $error';
  }

  @override
  String get importWizardDescription => 'Adjust grid to capture colors';

  @override
  String get actionImportColors => 'Import Colors';

  @override
  String get labelGridSettings => 'Grid Settings';

  @override
  String get labelRows => 'Rows';

  @override
  String get labelColumns => 'Columns';

  @override
  String get labelGridVisibility => 'Grid Visibility';

  @override
  String get labelExtractedColors => 'Extracted Colors';

  @override
  String get dialogExportTitle => 'Export Palette';

  @override
  String get dialogExportDescription => 'Choose an export format';
}
