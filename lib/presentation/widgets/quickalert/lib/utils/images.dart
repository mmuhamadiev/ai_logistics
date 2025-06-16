import 'package:flutter/foundation.dart';

/// Define Animation Type
class AppAnim {
  /// Loading Animation
  static const loading = kDebugMode? 'images/loading.png': 'assets/images/loading.png';

  /// Success Animation
  static const success = kDebugMode? 'images/success.png': 'assets/images/success.png';

  /// Error Animation
  static const error = kDebugMode? 'images/error.png': 'assets/images/error.png';

  /// Warning Animation
  static const warning = kDebugMode? 'images/warning.png': 'assets/images/warning.png';

  /// Info Animation
  static const info = kDebugMode? 'images/info.png': 'assets/images/info.png';

  /// Confirm Animation
  static const confirm = kDebugMode? 'images/confirm.png': 'assets/images/confirm.png';
}
