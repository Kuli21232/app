import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/update_manifest.dart';

enum UpdateSeverity { none, soft, hard }

class UpdateDecision {
  final UpdateSeverity severity;
  final String url;
  final String? changelog;
  final int? latestBuild;
  UpdateDecision({
    required this.severity,
    required this.url,
    this.changelog,
    this.latestBuild,
  });
}

class UpdateService {
  UpdateService({required this.manifestUrl});
  final String manifestUrl; // URL до вашего JSON с версиями

  Future<UpdateDecision?> check() async {
    final platformKey = _platformKey();
    if (platformKey == null) return null;

    final pkg = await PackageInfo.fromPlatform();
    final currentBuild = int.tryParse(pkg.buildNumber) ?? 0;

    final resp =
        await http.get(Uri.parse(manifestUrl)).timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) return null;

    final manifest = UpdateManifest.parse(resp.body);
    final channel = switch (platformKey) {
      'android' => manifest.android,
      'windows' => manifest.windows,
      _ => null,
    };
    if (channel == null) return null;

    final latest = channel.latestBuild;
    final min = channel.minSupportedBuild;

    if (currentBuild < min) {
      return UpdateDecision(
        severity: UpdateSeverity.hard,
        url: channel.url,
        changelog: channel.changelog,
        latestBuild: latest,
      );
    } else if (currentBuild < latest) {
      return UpdateDecision(
        severity: UpdateSeverity.soft,
        url: channel.url,
        changelog: channel.changelog,
        latestBuild: latest,
      );
    }
    return null;
  }

  Future<void> launchUpdate(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) throw 'Не удалось открыть $url';
  }

  String? _platformKey() {
    if (kIsWeb) return null;
    if (Platform.isAndroid) return 'android';
    if (Platform.isWindows) return 'windows';
    return null; // для iOS/других сейчас не поддерживаем
  }
}

// === Riverpod provider ===
// !!! ВАЖНО: замените ссылку на свою (см. раздел 6 ниже)
final updateServiceProvider = Provider<UpdateService>((ref) {
  const manifestUrl = 'https://motiva-app-ru.web.app/updates/manifest.json';
  return UpdateService(manifestUrl: manifestUrl);
});
