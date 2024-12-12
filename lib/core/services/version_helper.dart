import 'package:package_info_plus/package_info_plus.dart';

class VersionHelper {
  PackageInfo? _packageInfo;

  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  String get appName {
    return _packageInfo?.appName ?? 'Unknown';
  }

  String get packageName {
    return _packageInfo?.packageName ?? 'Unknown';
  }

  String get version {
    return _packageInfo?.version ?? 'Unknown';
  }

  String get buildNumber {
    return _packageInfo?.buildNumber ?? 'Unknown';
  }

  String get formattedVersion {
    return 'v$version+$buildNumber';
  }

  bool get isInitialized {
    return _packageInfo != null;
  }
}
