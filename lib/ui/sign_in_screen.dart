import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motivego/l10n/app_localizations.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _showPass = false;
  bool _showPass2 = false;
  String? _error;

  late final AnimationController _ac;

  // Для повторной отправки письма подтверждения
  DateTime? _lastVerifySent;
  final int _verifyCooldownSec = 45;

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(vsync: this, duration: const Duration(seconds: 12))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ac.dispose();
    _email.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _error = null; });

    try {
      final auth = FirebaseAuth.instance;

      if (_isLogin) {
        await auth.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text,
        );
      } else {
        // простая проверка совпадения паролей
        if (_pass.text != _pass2.text) {
          setState(() { _error = t.passwordsDontMatch; });
          return;
        }
        final cred = await auth.createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _pass.text,
        );
        // Отправим письмо подтверждения
        await cred.user?.sendEmailVerification();
        _lastVerifySent = DateTime.now();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.verifyEmailSent(cred.user?.email ?? ''))),
          );
        }
      }

      if (!mounted) return;
      final name = FirebaseAuth.instance.currentUser?.email ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.loginSuccessHello(name))),
      );
      // Закроем экран, если он был открыт модально; иначе останемся
      Navigator.of(context).maybePop();
      setState(() {}); // обновим баннер в случае неподтвержденного e-mail
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _secondsToResend() {
    if (_lastVerifySent == null) return 0;
    final diff = DateTime.now().difference(_lastVerifySent!);
    final left = _verifyCooldownSec - diff.inSeconds;
    return left > 0 ? left : 0;
  }

  Future<void> _resendVerification() async {
    final t = AppLocalizations.of(context)!;
    final left = _secondsToResend();
    if (left > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.verifyCooldown(left))),
      );
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
    _lastVerifySent = DateTime.now();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.verifyEmailSent(user.email ?? ''))),
      );
      setState(() {});
    }
  }

  Future<void> _reloadUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {});
  }

  Future<void> _showResetSheet() async {
    final t = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: _email.text.trim());
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final insets = MediaQuery.of(ctx).viewInsets;
        return Padding(
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.resetTitle, style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  t.resetSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: t.emailLabel,
                    prefixIcon: const Icon(Icons.alternate_email),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: ctrl.text.trim());
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.resetEmailSent(ctrl.text.trim()))),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(t.loginFailed(e.message ?? ''))),
                        );
                      }
                    },
                    child: Text(t.sendLink),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // NEW: Изменить e-mail прямо из баннера
  Future<void> _showChangeEmailSheet({String initial = ''}) async {
    final t = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ctrl = TextEditingController(text: initial);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final insets = MediaQuery.of(ctx).viewInsets;
        return Padding(
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.changeEmailTitle, style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  t.changeEmailSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(ctx)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: t.emailLabel,
                    prefixIcon: const Icon(Icons.alternate_email),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      final newEmail = ctrl.text.trim();
                      try {
                        // На большинстве проектов этого достаточно:
                        await user.verifyBeforeUpdateEmail(newEmail); // отправит письмо на новый e-mail
                        _lastVerifySent = DateTime.now();

                        _lastVerifySent = DateTime.now();
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(t.changeEmailSent(newEmail))),
                          );
                          setState(() {});
                        }
                      } on FirebaseAuthException catch (e) {
                        // Например, requires-recent-login
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(e.code == 'requires-recent-login'
                              ? t.reloginToChangeEmail
                              : (t.loginFailed(e.message ?? '')))),
                        );
                      }
                    },
                    child: Text(t.saveAndSend),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // NEW: «Назад к регистрации» — выходим и ставим экран в режим SignUp
  Future<void> _signOutToFixEmail() async {
    final t = AppLocalizations.of(context)!;
    try {
      await FirebaseAuth.instance.signOut();
    } finally {
      if (!mounted) return;
      setState(() {
        _isLogin = false;       // сразу открываем режим регистрации
        _error = null;
        _email.clear();
        _pass.clear();
        _pass2.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.backToSignUpHint)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final emailVerified = user?.emailVerified == true;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, c) {
            final maxW = c.maxWidth;
            final side = maxW < 360 ? 16.0 : 20.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(side, 0, side, side),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 80,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AnimatedHeader(controller: _ac),

                    const SizedBox(height: 16),
                    Text(
                      t.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.welcomeSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),

                    // Баннер неподтвержденного e-mail (показываем, если пользователь вошёл и не подтвердил)
                    if (user != null && !emailVerified)
                      _VerifyBanner(
                        email: user.email ?? '',
                        secondsLeft: _secondsToResend(),
                        onResend: _resendVerification,
                        onReload: _reloadUser,
                        onBack: _signOutToFixEmail, // NEW
                        onChangeEmail: () => _showChangeEmailSheet(
                          initial: user.email ?? '',
                        ), // NEW
                      ),

                    const SizedBox(height: 12),

                    // Карточка формы
                    Align(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: scheme.surface.withOpacity(.75),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: scheme.outlineVariant.withOpacity(.30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 28,
                                spreadRadius: -10,
                                offset: const Offset(0, 18),
                                color: scheme.primary.withOpacity(.10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Переключатель режимов
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  ChoiceChip(
                                    label: Text(t.authSignInTitle),
                                    selected: _isLogin,
                                    onSelected: _loading ? null : (v) {
                                      setState(() { _isLogin = true; _error = null; });
                                    },
                                  ),
                                  ChoiceChip(
                                    label: Text(t.authSignUpTitle),
                                    selected: !_isLogin,
                                    onSelected: _loading ? null : (v) {
                                      setState(() { _isLogin = false; _error = null; });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              TextField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: t.emailLabel,
                                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _pass,
                                obscureText: !_showPass,
                                textInputAction: _isLogin ? TextInputAction.done : TextInputAction.next,
                                onSubmitted: _isLogin ? (_) => _loading ? null : _submit() : null,
                                decoration: InputDecoration(
                                  labelText: t.passwordLabel,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    tooltip: _showPass ? t.passwordHide : t.passwordShow,
                                    icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility),
                                    onPressed: () => setState(() => _showPass = !_showPass),
                                  ),
                                ),
                              ),
                              if (!_isLogin) ...[
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _pass2,
                                  obscureText: !_showPass2,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _loading ? null : _submit(),
                                  decoration: InputDecoration(
                                    labelText: t.confirmPasswordLabel,
                                    prefixIcon: const Icon(Icons.lock_person_outlined),
                                    suffixIcon: IconButton(
                                      tooltip: _showPass2 ? t.passwordHide : t.passwordShow,
                                      icon: Icon(_showPass2 ? Icons.visibility_off : Icons.visibility),
                                      onPressed: () => setState(() => _showPass2 = !_showPass2),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 8),

                              // Ошибки
                              AnimatedCrossFade(
                                crossFadeState: _error == null
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 220),
                                firstChild: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 8),
                                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(_error ?? '',
                                          style: const TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                secondChild: const SizedBox.shrink(),
                              ),

                              // Ссылки «забыли пароль» / переключение режима
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    onPressed: _loading ? null : _showResetSheet,
                                    child: Text(t.forgotPassword),
                                  ),
                                  TextButton(
                                    onPressed: _loading ? null : () {
                                      setState(() { _isLogin = !_isLogin; _error = null; });
                                    },
                                    child: Text(_isLogin ? t.toggleNoAccount : t.toggleHaveAccount),
                                  ),
                                ],
                              ),

                              // Кнопка отправки
                              SizedBox(
                                height: 48,
                                child: FilledButton(
                                  onPressed: _loading ? null : _submit,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: _loading
                                        ? const SizedBox(
                                            key: ValueKey('p'),
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
                                            _isLogin ? t.signInButton : t.signUpButton,
                                            key: ValueKey(_isLogin),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Баннер подтверждения e-mail
class _VerifyBanner extends StatelessWidget {
  const _VerifyBanner({
    required this.email,
    required this.secondsLeft,
    required this.onResend,
    required this.onReload,
    this.onBack,         // NEW
    this.onChangeEmail,  // NEW
  });

  final String email;
  final int secondsLeft;
  final VoidCallback onResend;
  final VoidCallback onReload;
  final VoidCallback? onBack;         // NEW
  final VoidCallback? onChangeEmail;  // NEW

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withOpacity(.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withOpacity(.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.verifyTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 4),
          Text(
            t.verifyDesc(email),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // NEW: Назад к регистрации
              if (onBack != null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                  label: Text(t.backToSignUp),
                ),
              // NEW: Изменить e-mail
              if (onChangeEmail != null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onChangeEmail,
                  label: Text(t.changeEmail),
                ),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                onPressed: onReload,
                label: Text(t.iVerified),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.mark_email_unread_outlined),
                onPressed: secondsLeft > 0 ? null : onResend,
                label: Text(
                  secondsLeft > 0 ? t.resendIn(secondsLeft) : t.resendNow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Анимированный фиолетовый хэдэр, корректный и для светлой темы
class _AnimatedHeader extends StatelessWidget {
  const _AnimatedHeader({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const height = 220.0;

    return SizedBox(
      height: height,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final v = controller.value;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Градиентный фон — работает и в светлой теме
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-1 + v * .2, -1),
                    end: Alignment(1 - v * .2, 1),
                    colors: [
                      scheme.primary.withOpacity(.85),
                      scheme.secondaryContainer.withOpacity(.65),
                    ],
                  ),
                ),
              ),
              // Плавающие «пузыри»
              _bubble(Offset(36 + 18 * v, 30), 82, scheme.primaryContainer.withOpacity(.35)),
              _bubble(Offset(160 - 12 * v, 118), 62, scheme.primary.withOpacity(.25)),
              _bubble(Offset(300 - 30 * v, 44 + 10 * v), 92, scheme.secondary.withOpacity(.20)),
              // Плашка «Добро пожаловать»
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.handshake_outlined, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.welcomeTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bubble(Offset o, double size, Color color) {
    return Positioned(
      left: o.dx,
      top: o.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              spreadRadius: -8,
              color: color.withOpacity(.6),
            ),
          ],
        ),
      ),
    );
  }
}
