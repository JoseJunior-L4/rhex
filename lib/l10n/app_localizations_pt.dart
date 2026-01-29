// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Rhex';

  @override
  String get menuFile => 'Arquivo';

  @override
  String get menuOpen => 'Abrir';

  @override
  String get menuSave => 'Salvar';

  @override
  String get menuImportImage => 'Importar Imagem';

  @override
  String get menuExportPng => 'Exportar PNG';

  @override
  String get menuEdit => 'Editar';

  @override
  String get menuUndo => 'Desfazer';

  @override
  String get menuRedo => 'Refazer';

  @override
  String get menuClearAll => 'Limpar Tudo';

  @override
  String get menuHelp => 'Ajuda';

  @override
  String get menuHelpShortcuts => 'Ajuda e Atalhos';

  @override
  String get sidebarGridSize => 'Tamanho da Grade';

  @override
  String get sidebarHexLabels => 'Rótulos Hex';

  @override
  String get sidebarAddColor => 'Adicionar Cor';

  @override
  String get sidebarHistory => 'Histórico';

  @override
  String get dialogClearTitle => 'Limpar Paleta?';

  @override
  String get dialogClearDescription =>
      'Tem certeza de que deseja remover todas as cores? Esta ação pode ser desfeita.';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionClear => 'Limpar Tudo';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionUpdate => 'Atualizar';

  @override
  String get toastPaletteCleared => 'Paleta limpa';

  @override
  String get toastPaletteLoaded => 'Paleta carregada com sucesso!';

  @override
  String toastErrorLoading(Object error) {
    return 'Erro ao carregar paleta: $error';
  }

  @override
  String get toastPaletteSaved => 'Paleta salva com sucesso!';

  @override
  String toastErrorSaving(Object error) {
    return 'Erro ao salvar paleta: $error';
  }

  @override
  String toastImportedColors(Object count) {
    return 'Importadas $count cores com sucesso!';
  }

  @override
  String get toastNoColorsExport => 'Sem cores para exportar!';

  @override
  String get toastPaletteExported => 'Paleta exportada com sucesso!';

  @override
  String toastErrorExporting(Object error) {
    return 'Erro ao exportar paleta: $error';
  }

  @override
  String get dialogEditColorTitle => 'Editar Cor';

  @override
  String get dialogEditColorDescription =>
      'Escolha uma nova cor para este espaço da paleta';

  @override
  String get dialogShadeGeneratorTitle => 'Gerador de Sombras';

  @override
  String get labelBaseColor => 'Cor Base';

  @override
  String get labelTints => 'Tons Claros';

  @override
  String get labelShades => 'Tons Escuros';

  @override
  String get importWizardTitle => 'Importar Imagem';

  @override
  String get labelSelectImage => 'Selecionar Imagem';

  @override
  String get labelMaxColors => 'Máx. Cores';

  @override
  String get actionExtractColors => 'Extrair Cores';

  @override
  String get actionImport => 'Importar';

  @override
  String get helpShortcutFileOps => 'Operações de Arquivo';

  @override
  String get helpShortcutEditView => 'Editar e Visualizar';

  @override
  String get helpShortcutColorEditing => 'Edição de Cores';

  @override
  String get helpShortcutAddNewColor => 'Adicionar Nova Cor';

  @override
  String get helpShortcutSavePalette => 'Salvar Paleta (JSON)';

  @override
  String get helpShortcutOpenPalette => 'Abrir Paleta (JSON)';

  @override
  String get helpShortcutExportPng => 'Exportar como PNG';

  @override
  String get helpShortcutImportImage => 'Importar Imagem';

  @override
  String get helpShortcutUndo => 'Desfazer';

  @override
  String get helpShortcutRedo => 'Refazer';

  @override
  String get helpShortcutRedoAlt => 'Refazer (Alternativo)';

  @override
  String get helpShortcutClearAll => 'Limpar Todas as Cores';

  @override
  String get helpShortcutShowHelp => 'Mostrar Ajuda';

  @override
  String get helpShortcutGenerateShades => 'Gerar Tons';

  @override
  String get helpTabShortcuts => 'Atalhos de Teclado';

  @override
  String get helpTabUsage => 'Uso Geral';

  @override
  String get helpUsageTitle => 'Bem-vindo ao Rhex';

  @override
  String get helpUsageDescription =>
      'Um gerenciador de paletas de cores mínimo e focado em teclado para desenvolvedores e designers.';

  @override
  String get helpUsageItem1 => 'Clique no círculo de cor para abrir o seletor';

  @override
  String get helpUsageItem2 =>
      'Digite códigos hex diretamente ou selecione do histórico';

  @override
  String get helpUsageItem3 =>
      'Ajuste o tamanho da grade para organizar sua paleta';

  @override
  String get helpUsageItem4 =>
      'Clique com o botão direito em qualquer cor para gerar tons';

  @override
  String get helpUsageItem5 => 'Arraste e solte para reordenar cores';

  @override
  String get labelColorInput => 'Entrada de Cor';

  @override
  String get labelPickColor => 'Escolha uma cor';

  @override
  String get actionSelect => 'Selecionar';

  @override
  String get actionProcess => 'Processar';

  @override
  String get actionStopAll => 'Parar Tudo';

  @override
  String get actionSkipContinue => 'Pular e Continuar';

  @override
  String get actionBatchAdd => 'Adicionar em Lote';

  @override
  String get dialogBatchAddTitle => 'Adicionar Cores em Lote';

  @override
  String get dialogBatchAddDescription =>
      'Cole códigos hex (um por linha). Formato: #RRGGBB ou RRGGBB';

  @override
  String get dialogInvalidColorTitle => 'Cor Inválida Encontrada';

  @override
  String dialogInvalidColorDescription(Object content, Object line) {
    return 'Linha $line: \"$content\" não é um código hex válido.';
  }

  @override
  String toastBatchProcessingStopped(Object count) {
    return 'Adicionadas $count cores válidas. Processamento parado.';
  }

  @override
  String toastBatchSuccess(Object count) {
    return 'Adicionadas $count cores com sucesso!';
  }

  @override
  String get toastBatchNoColors =>
      'Nenhuma cor válida encontrada para adicionar.';

  @override
  String get labelNoHistory => 'Nenhuma cor no histórico ainda';

  @override
  String get actionClose => 'Fechar';

  @override
  String get helpSectionAddingColors => 'Adicionando Cores';

  @override
  String get helpSectionAddingColorsContent =>
      '• Digite um código hex na barra lateral (ex: #FF5500) e precione Enter.\n• Clique na caixa de pré-visualização de cor para abrir o seletor de cores.\n• Use o botão \"Adicionar Cor\" para adicionar a cor atual à sua grade.\n• Clique no ícone de Dado para gerar uma cor aleatória.';

  @override
  String get helpSectionManagingGrid => 'Gerenciando a Grade';

  @override
  String get helpSectionManagingGridContent =>
      '• Clique em qualquer bloco de cor na grade para Editar ou Excluir.\n• Use o controle deslizante Tamanho da Grade para alterar quantas colunas são exibidas.\n• Alterne \"Rótulos Hex\" para ocultar/mostrar sobreposições de texto.';

  @override
  String get helpSectionImportExport => 'Importar e Exportar';

  @override
  String get helpSectionImportExportContent =>
      '• Importar Imagem: Extraia uma paleta de qualquer arquivo de imagem.\n• Salvar/Abrir: Salve seu trabalho como um arquivo .json para trabalhar mais tarde.\n• Exportar PNG: Gere uma imagem de alta qualidade da sua paleta.';

  @override
  String dialogShadeGeneratorDescription(Object hex) {
    return 'Gerar tons e sombras para $hex';
  }

  @override
  String get labelTintsLighter => 'Tons (Mais Claro)';

  @override
  String get labelShadesDarker => 'Sombras (Mais Escuro)';

  @override
  String get toastColorAdded => 'Cor Adicionada';

  @override
  String toastColorAddedMessage(Object hex) {
    return '$hex adicionada à paleta';
  }

  @override
  String toastErrorLoadingImage(Object error) {
    return 'Falha ao carregar imagem: $error';
  }

  @override
  String get importWizardDescription => 'Ajuste a grade para capturar cores';

  @override
  String get actionImportColors => 'Importar Cores';

  @override
  String get labelGridSettings => 'Configurações da Grade';

  @override
  String get labelRows => 'Linhas';

  @override
  String get labelColumns => 'Colunas';

  @override
  String get labelGridVisibility => 'Visibilidade da Grade';

  @override
  String get labelExtractedColors => 'Cores Extraídas';

  @override
  String get dialogExportTitle => 'Exportar Paleta';

  @override
  String get dialogExportDescription => 'Escolha um formato de exportação';
}
