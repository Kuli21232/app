import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/hub_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reflection_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/life_goals_screen.dart';
import 'screens/life_goal_detail_screen.dart';

import 'ui/adaptive.dart';
import 'ui/sign_in_screen.dart';
import 'ui/go_router_refresh.dart';
import 'ui/update_watcher.dart';

import 'services/sync_service.dart';
import 'l10n/app_localizations.dart';

final _auth = FirebaseAuth.instance;

/// Роутер: корень — Хаб
final _router = GoRouter(
  refreshListenable: GoRouterRefreshStream(_auth.authStateChanges()),
  redirect: (context, state) {
    final user = _auth.currentUser;
    final loggedIn = user != null;
    final goingToLogin = state.matchedLocation == '/sign-in';
    final goingToVerify = state.matchedLocation == '/verify-email';

    final needsEmailVerify = loggedIn &&
        user!.providerData.any((p) => p.providerId == 'password') &&
        !(user.emailVerified);

    if (!loggedIn) return goingToLogin ? null : '/sign-in';
    if (needsEmailVerify && !goingToVerify) return '/verify-email';
    if (!needsEmailVerify && goingToVerify) return '/';
    if (loggedIn && goingToLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
    GoRoute(path: '/verify-email', builder: (_, __) => const VerifyEmailScreen()),
    // Хаб — главный экран
    GoRoute(path: '/', builder: (_, __) => const HubScreen()),
    // Остальные экраны
    GoRoute(path: '/planner', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/reflect', builder: (_, __) => const ReflectionScreen()),
    GoRoute(path: '/focus', builder: (_, __) => const PomodoroScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
    GoRoute(path: '/coach', builder: (_, __) => const CoachScreen()),
    GoRoute(path: '/goals', builder: (_, __) => const LifeGoalsScreen()),
    GoRoute(
      path: '/goals/:id',
      builder: (_, state) => LifeGoalDetailScreen(
        id: state.pathParameters['id']!,
      ),
    ),
  ],
);

class MotiveApp extends ConsumerWidget {
  const MotiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // облачная синхронизация
    ref.watch(syncServiceProvider);

    const seed = Color(0xFF6C5CE7);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const AppScrollBehavior(),
      themeMode: ref.watch(themeModeProvider),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      locale: ref.watch(localeProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
      // ⬇️ ПОДКЛЮЧЕН контроль обновлений
      builder: (context, child) => UpdateWatcher(child: child ?? const SizedBox()),
    );
  }
}

/// ===== Экран подтверждения e-mail (смена e-mail + выход) =====
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _sending = false;
  bool _checking = false;
  bool _changing = false;

  final _newEmail = TextEditingController();

  @override
  void dispose() {
    _newEmail.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    setState(() => _sending = true);
    try {
      await u.sendEmailVerification();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Письмо отправлено ещё раз')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _iVerified() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    setState(() => _checking = true);
    try {
      await u.reload();
      final verified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      if (!mounted) return;
      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail подтверждён')),
        );
        if (mounted) context.go('/');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('E-mail ещё не подтверждён')),
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _signOutToFixEmail() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    context.go('/sign-in');
  }

  Future<void> _changeEmail() async {
    final u = FirebaseAuth.instance.currentUser;
    final newEmail = _newEmail.text.trim();
    if (u == null || newEmail.isEmpty || !newEmail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректный e-mail')),
      );
      return;
    }

    setState(() => _changing = true);
    try {
      await u.verifyBeforeUpdateEmail(newEmail);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Письмо для подтверждения отправлено на $newEmail')),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final pwd = await _askPassword(context, currentEmail: u.email ?? '');
        if (pwd == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Изменение отменено')),
            );
          }
          return;
        }
        try {
          final cred = EmailAuthProvider.credential(
            email: u.email ?? '',
            password: pwd,
          );
          await u.reauthenticateWithCredential(cred);
          await u.verifyBeforeUpdateEmail(newEmail);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Письмо для подтверждения отправлено на $newEmail')),
          );
        } on FirebaseAuthException catch (e2) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось сменить e-mail: ${e2.message ?? e2.code}')),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.message ?? e.code}')),
        );
      }
    } finally {
      if (mounted) setState(() => _changing = false);
    }
  }

  Future<String?> _askPassword(BuildContext context, {required String currentEmail}) async {
    final ctrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? result;

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Подтверждение личности'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Чтобы сменить e-mail «$currentEmail», введите пароль.'),
              const SizedBox(height: 12),
              TextFormField(
                controller: ctrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Пароль',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Введите пароль' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                result = ctrl.text;
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Подтверждение e-mail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              'Мы отправили письмо со ссылкой на ${user?.email ?? 'ваш e-mail'}. '
              'Перейдите по ссылке, затем нажмите «Я подтвердил».',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _sending ? null : _resend,
              child: _sending
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Отправить письмо ещё раз'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _checking ? null : _iVerified,
              child: _checking
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Я подтвердил'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Text('Указали неверный e-mail?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _newEmail,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Новый e-mail',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: _changing ? null : _changeEmail,
              child: _changing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Сменить e-mail и выслать письмо'),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _signOutToFixEmail,
              icon: const Icon(Icons.logout),
              label: const Text('Выйти и ввести другой e-mail'),
            ),
            const SizedBox(height: 12),
            Text(
              'Если письма нет — проверьте «Спам». При смене e-mail иногда требуется повторный вход: '
              'мы попросим пароль для подтверждения.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
