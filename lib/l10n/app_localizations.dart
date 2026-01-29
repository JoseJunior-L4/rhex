import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Rhex'**
  String get appTitle;

  /// No description provided for @menuFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get menuFile;

  /// No description provided for @menuOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get menuOpen;

  /// No description provided for @menuSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get menuSave;

  /// No description provided for @menuImportImage.
  ///
  /// In en, this message translates to:
  /// **'Import Image'**
  String get menuImportImage;

  /// No description provided for @menuExportPng.
  ///
  /// In en, this message translates to:
  /// **'Export PNG'**
  String get menuExportPng;

  /// No description provided for @menuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get menuEdit;

  /// No description provided for @menuUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get menuUndo;

  /// No description provided for @menuRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get menuRedo;

  /// No description provided for @menuClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get menuClearAll;

  /// No description provided for @menuHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get menuHelp;

  /// No description provided for @menuHelpShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Help & Shortcuts'**
  String get menuHelpShortcuts;

  /// No description provided for @sidebarGridSize.
  ///
  /// In en, this message translates to:
  /// **'Grid Size'**
  String get sidebarGridSize;

  /// No description provided for @sidebarHexLabels.
  ///
  /// In en, this message translates to:
  /// **'Hex Labels'**
  String get sidebarHexLabels;

  /// No description provided for @sidebarAddColor.
  ///
  /// In en, this message translates to:
  /// **'Add Color'**
  String get sidebarAddColor;

  /// No description provided for @sidebarHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get sidebarHistory;

  /// No description provided for @dialogClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Palette?'**
  String get dialogClearTitle;

  /// No description provided for @dialogClearDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all colors? This action can be undone.'**
  String get dialogClearDescription;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get actionClear;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get actionUpdate;

  /// No description provided for @toastPaletteCleared.
  ///
  /// In en, this message translates to:
  /// **'Palette cleared'**
  String get toastPaletteCleared;

  /// No description provided for @toastPaletteLoaded.
  ///
  /// In en, this message translates to:
  /// **'Palette loaded successfully!'**
  String get toastPaletteLoaded;

  /// No description provided for @toastErrorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading palette: {error}'**
  String toastErrorLoading(Object error);

  /// No description provided for @toastPaletteSaved.
  ///
  /// In en, this message translates to:
  /// **'Palette saved successfully!'**
  String get toastPaletteSaved;

  /// No description provided for @toastErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving palette: {error}'**
  String toastErrorSaving(Object error);

  /// No description provided for @toastImportedColors.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} colors successfully!'**
  String toastImportedColors(Object count);

  /// No description provided for @toastNoColorsExport.
  ///
  /// In en, this message translates to:
  /// **'No colors to export!'**
  String get toastNoColorsExport;

  /// No description provided for @toastPaletteExported.
  ///
  /// In en, this message translates to:
  /// **'Palette exported successfully!'**
  String get toastPaletteExported;

  /// No description provided for @toastErrorExporting.
  ///
  /// In en, this message translates to:
  /// **'Error exporting palette: {error}'**
  String toastErrorExporting(Object error);

  /// No description provided for @dialogEditColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Color'**
  String get dialogEditColorTitle;

  /// No description provided for @dialogEditColorDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a new color for this palette slot'**
  String get dialogEditColorDescription;

  /// No description provided for @dialogShadeGeneratorTitle.
  ///
  /// In en, this message translates to:
  /// **'Shade Generator'**
  String get dialogShadeGeneratorTitle;

  /// No description provided for @labelBaseColor.
  ///
  /// In en, this message translates to:
  /// **'Base Color'**
  String get labelBaseColor;

  /// No description provided for @labelTints.
  ///
  /// In en, this message translates to:
  /// **'Tints'**
  String get labelTints;

  /// No description provided for @labelShades.
  ///
  /// In en, this message translates to:
  /// **'Shades'**
  String get labelShades;

  /// No description provided for @importWizardTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Image'**
  String get importWizardTitle;

  /// No description provided for @labelSelectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get labelSelectImage;

  /// No description provided for @labelMaxColors.
  ///
  /// In en, this message translates to:
  /// **'Max Colors'**
  String get labelMaxColors;

  /// No description provided for @actionExtractColors.
  ///
  /// In en, this message translates to:
  /// **'Extract Colors'**
  String get actionExtractColors;

  /// No description provided for @actionImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get actionImport;

  /// No description provided for @helpShortcutFileOps.
  ///
  /// In en, this message translates to:
  /// **'File Operations'**
  String get helpShortcutFileOps;

  /// No description provided for @helpShortcutEditView.
  ///
  /// In en, this message translates to:
  /// **'Edit & View'**
  String get helpShortcutEditView;

  /// No description provided for @helpShortcutColorEditing.
  ///
  /// In en, this message translates to:
  /// **'Color Editing'**
  String get helpShortcutColorEditing;

  /// No description provided for @helpShortcutAddNewColor.
  ///
  /// In en, this message translates to:
  /// **'Add New Color'**
  String get helpShortcutAddNewColor;

  /// No description provided for @helpShortcutSavePalette.
  ///
  /// In en, this message translates to:
  /// **'Save Palette (JSON)'**
  String get helpShortcutSavePalette;

  /// No description provided for @helpShortcutOpenPalette.
  ///
  /// In en, this message translates to:
  /// **'Open Palette (JSON)'**
  String get helpShortcutOpenPalette;

  /// No description provided for @helpShortcutExportPng.
  ///
  /// In en, this message translates to:
  /// **'Export as PNG'**
  String get helpShortcutExportPng;

  /// No description provided for @helpShortcutImportImage.
  ///
  /// In en, this message translates to:
  /// **'Import Image'**
  String get helpShortcutImportImage;

  /// No description provided for @helpShortcutUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get helpShortcutUndo;

  /// No description provided for @helpShortcutRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get helpShortcutRedo;

  /// No description provided for @helpShortcutRedoAlt.
  ///
  /// In en, this message translates to:
  /// **'Redo (Alternative)'**
  String get helpShortcutRedoAlt;

  /// No description provided for @helpShortcutClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All Colors'**
  String get helpShortcutClearAll;

  /// No description provided for @helpShortcutShowHelp.
  ///
  /// In en, this message translates to:
  /// **'Show Help'**
  String get helpShortcutShowHelp;

  /// No description provided for @helpShortcutGenerateShades.
  ///
  /// In en, this message translates to:
  /// **'Generate Tints & Shades'**
  String get helpShortcutGenerateShades;

  /// No description provided for @helpTabShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get helpTabShortcuts;

  /// No description provided for @helpTabUsage.
  ///
  /// In en, this message translates to:
  /// **'General Usage'**
  String get helpTabUsage;

  /// No description provided for @helpUsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Rhex'**
  String get helpUsageTitle;

  /// No description provided for @helpUsageDescription.
  ///
  /// In en, this message translates to:
  /// **'A minimal and keyboard-first color palette manager for developers and designers.'**
  String get helpUsageDescription;

  /// No description provided for @helpUsageItem1.
  ///
  /// In en, this message translates to:
  /// **'Click the color circle to open the color picker'**
  String get helpUsageItem1;

  /// No description provided for @helpUsageItem2.
  ///
  /// In en, this message translates to:
  /// **'Type hex codes directly or select from history'**
  String get helpUsageItem2;

  /// No description provided for @helpUsageItem3.
  ///
  /// In en, this message translates to:
  /// **'Adjust grid size to organize your palette'**
  String get helpUsageItem3;

  /// No description provided for @helpUsageItem4.
  ///
  /// In en, this message translates to:
  /// **'Right-click any color to generate tints and shades'**
  String get helpUsageItem4;

  /// No description provided for @helpUsageItem5.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop to reorder colors'**
  String get helpUsageItem5;

  /// No description provided for @labelColorInput.
  ///
  /// In en, this message translates to:
  /// **'Color Input'**
  String get labelColorInput;

  /// No description provided for @labelPickColor.
  ///
  /// In en, this message translates to:
  /// **'Pick a color'**
  String get labelPickColor;

  /// No description provided for @actionSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get actionSelect;

  /// No description provided for @actionProcess.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get actionProcess;

  /// No description provided for @actionStopAll.
  ///
  /// In en, this message translates to:
  /// **'Stop All'**
  String get actionStopAll;

  /// No description provided for @actionSkipContinue.
  ///
  /// In en, this message translates to:
  /// **'Skip & Continue'**
  String get actionSkipContinue;

  /// No description provided for @actionBatchAdd.
  ///
  /// In en, this message translates to:
  /// **'Batch Add'**
  String get actionBatchAdd;

  /// No description provided for @dialogBatchAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch Add Colors'**
  String get dialogBatchAddTitle;

  /// No description provided for @dialogBatchAddDescription.
  ///
  /// In en, this message translates to:
  /// **'Paste hex codes (one per line). Format: #RRGGBB or RRGGBB'**
  String get dialogBatchAddDescription;

  /// No description provided for @dialogInvalidColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid Color Found'**
  String get dialogInvalidColorTitle;

  /// No description provided for @dialogInvalidColorDescription.
  ///
  /// In en, this message translates to:
  /// **'Line {line}: \"{content}\" is not a valid hex code.'**
  String dialogInvalidColorDescription(Object content, Object line);

  /// No description provided for @toastBatchProcessingStopped.
  ///
  /// In en, this message translates to:
  /// **'Added {count} valid colors. Processing stopped.'**
  String toastBatchProcessingStopped(Object count);

  /// No description provided for @toastBatchSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully added {count} colors!'**
  String toastBatchSuccess(Object count);

  /// No description provided for @toastBatchNoColors.
  ///
  /// In en, this message translates to:
  /// **'No valid colors found to add.'**
  String get toastBatchNoColors;

  /// No description provided for @labelNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No colors in history yet'**
  String get labelNoHistory;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @helpSectionAddingColors.
  ///
  /// In en, this message translates to:
  /// **'Adding Colors'**
  String get helpSectionAddingColors;

  /// No description provided for @helpSectionAddingColorsContent.
  ///
  /// In en, this message translates to:
  /// **'• Type a hex code in the sidebar (e.g. #FF5500) and press Enter.\n• Click the color preview box to open a visual color picker.\n• Use the \"Add Color\" button to add the current color to your grid.\n• Click the Dice icon to generate a random color.'**
  String get helpSectionAddingColorsContent;

  /// No description provided for @helpSectionManagingGrid.
  ///
  /// In en, this message translates to:
  /// **'Managing the Grid'**
  String get helpSectionManagingGrid;

  /// No description provided for @helpSectionManagingGridContent.
  ///
  /// In en, this message translates to:
  /// **'• Click any color tile in the grid to Edit or Delete it.\n• Use the Grid Size slider to change how many columns are displayed.\n• Toggle \"Show Hex Labels\" to hide/show text overlays.'**
  String get helpSectionManagingGridContent;

  /// No description provided for @helpSectionImportExport.
  ///
  /// In en, this message translates to:
  /// **'Import & Export'**
  String get helpSectionImportExport;

  /// No description provided for @helpSectionImportExportContent.
  ///
  /// In en, this message translates to:
  /// **'• Import Image: Extract a palette from any image file.\n• Save/Open: Save your work as a .json file to work on later.\n• Export PNG: Generate a high-quality image of your palette.'**
  String get helpSectionImportExportContent;

  /// No description provided for @dialogShadeGeneratorDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate tints and shades for {hex}'**
  String dialogShadeGeneratorDescription(Object hex);

  /// No description provided for @labelTintsLighter.
  ///
  /// In en, this message translates to:
  /// **'Tints (Lighter)'**
  String get labelTintsLighter;

  /// No description provided for @labelShadesDarker.
  ///
  /// In en, this message translates to:
  /// **'Shades (Darker)'**
  String get labelShadesDarker;

  /// No description provided for @toastColorAdded.
  ///
  /// In en, this message translates to:
  /// **'Color Added'**
  String get toastColorAdded;

  /// No description provided for @toastColorAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'{hex} added to palette'**
  String toastColorAddedMessage(Object hex);

  /// No description provided for @toastErrorLoadingImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image: {error}'**
  String toastErrorLoadingImage(Object error);

  /// No description provided for @importWizardDescription.
  ///
  /// In en, this message translates to:
  /// **'Adjust grid to capture colors'**
  String get importWizardDescription;

  /// No description provided for @actionImportColors.
  ///
  /// In en, this message translates to:
  /// **'Import Colors'**
  String get actionImportColors;

  /// No description provided for @labelGridSettings.
  ///
  /// In en, this message translates to:
  /// **'Grid Settings'**
  String get labelGridSettings;

  /// No description provided for @labelRows.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get labelRows;

  /// No description provided for @labelColumns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get labelColumns;

  /// No description provided for @labelGridVisibility.
  ///
  /// In en, this message translates to:
  /// **'Grid Visibility'**
  String get labelGridVisibility;

  /// No description provided for @labelExtractedColors.
  ///
  /// In en, this message translates to:
  /// **'Extracted Colors'**
  String get labelExtractedColors;

  /// No description provided for @dialogExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Palette'**
  String get dialogExportTitle;

  /// No description provided for @dialogExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose an export format'**
  String get dialogExportDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
