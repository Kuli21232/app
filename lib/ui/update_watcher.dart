import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/update_service.dart';
import 'update_prompt.dart';

class UpdateWatcher extends ConsumerStatefulWidget {
  const UpdateWatcher({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<UpdateWatcher> createState() => _UpdateWatcherState();
}

class _UpdateWatcherState extends ConsumerState<UpdateWatcher>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _check();
    }
  }

  Future<void> _check() async {
    final service = ref.read(updateServiceProvider);
    final decision = await service.check();
    if (!mounted || decision == null) return;

    await showUpdateDialog(
      context,
      decision,
      onUpdate: () async {
        await service.launchUpdate(decision.url);
      },
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
