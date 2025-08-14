import 'dart:convert';

class UpdateChannel {
  final int latestBuild;        // рекомендованная версия (build number)
  final int minSupportedBuild;  // минимально поддерживаемая
  final String url;             // ссылка на APK/EXE
  final String? changelog;      // что нового (опционально)
  final int? snoozeHours;       // интервал "напомнить позже" (пока не используем)

  UpdateChannel({
    required this.latestBuild,
    required this.minSupportedBuild,
    required this.url,
    this.changelog,
    this.snoozeHours,
  });

  factory UpdateChannel.fromJson(Map<String, dynamic> json) => UpdateChannel(
        latestBuild: (json['latestBuild'] ?? 0) as int,
        minSupportedBuild: (json['minSupportedBuild'] ?? 0) as int,
        url: json['url'] as String,
        changelog: json['changelog'] as String?,
        snoozeHours: (json['snoozeHours'] as num?)?.toInt(),
      );
}

class UpdateManifest {
  final UpdateChannel? android;
  final UpdateChannel? windows;

  UpdateManifest({this.android, this.windows});

  factory UpdateManifest.fromJson(Map<String, dynamic> json) => UpdateManifest(
        android:
            json['android'] != null ? UpdateChannel.fromJson(json['android']) : null,
        windows:
            json['windows'] != null ? UpdateChannel.fromJson(json['windows']) : null,
      );

  static UpdateManifest parse(String body) =>
      UpdateManifest.fromJson(jsonDecode(body) as Map<String, dynamic>);
}
