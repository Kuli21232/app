import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'MotiveGo'**
  String get appTitle;

  /// No description provided for @tabPlanner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get tabPlanner;

  /// No description provided for @tabReflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get tabReflection;

  /// No description provided for @tabFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get tabFocus;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statsTitle;

  /// No description provided for @coachTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get coachTitle;

  /// No description provided for @overviewTab.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTab;

  /// No description provided for @weekTab.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get weekTab;

  /// No description provided for @trendTab.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trendTab;

  /// No description provided for @progress7d.
  ///
  /// In en, this message translates to:
  /// **'Progress over 7 days'**
  String get progress7d;

  /// No description provided for @doneOfPlanned.
  ///
  /// In en, this message translates to:
  /// **'Done: {done} / {planned}'**
  String doneOfPlanned(int done, int planned);

  /// No description provided for @distribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get distribution;

  /// No description provided for @legendDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get legendDone;

  /// No description provided for @legendRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get legendRemaining;

  /// No description provided for @kpiTotalTasks.
  ///
  /// In en, this message translates to:
  /// **'Total tasks'**
  String get kpiTotalTasks;

  /// No description provided for @kpiDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get kpiDone;

  /// No description provided for @kpiRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get kpiRemaining;

  /// No description provided for @focusCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus (Pomodoro)'**
  String get focusCardTitle;

  /// No description provided for @focusToday.
  ///
  /// In en, this message translates to:
  /// **'Focus today'**
  String get focusToday;

  /// No description provided for @distractions.
  ///
  /// In en, this message translates to:
  /// **'Distractions'**
  String get distractions;

  /// No description provided for @completion7d.
  ///
  /// In en, this message translates to:
  /// **'Completion 7d'**
  String get completion7d;

  /// No description provided for @coachTips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get coachTips;

  /// No description provided for @coachMotivation.
  ///
  /// In en, this message translates to:
  /// **'Motivation'**
  String get coachMotivation;

  /// No description provided for @focusTodayCard.
  ///
  /// In en, this message translates to:
  /// **'Focus today (Pomodoro)'**
  String get focusTodayCard;

  /// No description provided for @pomo_focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get pomo_focus;

  /// No description provided for @pomo_break.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get pomo_break;

  /// No description provided for @pomo_cycles.
  ///
  /// In en, this message translates to:
  /// **'Cycles'**
  String get pomo_cycles;

  /// No description provided for @pomo_distractions.
  ///
  /// In en, this message translates to:
  /// **'Distractions'**
  String get pomo_distractions;

  /// No description provided for @pomo_ready.
  ///
  /// In en, this message translates to:
  /// **'Ready?'**
  String get pomo_ready;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {{count} min} other {{count} min}}'**
  String minutesLabel(num count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language'**
  String get languageSubtitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceTitle;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app theme'**
  String get appearanceSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @backupTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backupTitle;

  /// No description provided for @backupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save all data to a file and restore it on another device'**
  String get backupSubtitle;

  /// No description provided for @backupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create backup'**
  String get backupCreate;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from file'**
  String get backupRestore;

  /// No description provided for @backupClear.
  ///
  /// In en, this message translates to:
  /// **'Clear data'**
  String get backupClear;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved: {file}'**
  String backupSaved(String file);

  /// No description provided for @backupImportOk.
  ///
  /// In en, this message translates to:
  /// **'Data restored'**
  String get backupImportOk;

  /// No description provided for @backupImportError.
  ///
  /// In en, this message translates to:
  /// **'Import error: {details}'**
  String backupImportError(String details);

  /// No description provided for @backupCreateError.
  ///
  /// In en, this message translates to:
  /// **'Backup error: {details}'**
  String backupCreateError(String details);

  /// No description provided for @clearDataConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all data?'**
  String get clearDataConfirmTitle;

  /// No description provided for @clearDataConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete goals, reflections and settings. Make sure you have a backup.'**
  String get clearDataConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @dataCleared.
  ///
  /// In en, this message translates to:
  /// **'Data cleared'**
  String get dataCleared;

  /// No description provided for @reflectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get reflectionTitle;

  /// No description provided for @howWasDay.
  ///
  /// In en, this message translates to:
  /// **'How was your day?'**
  String get howWasDay;

  /// No description provided for @happinessIndex.
  ///
  /// In en, this message translates to:
  /// **'Happiness index: {value}'**
  String happinessIndex(int value);

  /// No description provided for @reflTip0_20.
  ///
  /// In en, this message translates to:
  /// **'Tough day. A short walk and 10 minutes of breathing can reset you.'**
  String get reflTip0_20;

  /// No description provided for @reflTip21_40.
  ///
  /// In en, this message translates to:
  /// **'Set one easy task for the morning to catch the rhythm.'**
  String get reflTip21_40;

  /// No description provided for @reflTip41_60.
  ///
  /// In en, this message translates to:
  /// **'Middle ground! Repeat what worked best.'**
  String get reflTip41_60;

  /// No description provided for @reflTip61_80.
  ///
  /// In en, this message translates to:
  /// **'Great! Lock in success: capture 1–2 habits.'**
  String get reflTip61_80;

  /// No description provided for @reflTip81_100.
  ///
  /// In en, this message translates to:
  /// **'Top form! A small reward and gratitude to yourself.'**
  String get reflTip81_100;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Briefly: what worked? what to improve?'**
  String get noteLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @lastEntries.
  ///
  /// In en, this message translates to:
  /// **'Recent entries'**
  String get lastEntries;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get emptyList;

  /// No description provided for @moodLabel.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get moodLabel;

  /// No description provided for @happinessShort.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get happinessShort;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get chooseDate;

  /// No description provided for @addGoal.
  ///
  /// In en, this message translates to:
  /// **'Add goal'**
  String get addGoal;

  /// No description provided for @goalNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal name'**
  String get goalNameLabel;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get priorityMedium;

  /// No description provided for @priorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get priorityHigh;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @noGoalsToday.
  ///
  /// In en, this message translates to:
  /// **'No goals for this day'**
  String get noGoalsToday;

  /// No description provided for @goalCompletedDialog.
  ///
  /// In en, this message translates to:
  /// **'Nice! Goal completed 🎉'**
  String get goalCompletedDialog;

  /// No description provided for @goalCompletedToast.
  ///
  /// In en, this message translates to:
  /// **'Goal marked as done'**
  String get goalCompletedToast;

  /// No description provided for @goalDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Goal deleted'**
  String get goalDeletedToast;

  /// No description provided for @coachKpiCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get coachKpiCompletion;

  /// No description provided for @coachKpiStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get coachKpiStreak;

  /// No description provided for @coachKpiBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get coachKpiBalance;

  /// No description provided for @coachKpiTrend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get coachKpiTrend;

  /// No description provided for @coachKpiHappiness.
  ///
  /// In en, this message translates to:
  /// **'Happiness index'**
  String get coachKpiHappiness;

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get daysShort;

  /// No description provided for @coachPriority7dTitle.
  ///
  /// In en, this message translates to:
  /// **'Priorities (last 7 days)'**
  String get coachPriority7dTitle;

  /// No description provided for @coachNextStepsTitle.
  ///
  /// In en, this message translates to:
  /// **'What to do next'**
  String get coachNextStepsTitle;

  /// No description provided for @coachAdviceFrom7dNote.
  ///
  /// In en, this message translates to:
  /// **'Tips are based on the last 7 days: plan vs. actual, reflection notes and Pomodoro focus.'**
  String get coachAdviceFrom7dNote;

  /// No description provided for @trendUp.
  ///
  /// In en, this message translates to:
  /// **'rising'**
  String get trendUp;

  /// No description provided for @trendDown.
  ///
  /// In en, this message translates to:
  /// **'falling'**
  String get trendDown;

  /// No description provided for @trendStable.
  ///
  /// In en, this message translates to:
  /// **'stable'**
  String get trendStable;

  /// No description provided for @adviceLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading tip…'**
  String get adviceLoading;

  /// No description provided for @motivationRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh quotes'**
  String get motivationRefresh;

  /// No description provided for @coachOverloadTitleA.
  ///
  /// In en, this message translates to:
  /// **'Plan is overloaded'**
  String get coachOverloadTitleA;

  /// No description provided for @coachOverloadTitleB.
  ///
  /// In en, this message translates to:
  /// **'Too many tasks'**
  String get coachOverloadTitleB;

  /// No description provided for @coachOverloadTitleC.
  ///
  /// In en, this message translates to:
  /// **'Reduce the load'**
  String get coachOverloadTitleC;

  /// No description provided for @coachOverloadBodyA.
  ///
  /// In en, this message translates to:
  /// **'Keep ≤6 tasks per day, move the rest to a backlog. Start with a P3/P2 in the morning.'**
  String get coachOverloadBodyA;

  /// No description provided for @coachOverloadBodyB.
  ///
  /// In en, this message translates to:
  /// **'Cut the daily list by 30–40%. Secure one small win before noon.'**
  String get coachOverloadBodyB;

  /// No description provided for @coachOverloadBodyC.
  ///
  /// In en, this message translates to:
  /// **'Lighten the week: move tasks to free slots and batch P1 items.'**
  String get coachOverloadBodyC;

  /// No description provided for @coachLowCompletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Low completion'**
  String get coachLowCompletionTitle;

  /// No description provided for @coachLowCompletionBody.
  ///
  /// In en, this message translates to:
  /// **'Plan 70–80% of time and keep a buffer. Add one easy starter task.'**
  String get coachLowCompletionBody;

  /// No description provided for @coachMidCompletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Progress — add buffer'**
  String get coachMidCompletionTitle;

  /// No description provided for @coachMidCompletionBody.
  ///
  /// In en, this message translates to:
  /// **'Plan 70–80% and leave room for the unexpected. Keep one easy backup task.'**
  String get coachMidCompletionBody;

  /// No description provided for @coachGreatPaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Great pace'**
  String get coachGreatPaceTitle;

  /// No description provided for @coachGreatPaceBody.
  ///
  /// In en, this message translates to:
  /// **'Increase difficulty gradually: one P3 per day or a new 10–15 min habit.'**
  String get coachGreatPaceBody;

  /// No description provided for @coachWeakP3Title.
  ///
  /// In en, this message translates to:
  /// **'Weak P3 completion'**
  String get coachWeakP3Title;

  /// No description provided for @coachWeakP3Body.
  ///
  /// In en, this message translates to:
  /// **'Move one P3 to the morning and split it into 2–3 subtasks. Finish the subtask, not the mountain.'**
  String get coachWeakP3Body;

  /// No description provided for @coachNoP3Title.
  ///
  /// In en, this message translates to:
  /// **'No heavy tasks'**
  String get coachNoP3Title;

  /// No description provided for @coachNoP3Body.
  ///
  /// In en, this message translates to:
  /// **'Add one ambitious P3 this week — it sets direction and motivates.'**
  String get coachNoP3Body;

  /// No description provided for @coachP1StuckTitle.
  ///
  /// In en, this message translates to:
  /// **'Light tasks are stalling'**
  String get coachP1StuckTitle;

  /// No description provided for @coachP1StuckBody.
  ///
  /// In en, this message translates to:
  /// **'Batch P1s into a 20-min “inbox clearing” slot after lunch. One timer, better pace.'**
  String get coachP1StuckBody;

  /// No description provided for @coachPrioritySkewTitle.
  ///
  /// In en, this message translates to:
  /// **'Priority skew'**
  String get coachPrioritySkewTitle;

  /// No description provided for @coachPrioritySkewBody.
  ///
  /// In en, this message translates to:
  /// **'Match P3/P2/P1 shares in plan vs actual. Do P3 earlier in the day, batch P1 later.'**
  String get coachPrioritySkewBody;

  /// No description provided for @coachGoodBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Good balance'**
  String get coachGoodBalanceTitle;

  /// No description provided for @coachGoodBalanceBody.
  ///
  /// In en, this message translates to:
  /// **'Keep the distribution and repeat your best time windows.'**
  String get coachGoodBalanceBody;

  /// No description provided for @coachTrendDownTitle.
  ///
  /// In en, this message translates to:
  /// **'Trend down'**
  String get coachTrendDownTitle;

  /// No description provided for @coachTrendDownBody.
  ///
  /// In en, this message translates to:
  /// **'Do a one-day reset with a lighter plan, then ramp up gradually.'**
  String get coachTrendDownBody;

  /// No description provided for @coachTrendUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Trend up'**
  String get coachTrendUpTitle;

  /// No description provided for @coachTrendUpBody.
  ///
  /// In en, this message translates to:
  /// **'Capture what worked (time/place/task type) and repeat tomorrow.'**
  String get coachTrendUpBody;

  /// No description provided for @coachCareTitle.
  ///
  /// In en, this message translates to:
  /// **'Care for your energy'**
  String get coachCareTitle;

  /// No description provided for @coachCareBody.
  ///
  /// In en, this message translates to:
  /// **'Daily: water, 10-min walk, 4-7-8 breathing. This is the grease for productivity.'**
  String get coachCareBody;

  /// No description provided for @coachUsePeakTitle.
  ///
  /// In en, this message translates to:
  /// **'Use the peak'**
  String get coachUsePeakTitle;

  /// No description provided for @coachUsePeakBody.
  ///
  /// In en, this message translates to:
  /// **'Schedule a P3 for your energy peak and remove distractions (phone in another room for 45 min).'**
  String get coachUsePeakBody;

  /// No description provided for @coachStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'Streak: {days} days'**
  String coachStreakTitle(int days);

  /// No description provided for @coachStreakBody.
  ///
  /// In en, this message translates to:
  /// **'Note what keeps the rhythm and don’t break the chain tomorrow — at least one small win.'**
  String get coachStreakBody;

  /// No description provided for @coachNeedStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Need a start'**
  String get coachNeedStartTitle;

  /// No description provided for @coachNeedStartBody.
  ///
  /// In en, this message translates to:
  /// **'Begin with a 10-minute task. Kick off momentum — the rest is easier.'**
  String get coachNeedStartBody;

  /// No description provided for @coachSummary7d.
  ///
  /// In en, this message translates to:
  /// **'7-day summary'**
  String get coachSummary7d;

  /// No description provided for @reflDailyMetrics.
  ///
  /// In en, this message translates to:
  /// **'Daily metrics'**
  String get reflDailyMetrics;

  /// No description provided for @reflEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get reflEnergy;

  /// No description provided for @reflEnergyShort.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get reflEnergyShort;

  /// No description provided for @reflStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get reflStress;

  /// No description provided for @reflStressShort.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get reflStressShort;

  /// No description provided for @reflSleepHours.
  ///
  /// In en, this message translates to:
  /// **'Sleep, hours'**
  String get reflSleepHours;

  /// No description provided for @reflSleepShort.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get reflSleepShort;

  /// No description provided for @reflGratitudeTitle.
  ///
  /// In en, this message translates to:
  /// **'Gratitude'**
  String get reflGratitudeTitle;

  /// No description provided for @reflGratitudeHint.
  ///
  /// In en, this message translates to:
  /// **'Write 1–3 things you’re grateful for today'**
  String get reflGratitudeHint;

  /// No description provided for @reflGratitudePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'I\'m grateful for...'**
  String get reflGratitudePlaceholder;

  /// No description provided for @reflNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Day notes'**
  String get reflNotesTitle;

  /// No description provided for @reflHighlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight of the day'**
  String get reflHighlight;

  /// No description provided for @reflBlockers.
  ///
  /// In en, this message translates to:
  /// **'What got in the way'**
  String get reflBlockers;

  /// No description provided for @reflQuickTemplates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get reflQuickTemplates;

  /// No description provided for @reflTplSmooth.
  ///
  /// In en, this message translates to:
  /// **'The day went smoothly'**
  String get reflTplSmooth;

  /// No description provided for @reflTplLearned.
  ///
  /// In en, this message translates to:
  /// **'I learned something new today'**
  String get reflTplLearned;

  /// No description provided for @reflTplHelped.
  ///
  /// In en, this message translates to:
  /// **'I helped someone'**
  String get reflTplHelped;

  /// No description provided for @reflTplWalk.
  ///
  /// In en, this message translates to:
  /// **'I went for a walk'**
  String get reflTplWalk;

  /// No description provided for @reflTplWorkout.
  ///
  /// In en, this message translates to:
  /// **'I did a workout'**
  String get reflTplWorkout;

  /// No description provided for @reflReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reflReset;

  /// No description provided for @reflCopiedFromPast.
  ///
  /// In en, this message translates to:
  /// **'Filled with values from a past entry'**
  String get reflCopiedFromPast;

  /// No description provided for @reflAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get reflAddItem;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get accountLoading;

  /// No description provided for @accountNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not signed in'**
  String get accountNotSignedIn;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @userNoName.
  ///
  /// In en, this message translates to:
  /// **'No name'**
  String get userNoName;

  /// No description provided for @userNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get userNoEmail;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your goals and backups across devices'**
  String get welcomeSubtitle;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInTitle;

  /// No description provided for @authSignUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get authSignUpTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordShow.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get passwordShow;

  /// No description provided for @passwordHide.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get passwordHide;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpButton;

  /// No description provided for @toggleNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account? Sign up'**
  String get toggleNoAccount;

  /// No description provided for @toggleHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get toggleHaveAccount;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed: {error}'**
  String loginFailed(Object error);

  /// No description provided for @loginSuccessHello.
  ///
  /// In en, this message translates to:
  /// **'Done! Hello, {name}'**
  String loginSuccessHello(Object name);

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDontMatch;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your e-mail — we will send a reset link.'**
  String get resetSubtitle;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get sendLink;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset e-mail sent to {email}'**
  String resetEmailSent(Object email);

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your e-mail'**
  String get verifyTitle;

  /// No description provided for @verifyDesc.
  ///
  /// In en, this message translates to:
  /// **'We sent a message to {email}. Open it and follow the link to verify.'**
  String verifyDesc(Object email);

  /// No description provided for @verifyEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification e-mail sent to {email}'**
  String verifyEmailSent(Object email);

  /// No description provided for @iVerified.
  ///
  /// In en, this message translates to:
  /// **'I have verified'**
  String get iVerified;

  /// No description provided for @resendNow.
  ///
  /// In en, this message translates to:
  /// **'Resend now'**
  String get resendNow;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(Object seconds);

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @verifyCooldown.
  ///
  /// In en, this message translates to:
  /// **'You can resend in {seconds}s'**
  String verifyCooldown(Object seconds);

  /// No description provided for @hubTitle.
  ///
  /// In en, this message translates to:
  /// **'Hub'**
  String get hubTitle;

  /// No description provided for @hubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan · Focus · Reflect'**
  String get hubSubtitle;

  /// No description provided for @planner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @reflection.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get reflection;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @configure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configure;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks today'**
  String get noTasks;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// No description provided for @breakLabel.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get breakLabel;

  /// No description provided for @cycles.
  ///
  /// In en, this message translates to:
  /// **'Cycles'**
  String get cycles;

  /// No description provided for @quickSave.
  ///
  /// In en, this message translates to:
  /// **'Quick save'**
  String get quickSave;

  /// No description provided for @weekProgress.
  ///
  /// In en, this message translates to:
  /// **'7-day progress'**
  String get weekProgress;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// No description provided for @everythingAtOnce.
  ///
  /// In en, this message translates to:
  /// **'Everything at one place'**
  String get everythingAtOnce;

  /// No description provided for @startFocus.
  ///
  /// In en, this message translates to:
  /// **'Start focus'**
  String get startFocus;

  /// No description provided for @reflect.
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get reflect;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @last7d.
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get last7d;

  /// No description provided for @pomoTipStart.
  ///
  /// In en, this message translates to:
  /// **'Start with one full 25/5 cycle. Small win = best momentum.'**
  String get pomoTipStart;

  /// No description provided for @pomoTipGoodPace.
  ///
  /// In en, this message translates to:
  /// **'Good pace. Try 3–4 cycles in a row, then a 15–20 min long break.'**
  String get pomoTipGoodPace;

  /// No description provided for @pomoTipGreat.
  ///
  /// In en, this message translates to:
  /// **'Great focus! Capture what worked and repeat tomorrow at the same time.'**
  String get pomoTipGreat;

  /// No description provided for @pomoTipTooManyDistr.
  ///
  /// In en, this message translates to:
  /// **'Too many distractions: enable Do Not Disturb, put the phone away, work by a window.'**
  String get pomoTipTooManyDistr;

  /// No description provided for @pomoTipRaiseCompletion.
  ///
  /// In en, this message translates to:
  /// **'Finish at least 2 cycles today to lift your 7-day completion rate.'**
  String get pomoTipRaiseCompletion;

  /// No description provided for @pomoTipIncreaseInterval.
  ///
  /// In en, this message translates to:
  /// **'High consistency! Consider increasing the focus interval to 30 minutes.'**
  String get pomoTipIncreaseInterval;

  /// No description provided for @motPhrase1.
  ///
  /// In en, this message translates to:
  /// **'Small steps — big results.'**
  String get motPhrase1;

  /// No description provided for @motPhrase2.
  ///
  /// In en, this message translates to:
  /// **'Do what matters, not what’s urgent.'**
  String get motPhrase2;

  /// No description provided for @motPhrase3.
  ///
  /// In en, this message translates to:
  /// **'Progress is checkmarks, not perfection.'**
  String get motPhrase3;

  /// No description provided for @motPhrase4.
  ///
  /// In en, this message translates to:
  /// **'The best day to start is today.'**
  String get motPhrase4;

  /// No description provided for @motPhrase5.
  ///
  /// In en, this message translates to:
  /// **'25 minutes of focus works wonders.'**
  String get motPhrase5;

  /// No description provided for @motPhrase6.
  ///
  /// In en, this message translates to:
  /// **'Rest is part of the work.'**
  String get motPhrase6;

  /// No description provided for @motPhrase7.
  ///
  /// In en, this message translates to:
  /// **'Do one hard thing before lunch.'**
  String get motPhrase7;

  /// No description provided for @motPhrase8.
  ///
  /// In en, this message translates to:
  /// **'Not all at once, but every day a little.'**
  String get motPhrase8;

  /// No description provided for @motPhrase9.
  ///
  /// In en, this message translates to:
  /// **'Be consistent, not perfect.'**
  String get motPhrase9;

  /// No description provided for @motPhrase10.
  ///
  /// In en, this message translates to:
  /// **'In doubt? Start with 10 minutes.'**
  String get motPhrase10;

  /// No description provided for @goalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTitle;

  /// No description provided for @goalsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get goalsAdd;

  /// No description provided for @goalsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No goals yet'**
  String get goalsEmpty;

  /// No description provided for @goalType.
  ///
  /// In en, this message translates to:
  /// **'Goal type'**
  String get goalType;

  /// No description provided for @goalName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get goalName;

  /// No description provided for @photoUrlOptional.
  ///
  /// In en, this message translates to:
  /// **'Photo (URL, optional)'**
  String get photoUrlOptional;

  /// No description provided for @goalSavings.
  ///
  /// In en, this message translates to:
  /// **'Save money'**
  String get goalSavings;

  /// No description provided for @goalHabit.
  ///
  /// In en, this message translates to:
  /// **'Quit a bad habit'**
  String get goalHabit;

  /// No description provided for @goalSport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get goalSport;

  /// No description provided for @weeklyIncome.
  ///
  /// In en, this message translates to:
  /// **'Weekly income'**
  String get weeklyIncome;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target amount'**
  String get targetAmount;

  /// No description provided for @habitKind.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get habitKind;

  /// No description provided for @sportKind.
  ///
  /// In en, this message translates to:
  /// **'Sport kind'**
  String get sportKind;

  /// No description provided for @suggestedTasks.
  ///
  /// In en, this message translates to:
  /// **'Suggested tasks'**
  String get suggestedTasks;

  /// No description provided for @addCustomTask.
  ///
  /// In en, this message translates to:
  /// **'Add your own task'**
  String get addCustomTask;

  /// No description provided for @createGoal.
  ///
  /// In en, this message translates to:
  /// **'Create goal'**
  String get createGoal;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @confirmDeleteGoal.
  ///
  /// In en, this message translates to:
  /// **'Delete goal?'**
  String get confirmDeleteGoal;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get notFound;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @depositAmount.
  ///
  /// In en, this message translates to:
  /// **'Deposit amount'**
  String get depositAmount;

  /// No description provided for @doneToday.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get doneToday;

  /// No description provided for @todayChecklist.
  ///
  /// In en, this message translates to:
  /// **'Today\'s checklist'**
  String get todayChecklist;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'Streak: {count} days'**
  String streakDays(Object count);

  /// No description provided for @goalsSavedOf.
  ///
  /// In en, this message translates to:
  /// **'{saved} / {target}'**
  String goalsSavedOf(Object saved, Object target);

  /// No description provided for @recommendedWeeklyDeposit.
  ///
  /// In en, this message translates to:
  /// **'Recommended weekly deposit: {sum}'**
  String recommendedWeeklyDeposit(Object sum);

  /// No description provided for @habitSmoking.
  ///
  /// In en, this message translates to:
  /// **'Smoking'**
  String get habitSmoking;

  /// No description provided for @habitAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get habitAlcohol;

  /// No description provided for @habitSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get habitSugar;

  /// No description provided for @habitJunkFood.
  ///
  /// In en, this message translates to:
  /// **'Fast food'**
  String get habitJunkFood;

  /// No description provided for @habitSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Social media'**
  String get habitSocialMedia;

  /// No description provided for @habitGaming.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get habitGaming;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @sportRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get sportRunning;

  /// No description provided for @sportGym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get sportGym;

  /// No description provided for @sportYoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get sportYoga;

  /// No description provided for @sportSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get sportSwimming;

  /// No description provided for @sportCycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get sportCycling;

  /// No description provided for @taskNoSmoking.
  ///
  /// In en, this message translates to:
  /// **'No cigarettes'**
  String get taskNoSmoking;

  /// No description provided for @taskDrinkWater.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get taskDrinkWater;

  /// No description provided for @taskBreathing5m.
  ///
  /// In en, this message translates to:
  /// **'Breathing 5 min'**
  String get taskBreathing5m;

  /// No description provided for @taskNoAlcohol.
  ///
  /// In en, this message translates to:
  /// **'No alcohol'**
  String get taskNoAlcohol;

  /// No description provided for @taskWalk20m.
  ///
  /// In en, this message translates to:
  /// **'Walk 20 min'**
  String get taskWalk20m;

  /// No description provided for @taskNoSocial2h.
  ///
  /// In en, this message translates to:
  /// **'No social media 2h'**
  String get taskNoSocial2h;

  /// No description provided for @taskRead10p.
  ///
  /// In en, this message translates to:
  /// **'Read 10 pages'**
  String get taskRead10p;

  /// No description provided for @taskNoSugar.
  ///
  /// In en, this message translates to:
  /// **'No sugar'**
  String get taskNoSugar;

  /// No description provided for @taskFruitInstead.
  ///
  /// In en, this message translates to:
  /// **'Fruit instead of sweets'**
  String get taskFruitInstead;

  /// No description provided for @taskNoJunk.
  ///
  /// In en, this message translates to:
  /// **'No junk food'**
  String get taskNoJunk;

  /// No description provided for @taskSaladPortion.
  ///
  /// In en, this message translates to:
  /// **'Salad/veggies 1 serving'**
  String get taskSaladPortion;

  /// No description provided for @taskNoGames3h.
  ///
  /// In en, this message translates to:
  /// **'No games for 3h'**
  String get taskNoGames3h;

  /// No description provided for @taskSport20m.
  ///
  /// In en, this message translates to:
  /// **'Any sport 20 min'**
  String get taskSport20m;

  /// No description provided for @taskStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1'**
  String get taskStep1;

  /// No description provided for @taskStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2'**
  String get taskStep2;

  /// No description provided for @taskWarmup10m.
  ///
  /// In en, this message translates to:
  /// **'Warm-up 10 min'**
  String get taskWarmup10m;

  /// No description provided for @taskRun20_30m.
  ///
  /// In en, this message translates to:
  /// **'Run 20–30 min'**
  String get taskRun20_30m;

  /// No description provided for @taskStretching.
  ///
  /// In en, this message translates to:
  /// **'Stretching'**
  String get taskStretching;

  /// No description provided for @taskWarmup.
  ///
  /// In en, this message translates to:
  /// **'Warm-up'**
  String get taskWarmup;

  /// No description provided for @taskStrength30_40m.
  ///
  /// In en, this message translates to:
  /// **'Strength 30–40 min'**
  String get taskStrength30_40m;

  /// No description provided for @taskCooldown.
  ///
  /// In en, this message translates to:
  /// **'Cool-down'**
  String get taskCooldown;

  /// No description provided for @taskYoga20_30m.
  ///
  /// In en, this message translates to:
  /// **'Yoga 20–30 min'**
  String get taskYoga20_30m;

  /// No description provided for @taskSwim30m.
  ///
  /// In en, this message translates to:
  /// **'Swim 30 min'**
  String get taskSwim30m;

  /// No description provided for @taskBike30_60m.
  ///
  /// In en, this message translates to:
  /// **'Bike 30–60 min'**
  String get taskBike30_60m;

  /// No description provided for @taskActivity20_30m.
  ///
  /// In en, this message translates to:
  /// **'Activity 20–30 min'**
  String get taskActivity20_30m;

  /// No description provided for @backToSignUp.
  ///
  /// In en, this message translates to:
  /// **'Back to sign up'**
  String get backToSignUp;

  /// No description provided for @backToSignUpHint.
  ///
  /// In en, this message translates to:
  /// **'You can register again with the correct e-mail.'**
  String get backToSignUpHint;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change e-mail'**
  String get changeEmail;

  /// No description provided for @changeEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Change e-mail address'**
  String get changeEmailTitle;

  /// No description provided for @changeEmailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a new address and we’ll send a verification e-mail.'**
  String get changeEmailSubtitle;

  /// No description provided for @saveAndSend.
  ///
  /// In en, this message translates to:
  /// **'Save & send'**
  String get saveAndSend;

  /// No description provided for @changeEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification e-mail sent to {email}'**
  String changeEmailSent(Object email);

  /// No description provided for @reloginToChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Recent sign-in required to change e-mail. Please sign in again.'**
  String get reloginToChangeEmail;

  /// No description provided for @stage1Title.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get stage1Title;

  /// No description provided for @stage2Title.
  ///
  /// In en, this message translates to:
  /// **'Stabilization'**
  String get stage2Title;

  /// No description provided for @stage3Title.
  ///
  /// In en, this message translates to:
  /// **'Consolidation'**
  String get stage3Title;

  /// No description provided for @stageProgress.
  ///
  /// In en, this message translates to:
  /// **'Stage {current} of {total}'**
  String stageProgress(Object current, Object total);

  /// No description provided for @dayOf.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of {total}'**
  String dayOf(Object day, Object total);

  /// No description provided for @didYouQuit.
  ///
  /// In en, this message translates to:
  /// **'Did you quit?'**
  String get didYouQuit;

  /// No description provided for @didYouQuitDesc.
  ///
  /// In en, this message translates to:
  /// **'If not, we will continue to the next stage.'**
  String get didYouQuitDesc;

  /// No description provided for @iQuit.
  ///
  /// In en, this message translates to:
  /// **'Yes, I quit'**
  String get iQuit;

  /// No description provided for @continueRoad.
  ///
  /// In en, this message translates to:
  /// **'Not yet, continue'**
  String get continueRoad;

  /// No description provided for @statusQuit.
  ///
  /// In en, this message translates to:
  /// **'Status: quit'**
  String get statusQuit;

  /// No description provided for @coachRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get coachRefresh;

  /// No description provided for @coachNoData.
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet — keep going!'**
  String get coachNoData;

  /// No description provided for @completeChecklistHint.
  ///
  /// In en, this message translates to:
  /// **'Tick today’s checklist — that’s how the habit sticks.'**
  String get completeChecklistHint;

  /// No description provided for @sv_tip_fill_income.
  ///
  /// In en, this message translates to:
  /// **'Set your weekly income so I can suggest a deposit amount.'**
  String get sv_tip_fill_income;

  /// No description provided for @sv_tip_start_auto.
  ///
  /// In en, this message translates to:
  /// **'Start with a tiny auto-transfer (5–10%): consistency beats size.'**
  String get sv_tip_start_auto;

  /// No description provided for @sv_tip_small_deposit.
  ///
  /// In en, this message translates to:
  /// **'Try to deposit this week: {amount}'**
  String sv_tip_small_deposit(Object amount);

  /// No description provided for @sv_tip_visualize.
  ///
  /// In en, this message translates to:
  /// **'You are close — keep the goal photo handy to resist impulse spending.'**
  String get sv_tip_visualize;

  /// No description provided for @hb_s1_1.
  ///
  /// In en, this message translates to:
  /// **'Remove triggers (lighters, snacks, “just in case”).'**
  String get hb_s1_1;

  /// No description provided for @hb_s1_2.
  ///
  /// In en, this message translates to:
  /// **'Tell close ones — a social contract helps.'**
  String get hb_s1_2;

  /// No description provided for @hb_s1_3.
  ///
  /// In en, this message translates to:
  /// **'Plan replacements (gum, tea, water) for craving moments.'**
  String get hb_s1_3;

  /// No description provided for @hb_s2_1.
  ///
  /// In en, this message translates to:
  /// **'Plan “hard moments” in advance (after meals, breaks, evenings).'**
  String get hb_s2_1;

  /// No description provided for @hb_s2_2.
  ///
  /// In en, this message translates to:
  /// **'Watch sleep and hydration — deficits increase cravings.'**
  String get hb_s2_2;

  /// No description provided for @hb_s2_3.
  ///
  /// In en, this message translates to:
  /// **'Reward yourself daily — small wins matter.'**
  String get hb_s2_3;

  /// No description provided for @hb_s3_1.
  ///
  /// In en, this message translates to:
  /// **'Rehearse relapses: what you’ll say and do when craving hits.'**
  String get hb_s3_1;

  /// No description provided for @hb_s3_2.
  ///
  /// In en, this message translates to:
  /// **'Write down the benefits of the new life — reread during weak moments.'**
  String get hb_s3_2;

  /// No description provided for @hb_s3_3.
  ///
  /// In en, this message translates to:
  /// **'Share your experience/help someone — it cements the habit.'**
  String get hb_s3_3;

  /// No description provided for @hb_start_small.
  ///
  /// In en, this message translates to:
  /// **'Start tiny and steady — stability first.'**
  String get hb_start_small;

  /// No description provided for @hb_keep_chain.
  ///
  /// In en, this message translates to:
  /// **'Don’t break the chain: one day is a win.'**
  String get hb_keep_chain;

  /// No description provided for @hb_high_streak.
  ///
  /// In en, this message translates to:
  /// **'Great streak! Anchor the routine (alarm, sticky note).'**
  String get hb_high_streak;

  /// No description provided for @hb_maintain_1.
  ///
  /// In en, this message translates to:
  /// **'You did it! Keep support rituals for 2–3 more weeks.'**
  String get hb_maintain_1;

  /// No description provided for @hb_maintain_2.
  ///
  /// In en, this message translates to:
  /// **'Occasionally test yourself with “no-action triggers” — build resilience.'**
  String get hb_maintain_2;

  /// No description provided for @hb_maintain_3.
  ///
  /// In en, this message translates to:
  /// **'Plan a new goal so your freed-up time works for you.'**
  String get hb_maintain_3;

  /// No description provided for @sp_beginner_1.
  ///
  /// In en, this message translates to:
  /// **'Keep workouts short (15–20 min) — easier to stay consistent.'**
  String get sp_beginner_1;

  /// No description provided for @sp_beginner_2.
  ///
  /// In en, this message translates to:
  /// **'Prepare your gear the night before — reduce start friction.'**
  String get sp_beginner_2;

  /// No description provided for @sp_consistency_1.
  ///
  /// In en, this message translates to:
  /// **'Consistency > volume: aim for 3 sessions per week.'**
  String get sp_consistency_1;

  /// No description provided for @sp_consistency_2.
  ///
  /// In en, this message translates to:
  /// **'Use fixed days/time so you don’t negotiate with yourself.'**
  String get sp_consistency_2;

  /// No description provided for @sp_deload_1.
  ///
  /// In en, this message translates to:
  /// **'Nice long streak! Add a light deload to recover.'**
  String get sp_deload_1;

  /// No description provided for @sp_deload_2.
  ///
  /// In en, this message translates to:
  /// **'Track heart rate/energy — don’t overdo it.'**
  String get sp_deload_2;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
