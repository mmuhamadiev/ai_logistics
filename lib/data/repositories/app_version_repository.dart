import 'package:hegelmann_order_automation/data/services/firebase_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionRepository {
  final FirebaseHelper firebaseHelper;

  AppVersionRepository(this.firebaseHelper);

  Future<bool> isAppOutdated() async {
    try {
      String? latestVersion = await firebaseHelper.getLatestVersion();
      if (latestVersion == null) return false;

      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      print('latestVersion ${latestVersion}');
      print('currentVersion ${currentVersion}');

      return currentVersion != latestVersion; // Compare versions
    } catch (e) {
      print("Error checking app version: $e");
      return false;
    }
  }
}
