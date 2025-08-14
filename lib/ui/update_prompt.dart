import 'package:flutter/material.dart';
import '../services/update_service.dart';

Future<void> showUpdateDialog(
  BuildContext context,
  UpdateDecision decision, {
  required VoidCallback onUpdate,
}) async {
  final isHard = decision.severity == UpdateSeverity.hard;

  return showDialog(
    context: context,
    barrierDismissible: !isHard,
    builder: (context) {
      return AlertDialog(
        title: Text(isHard ? 'Требуется обновление' : 'Доступно обновление'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((decision.changelog ?? '').trim().isNotEmpty)
              Text(decision.changelog!)
            else
              const Text('Доступна новая версия приложения.'),
          ],
        ),
        actions: [
          if (!isHard)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Позже'),
            ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onUpdate();
            },
            child: const Text('Обновить'),
          ),
        ],
      );
    },
  );
}
