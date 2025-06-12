// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'プロテイントラッカー';

  @override
  String get todayProgress => '今日の進捗';

  @override
  String get progressOf => '/';

  @override
  String get complete => '完了';

  @override
  String get todayEntries => '今日の記録';

  @override
  String get add => '追加';

  @override
  String get noEntriesToday => '今日の記録はありません';

  @override
  String get startTracking => '最初の記録を追加してください';

  @override
  String get editEntry => '記録を編集';

  @override
  String get edit => '編集';

  @override
  String get delete => '削除';

  @override
  String get deleteEntry => '記録を削除';

  @override
  String get entry => '記録';

  @override
  String get addProtein => 'プロテインを追加';

  @override
  String get recentEntries => '最近の記録';

  @override
  String get proteinSource => 'プロテイン源';

  @override
  String get proteinSourceHint => '例：鶏むね肉、プロテインシェイク';

  @override
  String get proteinAmount => 'プロテイン量';

  @override
  String get proteinAmountHint => '例：30';

  @override
  String get addEntry => '記録を追加';

  @override
  String get settings => '設定';

  @override
  String get dailyProteinGoal => '1日のプロテイン目標';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get history => '履歴';

  @override
  String get noHistory => '履歴がありません';

  @override
  String get today => '今日';

  @override
  String get dailyGoal => '1日の目標';

  @override
  String get dailyGoalHint => '1日の目標を入力';

  @override
  String get noEntries => 'まだ記録がありません';

  @override
  String get appColor => 'アプリの色';

  @override
  String get tapToChangeColor => 'タップして色を変更';

  @override
  String get language => '言語';

  @override
  String get systemDefault => 'システムデフォルト';

  @override
  String get theme => 'テーマ';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get recipeList => 'レシピリスト';

  @override
  String get noRecipes => 'レシピがありません';

  @override
  String get addRecipe => 'レシピを追加';

  @override
  String get recipeName => 'レシピ名';

  @override
  String get recipeNameHint => '例：鶏むね肉とご飯';
}
