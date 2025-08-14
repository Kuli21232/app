// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'MotiveGo';

  @override
  String get tabPlanner => 'Планировщик';

  @override
  String get tabReflection => 'Рефлексия';

  @override
  String get tabFocus => 'Фокус';

  @override
  String get tabSettings => 'Настройки';

  @override
  String get statsTitle => 'Статистика';

  @override
  String get coachTitle => 'Подсказки';

  @override
  String get overviewTab => 'Обзор';

  @override
  String get weekTab => 'Неделя';

  @override
  String get trendTab => 'Тренд';

  @override
  String get progress7d => 'Прогресс за 7 дней';

  @override
  String doneOfPlanned(int done, int planned) {
    return 'Выполнено: $done / $planned';
  }

  @override
  String get distribution => 'Распределение';

  @override
  String get legendDone => 'Выполнено';

  @override
  String get legendRemaining => 'Осталось';

  @override
  String get kpiTotalTasks => 'Всего задач';

  @override
  String get kpiDone => 'Выполнено';

  @override
  String get kpiRemaining => 'Осталось';

  @override
  String get focusCardTitle => 'Фокус (Помодоро)';

  @override
  String get focusToday => 'Сегодня фокуса';

  @override
  String get distractions => 'Отвлечений';

  @override
  String get completion7d => 'Завершение 7д';

  @override
  String get coachTips => 'Советы';

  @override
  String get coachMotivation => 'Мотивация';

  @override
  String get focusTodayCard => 'Фокус сегодня (Помодоро)';

  @override
  String get pomo_focus => 'Фокус';

  @override
  String get pomo_break => 'Перерыв';

  @override
  String get pomo_cycles => 'Циклы';

  @override
  String get pomo_distractions => 'Отвлечения';

  @override
  String get pomo_ready => 'Готов?';

  @override
  String minutesLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мин',
      many: '$count мин',
      few: '$count мин',
      one: '$count мин',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSubtitle => 'Выберите язык приложения';

  @override
  String get languageSystem => 'Системный';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageEnglish => 'English';

  @override
  String get appearanceTitle => 'Оформление';

  @override
  String get appearanceSubtitle => 'Выберите тему приложения';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get backupTitle => 'Резервная копия';

  @override
  String get backupSubtitle => 'Сохраните все данные в файл и восстановите на другом устройстве';

  @override
  String get backupCreate => 'Создать копию';

  @override
  String get backupRestore => 'Восстановить из файла';

  @override
  String get backupClear => 'Очистить данные';

  @override
  String backupSaved(String file) {
    return 'Копия сохранена: $file';
  }

  @override
  String get backupImportOk => 'Данные восстановлены';

  @override
  String backupImportError(String details) {
    return 'Ошибка импорта: $details';
  }

  @override
  String backupCreateError(String details) {
    return 'Ошибка резервного копирования: $details';
  }

  @override
  String get clearDataConfirmTitle => 'Очистить все данные?';

  @override
  String get clearDataConfirmBody => 'Это действие удалит цели, рефлексию и настройки. Убедитесь, что у вас есть резервная копия.';

  @override
  String get cancel => 'Отмена';

  @override
  String get clear => 'Очистить';

  @override
  String get dataCleared => 'Данные очищены';

  @override
  String get reflectionTitle => 'Рефлексия';

  @override
  String get howWasDay => 'Как прошёл день?';

  @override
  String happinessIndex(int value) {
    return 'Индекс счастья: $value';
  }

  @override
  String get reflTip0_20 => 'Сложный день. Короткая прогулка и 10 минут дыхания — хороший перезапуск.';

  @override
  String get reflTip21_40 => 'Поставь 1 простую задачу на утро, чтобы поймать ритм.';

  @override
  String get reflTip41_60 => 'Серединка! Повтори то, что сработало лучше всего.';

  @override
  String get reflTip61_80 => 'Отлично! Закрепи успех: зафиксируй 1–2 привычки.';

  @override
  String get reflTip81_100 => 'Топ форма! Небольшая награда и благодарность себе.';

  @override
  String get noteLabel => 'Коротко: что получилось? что улучшить?';

  @override
  String get save => 'Сохранить';

  @override
  String get saved => 'Сохранено';

  @override
  String get lastEntries => 'Последние записи';

  @override
  String get emptyList => 'Пока пусто';

  @override
  String get moodLabel => 'Настроение';

  @override
  String get happinessShort => 'Индекс';

  @override
  String get chooseDate => 'Выбрать дату';

  @override
  String get addGoal => 'Цель';

  @override
  String get goalNameLabel => 'Название цели';

  @override
  String get priority => 'Приоритет';

  @override
  String get priorityLow => 'Низкий';

  @override
  String get priorityMedium => 'Средний';

  @override
  String get priorityHigh => 'Высокий';

  @override
  String get addButton => 'Добавить';

  @override
  String get noGoalsToday => 'Нет целей на этот день';

  @override
  String get goalCompletedDialog => 'Отлично! Цель выполнена 🎉';

  @override
  String get goalCompletedToast => 'Цель отмечена как выполненная';

  @override
  String get goalDeletedToast => 'Цель удалена';

  @override
  String get coachKpiCompletion => 'Выполнение';

  @override
  String get coachKpiStreak => 'Стрик';

  @override
  String get coachKpiBalance => 'Баланс';

  @override
  String get coachKpiTrend => 'Тренд';

  @override
  String get coachKpiHappiness => 'Индекс счастья';

  @override
  String get daysShort => 'дн.';

  @override
  String get coachPriority7dTitle => 'Приоритеты за 7 дней';

  @override
  String get coachNextStepsTitle => 'Что делать дальше';

  @override
  String get coachAdviceFrom7dNote => 'Советы рассчитаны по последним 7 дням: план/факт, записям рефлексии и фокусу (Помодоро).';

  @override
  String get trendUp => 'растёт';

  @override
  String get trendDown => 'падает';

  @override
  String get trendStable => 'стабилен';

  @override
  String get adviceLoading => 'Совет загружается…';

  @override
  String get motivationRefresh => 'Обновить фразы';

  @override
  String get coachOverloadTitleA => 'План перегружен';

  @override
  String get coachOverloadTitleB => 'Слишком много задач';

  @override
  String get coachOverloadTitleC => 'Сбавь объём';

  @override
  String get coachOverloadBodyA => 'Оставь ≤6 задач на день, остальное — в пул. Начни с P3/P2 утром.';

  @override
  String get coachOverloadBodyB => 'Сократи дневной список на 30–40%. Зафиксируй одну мини-победу в первую половину дня.';

  @override
  String get coachOverloadBodyC => 'Разгрузи неделю: перенеси часть задач на свободные слоты и собери «пачки» из P1.';

  @override
  String get coachLowCompletionTitle => 'Низкая завершённость';

  @override
  String get coachLowCompletionBody => 'Планируй 70–80% времени, остальное — буфер. Ставь одну лёгкую задачу для разгона.';

  @override
  String get coachMidCompletionTitle => 'Есть прогресс — нужен буфер';

  @override
  String get coachMidCompletionBody => 'Планируй 70–80% и оставляй место для непредвиденного. Держи одну лёгкую задачу в запасе.';

  @override
  String get coachGreatPaceTitle => 'Отличный ритм';

  @override
  String get coachGreatPaceBody => 'Повышай сложность дозированно: одна P3 в день или новая полезная привычка (10–15 минут).';

  @override
  String get coachWeakP3Title => 'Слабое закрытие P3';

  @override
  String get coachWeakP3Body => 'Перенеси одну P3 на утро и разрежь её на 2–3 подзадачи. Финишируй подзадачу, а не всю гору.';

  @override
  String get coachNoP3Title => 'Нет «тяжёлых» задач';

  @override
  String get coachNoP3Body => 'Добавь одну амбициозную P3 на неделю — она задаёт вектор и мотивирует.';

  @override
  String get coachP1StuckTitle => 'Лёгкие задачи буксуют';

  @override
  String get coachP1StuckBody => 'Сгруппируй P1 в 20-минутный слот «разгребание» после обеда. Один таймер — выше темп.';

  @override
  String get coachPrioritySkewTitle => 'Перекос по приоритетам';

  @override
  String get coachPrioritySkewBody => 'Сверь долю P3/P2/P1 в плане и факте. P3 — раньше суток, P1 — пачкой позже.';

  @override
  String get coachGoodBalanceTitle => 'Хороший баланс';

  @override
  String get coachGoodBalanceBody => 'Сохрани распределение приоритетов и повтори удачные временные слоты.';

  @override
  String get coachTrendDownTitle => 'Тренд вниз';

  @override
  String get coachTrendDownBody => 'Сделай перезагрузку: один день с облегчённым планом. Затем — постепенное наращивание.';

  @override
  String get coachTrendUpTitle => 'Тренд вверх';

  @override
  String get coachTrendUpBody => 'Зафиксируй, что сработало (время/место/тип задачи) и повтори завтра.';

  @override
  String get coachCareTitle => 'Забота о ресурсе';

  @override
  String get coachCareBody => 'Ежедневно: вода, 10-мин прогулка, дыхание 4-7-8. Это «смазка» для продуктивности.';

  @override
  String get coachUsePeakTitle => 'Используй подъём';

  @override
  String get coachUsePeakBody => 'Запланируй P3 в пик энергии и убери отвлечения (телефон в другой комнате на 45 минут).';

  @override
  String coachStreakTitle(int days) {
    return 'Серия успехов: $days дн.';
  }

  @override
  String get coachStreakBody => 'Отметь, что держит ритм, и не ломай цепочку завтра — хотя бы одна маленькая победа.';

  @override
  String get coachNeedStartTitle => 'Нужен старт';

  @override
  String get coachNeedStartBody => 'Начни с 10-минутной задачи. Запусти движение — дальше легче.';

  @override
  String get coachSummary7d => 'Сводка за 7 дней';

  @override
  String get reflDailyMetrics => 'Ежедневные метрики';

  @override
  String get reflEnergy => 'Энергия';

  @override
  String get reflEnergyShort => 'Энергия';

  @override
  String get reflStress => 'Стресс';

  @override
  String get reflStressShort => 'Стресс';

  @override
  String get reflSleepHours => 'Сон, часов';

  @override
  String get reflSleepShort => 'Сон';

  @override
  String get reflGratitudeTitle => 'Благодарности';

  @override
  String get reflGratitudeHint => 'Запиши 1–3 вещи, за которые благодарен сегодня';

  @override
  String get reflGratitudePlaceholder => 'Я благодарен за...';

  @override
  String get reflNotesTitle => 'Заметки дня';

  @override
  String get reflHighlight => 'Главный момент дня';

  @override
  String get reflBlockers => 'Что мешало';

  @override
  String get reflQuickTemplates => 'Шаблоны';

  @override
  String get reflTplSmooth => 'День прошёл спокойно';

  @override
  String get reflTplLearned => 'Сегодня узнал(а) новое';

  @override
  String get reflTplHelped => 'Кому-то помог(ла)';

  @override
  String get reflTplWalk => 'Сделал(а) прогулку';

  @override
  String get reflTplWorkout => 'Сделал(а) тренировку';

  @override
  String get reflReset => 'Сбросить';

  @override
  String get reflCopiedFromPast => 'Подставили значения из прошлой записи';

  @override
  String get reflAddItem => 'Добавить пункт';

  @override
  String get delete => 'Удалить';

  @override
  String get accountTitle => 'Аккаунт';

  @override
  String get accountLoading => 'Загрузка…';

  @override
  String get accountNotSignedIn => 'Вы не вошли в аккаунт';

  @override
  String get signIn => 'Войти';

  @override
  String get signOut => 'Выйти';

  @override
  String get userNoName => 'Без имени';

  @override
  String get userNoEmail => 'Без e-mail';

  @override
  String get welcomeTitle => 'Добро пожаловать';

  @override
  String get welcomeSubtitle => 'Войдите, чтобы синхронизировать цели и резервные копии между устройствами';

  @override
  String get authSignInTitle => 'Вход';

  @override
  String get authSignUpTitle => 'Регистрация';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get passwordShow => 'Показать пароль';

  @override
  String get passwordHide => 'Скрыть пароль';

  @override
  String get signInButton => 'Войти';

  @override
  String get signUpButton => 'Создать аккаунт';

  @override
  String get toggleNoAccount => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get toggleHaveAccount => 'У меня уже есть аккаунт';

  @override
  String loginFailed(Object error) {
    return 'Не удалось войти: $error';
  }

  @override
  String loginSuccessHello(Object name) {
    return 'Готово! Привет, $name';
  }

  @override
  String get passwordsDontMatch => 'Пароли не совпадают';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get resetTitle => 'Reset password';

  @override
  String get resetSubtitle => 'Укажите e-mail — отправим письмо со ссылкой на сброс пароля.';

  @override
  String get sendLink => 'Отправить ссылку';

  @override
  String resetEmailSent(Object email) {
    return 'Письмо для сброса отправлено на $email';
  }

  @override
  String get verifyTitle => 'Подтвердите e-mail';

  @override
  String verifyDesc(Object email) {
    return 'Мы отправили письмо на $email. Откройте его и перейдите по ссылке для подтверждения.';
  }

  @override
  String verifyEmailSent(Object email) {
    return 'Письмо отправлено на $email';
  }

  @override
  String get iVerified => 'Я подтвердил(а)';

  @override
  String get resendNow => 'Отправить ещё раз';

  @override
  String resendIn(Object seconds) {
    return 'Отправить через $seconds c';
  }

  @override
  String get confirmPasswordLabel => 'Подтвердите пароль';

  @override
  String verifyCooldown(Object seconds) {
    return 'Повторная отправка будет доступна через $seconds c';
  }

  @override
  String get hubTitle => 'Хаб';

  @override
  String get hubSubtitle => 'Планируй · Фокусируйся · Рефлексируй';

  @override
  String get planner => 'Планировщик';

  @override
  String get focus => 'Фокус';

  @override
  String get reflection => 'Рефлексия';

  @override
  String get stats => 'Статистика';

  @override
  String get settings => 'Настройки';

  @override
  String get open => 'Открыть';

  @override
  String get start => 'Старт';

  @override
  String get configure => 'Настроить';

  @override
  String get completed => 'Выполнено';

  @override
  String get noTasks => 'Сегодня целей нет';

  @override
  String get minutes => 'мин';

  @override
  String get breakLabel => 'Перерыв';

  @override
  String get cycles => 'Циклы';

  @override
  String get quickSave => 'Быстро сохранить';

  @override
  String get weekProgress => 'Прогресс за 7 дней';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get everythingAtOnce => 'Всё в одном месте';

  @override
  String get startFocus => 'Старт фокуса';

  @override
  String get reflect => 'Рефлексия';

  @override
  String get backup => 'Резервная копия';

  @override
  String get today => 'Сегодня';

  @override
  String get last7d => '7д';

  @override
  String get pomoTipStart => 'Начни с одного полного цикла 25/5. Маленькая победа = импульс.';

  @override
  String get pomoTipGoodPace => 'Хороший темп. Сделай 3–4 цикла подряд, затем длинный перерыв 15–20 мин.';

  @override
  String get pomoTipGreat => 'Отличная концентрация! Зафиксируй, что сработало, и повтори завтра в то же время.';

  @override
  String get pomoTipTooManyDistr => 'Слишком много отвлечений: включи «Не беспокоить», убери телефон, сядь у окна.';

  @override
  String get pomoTipRaiseCompletion => 'Доведи сегодня хотя бы 2 цикла до конца — это поднимет 7-дневную метрику.';

  @override
  String get pomoTipIncreaseInterval => 'Высокая стабильность! Попробуй увеличить фокус-интервал до 30 минут.';

  @override
  String get motPhrase1 => 'Малые шаги — большие результаты.';

  @override
  String get motPhrase2 => 'Делай важное, а не срочное.';

  @override
  String get motPhrase3 => 'Прогресс — это галочки, а не идеал.';

  @override
  String get motPhrase4 => 'Лучший день начать — сегодня.';

  @override
  String get motPhrase5 => '25 минут фокуса творят чудеса.';

  @override
  String get motPhrase6 => 'Отдых — часть работы.';

  @override
  String get motPhrase7 => 'Сделай одно сложное до обеда.';

  @override
  String get motPhrase8 => 'Не сразу, но каждый день понемногу.';

  @override
  String get motPhrase9 => 'Стабильность важнее совершенства.';

  @override
  String get motPhrase10 => 'Сомневаешься? Начни с 10 минут.';

  @override
  String get goalsTitle => 'Цели';

  @override
  String get goalsAdd => 'Добавить';

  @override
  String get goalsEmpty => 'Пока нет целей';

  @override
  String get goalType => 'Тип цели';

  @override
  String get goalName => 'Название';

  @override
  String get photoUrlOptional => 'Фото (URL, опционально)';

  @override
  String get goalSavings => 'Накопить';

  @override
  String get goalHabit => 'Бросить вредную привычку';

  @override
  String get goalSport => 'Спорт';

  @override
  String get weeklyIncome => 'Доход в неделю, ₽';

  @override
  String get targetAmount => 'Сколько накопить, ₽';

  @override
  String get habitKind => 'Привычка';

  @override
  String get sportKind => 'Вид спорта';

  @override
  String get suggestedTasks => 'Рекомендуемые задания';

  @override
  String get addCustomTask => 'Добавить своё задание';

  @override
  String get createGoal => 'Создать цель';

  @override
  String get ok => 'ОК';

  @override
  String get add => 'Добавить';

  @override
  String get confirmDeleteGoal => 'Удалить цель?';

  @override
  String get notFound => 'Не найдено';

  @override
  String get deposit => 'Пополнить';

  @override
  String get depositAmount => 'Сумма взноса';

  @override
  String get doneToday => 'Готово сегодня';

  @override
  String get todayChecklist => 'Чеклист на сегодня';

  @override
  String streakDays(Object count) {
    return 'Серия: $count дней';
  }

  @override
  String goalsSavedOf(Object saved, Object target) {
    return '$saved / $target';
  }

  @override
  String recommendedWeeklyDeposit(Object sum) {
    return 'Рекомендуемый взнос за неделю: $sum';
  }

  @override
  String get habitSmoking => 'Курение';

  @override
  String get habitAlcohol => 'Алкоголь';

  @override
  String get habitSugar => 'Сладкое';

  @override
  String get habitJunkFood => 'Фастфуд';

  @override
  String get habitSocialMedia => 'Соцсети';

  @override
  String get habitGaming => 'Игры';

  @override
  String get other => 'Другое';

  @override
  String get sportRunning => 'Бег';

  @override
  String get sportGym => 'Зал';

  @override
  String get sportYoga => 'Йога';

  @override
  String get sportSwimming => 'Плавание';

  @override
  String get sportCycling => 'Велосипед';

  @override
  String get taskNoSmoking => 'Без сигарет';

  @override
  String get taskDrinkWater => 'Выпить воду';

  @override
  String get taskBreathing5m => 'Дыхательная практика 5 мин';

  @override
  String get taskNoAlcohol => '0 алкоголя';

  @override
  String get taskWalk20m => 'Прогулка 20 мин';

  @override
  String get taskNoSocial2h => 'Без соцсетей 2 часа';

  @override
  String get taskRead10p => 'Книга 10 страниц';

  @override
  String get taskNoSugar => 'Без сладкого';

  @override
  String get taskFruitInstead => 'Фрукты вместо сладкого';

  @override
  String get taskNoJunk => 'Без фастфуда';

  @override
  String get taskSaladPortion => 'Салат/овощи 1 порция';

  @override
  String get taskNoGames3h => 'Без игр 3 часа';

  @override
  String get taskSport20m => 'Спорт 20 мин';

  @override
  String get taskStep1 => 'Шаг 1';

  @override
  String get taskStep2 => 'Шаг 2';

  @override
  String get taskWarmup10m => 'Разминка 10 мин';

  @override
  String get taskRun20_30m => 'Бег 20–30 мин';

  @override
  String get taskStretching => 'Растяжка';

  @override
  String get taskWarmup => 'Разминка';

  @override
  String get taskStrength30_40m => 'Силовая 30–40 мин';

  @override
  String get taskCooldown => 'Заминка';

  @override
  String get taskYoga20_30m => 'Йога 20–30 мин';

  @override
  String get taskSwim30m => 'Плавание 30 мин';

  @override
  String get taskBike30_60m => 'Велопрогулка 30–60 мин';

  @override
  String get taskActivity20_30m => 'Активность 20–30 мин';

  @override
  String get backToSignUp => 'Назад к регистрации';

  @override
  String get backToSignUpHint => 'Можешь заново зарегистрироваться с правильным e-mail.';

  @override
  String get changeEmail => 'Изменить e-mail';

  @override
  String get changeEmailTitle => 'Изменить адрес e-mail';

  @override
  String get changeEmailSubtitle => 'Введи новый адрес, мы отправим на него письмо для подтверждения.';

  @override
  String get saveAndSend => 'Сохранить и отправить';

  @override
  String changeEmailSent(Object email) {
    return 'Письмо отправлено на $email';
  }

  @override
  String get reloginToChangeEmail => 'Для изменения e-mail нужна повторная авторизация. Выйди и войди снова.';

  @override
  String get stage1Title => 'Подготовка';

  @override
  String get stage2Title => 'Стабилизация';

  @override
  String get stage3Title => 'Закрепление';

  @override
  String stageProgress(Object current, Object total) {
    return 'Этап $current из $total';
  }

  @override
  String dayOf(Object day, Object total) {
    return 'День $day из $total';
  }

  @override
  String get didYouQuit => 'Получилось бросить?';

  @override
  String get didYouQuitDesc => 'Если нет — продолжим следующий этап.';

  @override
  String get iQuit => 'Да, бросил';

  @override
  String get continueRoad => 'Пока нет, продолжить';

  @override
  String get statusQuit => 'Статус: бросил';

  @override
  String get coachRefresh => 'Обновить';

  @override
  String get coachNoData => 'Недостаточно данных для совета, продолжай!';

  @override
  String get completeChecklistHint => 'Отметь чек-лист на сегодня — так привычка закрепляется';

  @override
  String get sv_tip_fill_income => 'Укажи еженедельный доход — так будет проще рекомендовать сумму откладывания.';

  @override
  String get sv_tip_start_auto => 'Начни с маленького автоплатежа (например, 5–10% от дохода) — главное регулярность.';

  @override
  String sv_tip_small_deposit(Object amount) {
    return 'Попробуй отложить уже на этой неделе: $amount';
  }

  @override
  String get sv_tip_visualize => 'Ты близко к цели — держи фото цели под рукой, чтобы не сорваться на траты.';

  @override
  String get hb_s1_1 => 'Убери триггеры (зажигалки, снеки, «сигареты на всякий случай»).';

  @override
  String get hb_s1_2 => 'Сообщи близким о цели — социальный контракт работает.';

  @override
  String get hb_s1_3 => 'Продумай замену (жвачка, чай, вода) на моменты тяги.';

  @override
  String get hb_s2_1 => 'Планируй «трудные окна» заранее (после еды, перерывы, вечер).';

  @override
  String get hb_s2_2 => 'Следи за сном и водой — дефициты усиливают тягу.';

  @override
  String get hb_s2_3 => 'Награждай себя за каждый день — пусть это будет маленькая радость.';

  @override
  String get hb_s3_1 => 'Сделай «репетицию срывов»: что скажешь и сделаешь при тяге.';

  @override
  String get hb_s3_2 => 'Запиши выгоды новой жизни — перечитывай в моменты слабости.';

  @override
  String get hb_s3_3 => 'Поделись опытом/помоги другому — это закрепляет привычку.';

  @override
  String get hb_start_small => 'Начни с мини-целей и не гони лошадей — важна стабильность.';

  @override
  String get hb_keep_chain => 'Не рви серию: один день — это уже победа.';

  @override
  String get hb_high_streak => 'Отличная серия! Зафиксируй рутину якорями (будильник, заметка).';

  @override
  String get hb_maintain_1 => 'Ты справился! Сохраняй ритуалы поддержки ещё 2–3 недели.';

  @override
  String get hb_maintain_2 => 'Изредка проверяй себя «провокациями» (без действия) — тренируй устойчивость.';

  @override
  String get hb_maintain_3 => 'Запланируй новую цель, чтобы высвободившееся время работало на тебя.';

  @override
  String get sp_beginner_1 => 'Ставь очень короткие тренировки (15–20 мин) — легче сохранять регулярность.';

  @override
  String get sp_beginner_2 => 'Готовь форму заранее вечером — снизь трение старта.';

  @override
  String get sp_consistency_1 => 'Стабильность важнее объёма: закрой неделю 3 тренировками.';

  @override
  String get sp_consistency_2 => 'Запланируй фиксированные дни/время, чтобы не думать каждый раз.';

  @override
  String get sp_deload_1 => 'Большая серия — круто! Добавь лёгкий «делоуд» для восстановления.';

  @override
  String get sp_deload_2 => 'Следи за пульсом/самочувствием — не загоняй себя.';
}
