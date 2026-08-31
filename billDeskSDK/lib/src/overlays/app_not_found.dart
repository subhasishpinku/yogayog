import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformAdaptiveDialog {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required String buttonText,
    required Future<void> Function() onButtonPressed,
  }) {
    final size = MediaQuery.of(context).size;
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    // Non-transparent overlay
    final barrierColor = Colors.black.withValues(alpha: 0.7);

    if (isIOS) {
      return showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        // barrierColor: barrierColor,
        builder: (_) => CupertinoAlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Padding(
            padding: EdgeInsets.only(top: size.height * 0.01),
            child: Text(
              message,
              style: TextStyle(fontSize: size.width * 0.035),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () async {
                if (Navigator.of(context, rootNavigator: true).canPop()) {
                  Navigator.of(context, rootNavigator: true).pop();
                }
                await onButtonPressed();
              },
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Color(0xFF002D99),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: barrierColor,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            style: TextStyle(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: size.width * 0.035),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: size.width * 0.6,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002D99),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  if (Navigator.of(context, rootNavigator: true).canPop()) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                  await onButtonPressed();
                },
                child: Text(
                  buttonText,
                  style: TextStyle(
                      fontSize: size.width * 0.038,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
