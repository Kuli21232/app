// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MotiveGo';

  @override
  String get tabPlanner => 'Planner';

  @override
  String get tabReflection => 'Reflection';

  @override
  String get tabFocus => 'Focus';

  @override
  String get tabSettings => 'Settings';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get coachTitle => 'Tips';

  @override
  String get overviewTab => 'Overview';

  @override
  String get weekTab => 'Week';

  @override
  String get trendTab => 'Trend';

  @override
  String get progress7d => 'Progress over 7 days';

  @override
  String doneOfPlanned(int done, int planned) {
    return 'Done: $done / $planned';
  }

  @override
  String get distribution => 'Distribution';

  @override
  String get legendDone => 'Done';

  @override
  String get legendRemaining => 'Remaining';

  @override
  String get kpiTotalTasks => 'Total tasks';

  @override
  String get kpiDone => 'Done';

  @override
  String get kpiRemaining => 'Remaining';

  @override
  String get focusCardTitle => 'Focus (Pomodoro)';

  @override
  String get focusToday => 'Focus today';

  @override
  String get distractions => 'Distractions';

  @override
  String get completion7d => 'Completion 7d';

  @override
  String get coachTips => 'Tips';

  @override
  String get coachMotivation => 'Motivation';

  @override
  String get focusTodayCard => 'Focus today (Pomodoro)';

  @override
  String get pomo_focus => 'Focus';

  @override
  String get pomo_break => 'Break';

  @override
  String get pomo_cycles => 'Cycles';

  @override
  String get pomo_distractions => 'Distractions';

  @override
  String get pomo_ready => 'Ready?';

  @override
  String minutesLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count min',
      one: '$count min',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose the app language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageEnglish => 'English';

  @override
  String get appearanceTitle => 'Appearance';

  @override
  String get appearanceSubtitle => 'Choose the app theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get backupTitle => 'Backup';

  @override
  String get backupSubtitle => 'Save all data to a file and restore it on another device';

  @override
  String get backupCreate => 'Create backup';

  @override
  String get backupRestore => 'Restore from file';

  @override
  String get backupClear => 'Clear data';

  @override
  String backupSaved(String file) {
    return 'Backup saved: $file';
  }

  @override
  String get backupImportOk => 'Data restored';

  @override
  String backupImportError(String details) {
    return 'Import error: $details';
  }

  @override
  String backupCreateError(String details) {
    return 'Backup error: $details';
  }

  @override
  String get clearDataConfirmTitle => 'Clear all data?';

  @override
  String get clearDataConfirmBody => 'This will delete goals, reflections and settings. Make sure you have a backup.';

  @override
  String get cancel => 'Cancel';

  @override
  String get clear => 'Clear';

  @override
  String get dataCleared => 'Data cleared';

  @override
  String get reflectionTitle => 'Reflection';

  @override
  String get howWasDay => 'How was your day?';

  @override
  String happinessIndex(int value) {
    return 'Happiness index: $value';
  }

  @override
  String get reflTip0_20 => 'Tough day. A short walk and 10 minutes of breathing can reset you.';

  @override
  String get reflTip21_40 => 'Set one easy task for the morning to catch the rhythm.';

  @override
  String get reflTip41_60 => 'Middle ground! Repeat what worked best.';

  @override
  String get reflTip61_80 => 'Great! Lock in success: capture 1–2 habits.';

  @override
  String get reflTip81_100 => 'Top form! A small reward and gratitude to yourself.';

  @override
  String get noteLabel => 'Briefly: what worked? what to improve?';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get lastEntries => 'Recent entries';

  @override
  String get emptyList => 'No entries yet';

  @override
  String get moodLabel => 'Mood';

  @override
  String get happinessShort => 'Index';

  @override
  String get chooseDate => 'Pick a date';

  @override
  String get addGoal => 'Add goal';

  @override
  String get goalNameLabel => 'Goal name';

  @override
  String get priority => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get addButton => 'Add';

  @override
  String get noGoalsToday => 'No goals for this day';

  @override
  String get goalCompletedDialog => 'Nice! Goal completed 🎉';

  @override
  String get goalCompletedToast => 'Goal marked as done';

  @override
  String get goalDeletedToast => 'Goal deleted';

  @override
  String get coachKpiCompletion => 'Completion';

  @override
  String get coachKpiStreak => 'Streak';

  @override
  String get coachKpiBalance => 'Balance';

  @override
  String get coachKpiTrend => 'Trend';

  @override
  String get coachKpiHappiness => 'Happiness index';

  @override
  String get daysShort => 'd';

  @override
  String get coachPriority7dTitle => 'Priorities (last 7 days)';

  @override
  String get coachNextStepsTitle => 'What to do next';

  @override
  String get coachAdviceFrom7dNote => 'Tips are based on the last 7 days: plan vs. actual, reflection notes and Pomodoro focus.';

  @override
  String get trendUp => 'rising';

  @override
  String get trendDown => 'falling';

  @override
  String get trendStable => 'stable';

  @override
  String get adviceLoading => 'Loading tip…';

  @override
  String get motivationRefresh => 'Refresh quotes';

  @override
  String get coachOverloadTitleA => 'Plan is overloaded';

  @override
  String get coachOverloadTitleB => 'Too many tasks';

  @override
  String get coachOverloadTitleC => 'Reduce the load';

  @override
  String get coachOverloadBodyA => 'Keep ≤6 tasks per day, move the rest to a backlog. Start with a P3/P2 in the morning.';

  @override
  String get coachOverloadBodyB => 'Cut the daily list by 30–40%. Secure one small win before noon.';

  @override
  String get coachOverloadBodyC => 'Lighten the week: move tasks to free slots and batch P1 items.';

  @override
  String get coachLowCompletionTitle => 'Low completion';

  @override
  String get coachLowCompletionBody => 'Plan 70–80% of time and keep a buffer. Add one easy starter task.';

  @override
  String get coachMidCompletionTitle => 'Progress — add buffer';

  @override
  String get coachMidCompletionBody => 'Plan 70–80% and leave room for the unexpected. Keep one easy backup task.';

  @override
  String get coachGreatPaceTitle => 'Great pace';

  @override
  String get coachGreatPaceBody => 'Increase difficulty gradually: one P3 per day or a new 10–15 min habit.';

  @override
  String get coachWeakP3Title => 'Weak P3 completion';

  @override
  String get coachWeakP3Body => 'Move one P3 to the morning and split it into 2–3 subtasks. Finish the subtask, not the mountain.';

  @override
  String get coachNoP3Title => 'No heavy tasks';

  @override
  String get coachNoP3Body => 'Add one ambitious P3 this week — it sets direction and motivates.';

  @override
  String get coachP1StuckTitle => 'Light tasks are stalling';

  @override
  String get coachP1StuckBody => 'Batch P1s into a 20-min “inbox clearing” slot after lunch. One timer, better pace.';

  @override
  String get coachPrioritySkewTitle => 'Priority skew';

  @override
  String get coachPrioritySkewBody => 'Match P3/P2/P1 shares in plan vs actual. Do P3 earlier in the day, batch P1 later.';

  @override
  String get coachGoodBalanceTitle => 'Good balance';

  @override
  String get coachGoodBalanceBody => 'Keep the distribution and repeat your best time windows.';

  @override
  String get coachTrendDownTitle => 'Trend down';

  @override
  String get coachTrendDownBody => 'Do a one-day reset with a lighter plan, then ramp up gradually.';

  @override
  String get coachTrendUpTitle => 'Trend up';

  @override
  String get coachTrendUpBody => 'Capture what worked (time/place/task type) and repeat tomorrow.';

  @override
  String get coachCareTitle => 'Care for your energy';

  @override
  String get coachCareBody => 'Daily: water, 10-min walk, 4-7-8 breathing. This is the grease for productivity.';

  @override
  String get coachUsePeakTitle => 'Use the peak';

  @override
  String get coachUsePeakBody => 'Schedule a P3 for your energy peak and remove distractions (phone in another room for 45 min).';

  @override
  String coachStreakTitle(int days) {
    return 'Streak: $days days';
  }

  @override
  String get coachStreakBody => 'Note what keeps the rhythm and don’t break the chain tomorrow — at least one small win.';

  @override
  String get coachNeedStartTitle => 'Need a start';

  @override
  String get coachNeedStartBody => 'Begin with a 10-minute task. Kick off momentum — the rest is easier.';

  @override
  String get coachSummary7d => '7-day summary';

  @override
  String get reflDailyMetrics => 'Daily metrics';

  @override
  String get reflEnergy => 'Energy';

  @override
  String get reflEnergyShort => 'Energy';

  @override
  String get reflStress => 'Stress';

  @override
  String get reflStressShort => 'Stress';

  @override
  String get reflSleepHours => 'Sleep, hours';

  @override
  String get reflSleepShort => 'Sleep';

  @override
  String get reflGratitudeTitle => 'Gratitude';

  @override
  String get reflGratitudeHint => 'Write 1–3 things you’re grateful for today';

  @override
  String get reflGratitudePlaceholder => 'I\'m grateful for...';

  @override
  String get reflNotesTitle => 'Day notes';

  @override
  String get reflHighlight => 'Highlight of the day';

  @override
  String get reflBlockers => 'What got in the way';

  @override
  String get reflQuickTemplates => 'Templates';

  @override
  String get reflTplSmooth => 'The day went smoothly';

  @override
  String get reflTplLearned => 'I learned something new today';

  @override
  String get reflTplHelped => 'I helped someone';

  @override
  String get reflTplWalk => 'I went for a walk';

  @override
  String get reflTplWorkout => 'I did a workout';

  @override
  String get reflReset => 'Reset';

  @override
  String get reflCopiedFromPast => 'Filled with values from a past entry';

  @override
  String get reflAddItem => 'Add item';

  @override
  String get delete => 'Delete';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountLoading => 'Loading…';

  @override
  String get accountNotSignedIn => 'You are not signed in';

  @override
  String get signIn => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get userNoName => 'No name';

  @override
  String get userNoEmail => 'No email';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeSubtitle => 'Sign in to sync your goals and backups across devices';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authSignUpTitle => 'Sign up';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordShow => 'Show password';

  @override
  String get passwordHide => 'Hide password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signUpButton => 'Create account';

  @override
  String get toggleNoAccount => 'No account? Sign up';

  @override
  String get toggleHaveAccount => 'I already have an account';

  @override
  String loginFailed(Object error) {
    return 'Sign-in failed: $error';
  }

  @override
  String loginSuccessHello(Object name) {
    return 'Done! Hello, $name';
  }

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get resetSubtitle => 'Enter your e-mail — we will send a reset link.';

  @override
  String get sendLink => 'Send link';

  @override
  String resetEmailSent(Object email) {
    return 'Reset e-mail sent to $email';
  }

  @override
  String get verifyTitle => 'Verify your e-mail';

  @override
  String verifyDesc(Object email) {
    return 'We sent a message to $email. Open it and follow the link to verify.';
  }

  @override
  String verifyEmailSent(Object email) {
    return 'Verification e-mail sent to $email';
  }

  @override
  String get iVerified => 'I have verified';

  @override
  String get resendNow => 'Resend now';

  @override
  String resendIn(Object seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String verifyCooldown(Object seconds) {
    return 'You can resend in ${seconds}s';
  }

  @override
  String get hubTitle => 'Hub';

  @override
  String get hubSubtitle => 'Plan · Focus · Reflect';

  @override
  String get planner => 'Planner';

  @override
  String get focus => 'Focus';

  @override
  String get reflection => 'Reflection';

  @override
  String get stats => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get open => 'Open';

  @override
  String get start => 'Start';

  @override
  String get configure => 'Configure';

  @override
  String get completed => 'Completed';

  @override
  String get noTasks => 'No tasks today';

  @override
  String get minutes => 'min';

  @override
  String get breakLabel => 'Break';

  @override
  String get cycles => 'Cycles';

  @override
  String get quickSave => 'Quick save';

  @override
  String get weekProgress => '7-day progress';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get everythingAtOnce => 'Everything at one place';

  @override
  String get startFocus => 'Start focus';

  @override
  String get reflect => 'Reflect';

  @override
  String get backup => 'Backup';

  @override
  String get today => 'Today';

  @override
  String get last7d => '7d';

  @override
  String get pomoTipStart => 'Start with one full 25/5 cycle. Small win = best momentum.';

  @override
  String get pomoTipGoodPace => 'Good pace. Try 3–4 cycles in a row, then a 15–20 min long break.';

  @override
  String get pomoTipGreat => 'Great focus! Capture what worked and repeat tomorrow at the same time.';

  @override
  String get pomoTipTooManyDistr => 'Too many distractions: enable Do Not Disturb, put the phone away, work by a window.';

  @override
  String get pomoTipRaiseCompletion => 'Finish at least 2 cycles today to lift your 7-day completion rate.';

  @override
  String get pomoTipIncreaseInterval => 'High consistency! Consider increasing the focus interval to 30 minutes.';

  @override
  String get motPhrase1 => 'Small steps — big results.';

  @override
  String get motPhrase2 => 'Do what matters, not what’s urgent.';

  @override
  String get motPhrase3 => 'Progress is checkmarks, not perfection.';

  @override
  String get motPhrase4 => 'The best day to start is today.';

  @override
  String get motPhrase5 => '25 minutes of focus works wonders.';

  @override
  String get motPhrase6 => 'Rest is part of the work.';

  @override
  String get motPhrase7 => 'Do one hard thing before lunch.';

  @override
  String get motPhrase8 => 'Not all at once, but every day a little.';

  @override
  String get motPhrase9 => 'Be consistent, not perfect.';

  @override
  String get motPhrase10 => 'In doubt? Start with 10 minutes.';

  @override
  String get goalsTitle => 'Goals';

  @override
  String get goalsAdd => 'Add';

  @override
  String get goalsEmpty => 'No goals yet';

  @override
  String get goalType => 'Goal type';

  @override
  String get goalName => 'Name';

  @override
  String get photoUrlOptional => 'Photo (URL, optional)';

  @override
  String get goalSavings => 'Save money';

  @override
  String get goalHabit => 'Quit a bad habit';

  @override
  String get goalSport => 'Sport';

  @override
  String get weeklyIncome => 'Weekly income';

  @override
  String get targetAmount => 'Target amount';

  @override
  String get habitKind => 'Habit';

  @override
  String get sportKind => 'Sport kind';

  @override
  String get suggestedTasks => 'Suggested tasks';

  @override
  String get addCustomTask => 'Add your own task';

  @override
  String get createGoal => 'Create goal';

  @override
  String get ok => 'OK';

  @override
  String get add => 'Add';

  @override
  String get confirmDeleteGoal => 'Delete goal?';

  @override
  String get notFound => 'Not found';

  @override
  String get deposit => 'Deposit';

  @override
  String get depositAmount => 'Deposit amount';

  @override
  String get doneToday => 'Done today';

  @override
  String get todayChecklist => 'Today\'s checklist';

  @override
  String streakDays(Object count) {
    return 'Streak: $count days';
  }

  @override
  String goalsSavedOf(Object saved, Object target) {
    return '$saved / $target';
  }

  @override
  String recommendedWeeklyDeposit(Object sum) {
    return 'Recommended weekly deposit: $sum';
  }

  @override
  String get habitSmoking => 'Smoking';

  @override
  String get habitAlcohol => 'Alcohol';

  @override
  String get habitSugar => 'Sugar';

  @override
  String get habitJunkFood => 'Fast food';

  @override
  String get habitSocialMedia => 'Social media';

  @override
  String get habitGaming => 'Gaming';

  @override
  String get other => 'Other';

  @override
  String get sportRunning => 'Running';

  @override
  String get sportGym => 'Gym';

  @override
  String get sportYoga => 'Yoga';

  @override
  String get sportSwimming => 'Swimming';

  @override
  String get sportCycling => 'Cycling';

  @override
  String get taskNoSmoking => 'No cigarettes';

  @override
  String get taskDrinkWater => 'Drink water';

  @override
  String get taskBreathing5m => 'Breathing 5 min';

  @override
  String get taskNoAlcohol => 'No alcohol';

  @override
  String get taskWalk20m => 'Walk 20 min';

  @override
  String get taskNoSocial2h => 'No social media 2h';

  @override
  String get taskRead10p => 'Read 10 pages';

  @override
  String get taskNoSugar => 'No sugar';

  @override
  String get taskFruitInstead => 'Fruit instead of sweets';

  @override
  String get taskNoJunk => 'No junk food';

  @override
  String get taskSaladPortion => 'Salad/veggies 1 serving';

  @override
  String get taskNoGames3h => 'No games for 3h';

  @override
  String get taskSport20m => 'Any sport 20 min';

  @override
  String get taskStep1 => 'Step 1';

  @override
  String get taskStep2 => 'Step 2';

  @override
  String get taskWarmup10m => 'Warm-up 10 min';

  @override
  String get taskRun20_30m => 'Run 20–30 min';

  @override
  String get taskStretching => 'Stretching';

  @override
  String get taskWarmup => 'Warm-up';

  @override
  String get taskStrength30_40m => 'Strength 30–40 min';

  @override
  String get taskCooldown => 'Cool-down';

  @override
  String get taskYoga20_30m => 'Yoga 20–30 min';

  @override
  String get taskSwim30m => 'Swim 30 min';

  @override
  String get taskBike30_60m => 'Bike 30–60 min';

  @override
  String get taskActivity20_30m => 'Activity 20–30 min';

  @override
  String get backToSignUp => 'Back to sign up';

  @override
  String get backToSignUpHint => 'You can register again with the correct e-mail.';

  @override
  String get changeEmail => 'Change e-mail';

  @override
  String get changeEmailTitle => 'Change e-mail address';

  @override
  String get changeEmailSubtitle => 'Enter a new address and we’ll send a verification e-mail.';

  @override
  String get saveAndSend => 'Save & send';

  @override
  String changeEmailSent(Object email) {
    return 'Verification e-mail sent to $email';
  }

  @override
  String get reloginToChangeEmail => 'Recent sign-in required to change e-mail. Please sign in again.';

  @override
  String get stage1Title => 'Preparation';

  @override
  String get stage2Title => 'Stabilization';

  @override
  String get stage3Title => 'Consolidation';

  @override
  String stageProgress(Object current, Object total) {
    return 'Stage $current of $total';
  }

  @override
  String dayOf(Object day, Object total) {
    return 'Day $day of $total';
  }

  @override
  String get didYouQuit => 'Did you quit?';

  @override
  String get didYouQuitDesc => 'If not, we will continue to the next stage.';

  @override
  String get iQuit => 'Yes, I quit';

  @override
  String get continueRoad => 'Not yet, continue';

  @override
  String get statusQuit => 'Status: quit';

  @override
  String get coachRefresh => 'Refresh';

  @override
  String get coachNoData => 'Not enough data yet — keep going!';

  @override
  String get completeChecklistHint => 'Tick today’s checklist — that’s how the habit sticks.';

  @override
  String get sv_tip_fill_income => 'Set your weekly income so I can suggest a deposit amount.';

  @override
  String get sv_tip_start_auto => 'Start with a tiny auto-transfer (5–10%): consistency beats size.';

  @override
  String sv_tip_small_deposit(Object amount) {
    return 'Try to deposit this week: $amount';
  }

  @override
  String get sv_tip_visualize => 'You are close — keep the goal photo handy to resist impulse spending.';

  @override
  String get hb_s1_1 => 'Remove triggers (lighters, snacks, “just in case”).';

  @override
  String get hb_s1_2 => 'Tell close ones — a social contract helps.';

  @override
  String get hb_s1_3 => 'Plan replacements (gum, tea, water) for craving moments.';

  @override
  String get hb_s2_1 => 'Plan “hard moments” in advance (after meals, breaks, evenings).';

  @override
  String get hb_s2_2 => 'Watch sleep and hydration — deficits increase cravings.';

  @override
  String get hb_s2_3 => 'Reward yourself daily — small wins matter.';

  @override
  String get hb_s3_1 => 'Rehearse relapses: what you’ll say and do when craving hits.';

  @override
  String get hb_s3_2 => 'Write down the benefits of the new life — reread during weak moments.';

  @override
  String get hb_s3_3 => 'Share your experience/help someone — it cements the habit.';

  @override
  String get hb_start_small => 'Start tiny and steady — stability first.';

  @override
  String get hb_keep_chain => 'Don’t break the chain: one day is a win.';

  @override
  String get hb_high_streak => 'Great streak! Anchor the routine (alarm, sticky note).';

  @override
  String get hb_maintain_1 => 'You did it! Keep support rituals for 2–3 more weeks.';

  @override
  String get hb_maintain_2 => 'Occasionally test yourself with “no-action triggers” — build resilience.';

  @override
  String get hb_maintain_3 => 'Plan a new goal so your freed-up time works for you.';

  @override
  String get sp_beginner_1 => 'Keep workouts short (15–20 min) — easier to stay consistent.';

  @override
  String get sp_beginner_2 => 'Prepare your gear the night before — reduce start friction.';

  @override
  String get sp_consistency_1 => 'Consistency > volume: aim for 3 sessions per week.';

  @override
  String get sp_consistency_2 => 'Use fixed days/time so you don’t negotiate with yourself.';

  @override
  String get sp_deload_1 => 'Nice long streak! Add a light deload to recover.';

  @override
  String get sp_deload_2 => 'Track heart rate/energy — don’t overdo it.';
}
