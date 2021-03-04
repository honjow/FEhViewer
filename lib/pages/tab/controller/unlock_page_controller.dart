import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/route/app_pages.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

class UnlockPageController extends GetxController {
  final _infoText = ''.obs;
  get infoText => _infoText.value;
  set infoText(val) => _infoText.value = val;

  Future<bool> _unlock({BuildContext context}) async {
    final IOSAuthMessages iosStrings = IOSAuthMessages(
        cancelButton: S.of(context ?? Get.context).cancel,
        goToSettingsButton: S.of(context ?? Get.context).tab_setting,
        goToSettingsDescription: 'Please set up your Touch & Face ID.',
        lockOut: 'Please reenable your Touch & Face ID');

    final AndroidAuthMessages androidStrings = AndroidAuthMessages(
      cancelButton: S.of(context ?? Get.context).cancel,
      signInTitle: '指纹认证',
      biometricHint: '',
    );

    infoText = '';
    try {
      final bool didAuthenticate = await localAuth.authenticateWithBiometrics(
        localizedReason: '验证以解锁应用',
        iOSAuthStrings: iosStrings,
        androidAuthStrings: androidStrings,
      );
      return didAuthenticate;
    } on PlatformException catch (e, stack) {
      logger.e('$e\n$stack');
      switch (e.code) {
        case auth_error.notAvailable:
        default:
          infoText = e.message;
          break;
      }
      rethrow;
    }
  }

  Future<void> unlockAndback({BuildContext context}) async {
    await Future.delayed(kUnLockPageTransitionDuration);
    final didAuthenticate = await _unlock(context: context);
    if (didAuthenticate) {
      Get.back(result: didAuthenticate);
    }
  }
}
