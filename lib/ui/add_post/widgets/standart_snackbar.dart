import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:y_storiers/services/constants.dart';

class StandartSnackBar {
  static void show(BuildContext context, String text, SnackBarStatus status) {
    showOverlayNotification(
      (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            width: 400,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(10),
              // boxShadow: shadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    status.icon,
                    color: status.color,
                    size: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: SelectableText(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      duration: const Duration(milliseconds: 4000),
    );
  }

  static void showAndDontRemoveUntil(BuildContext context, String text,
      SnackBarStatus status, Duration duration) {
    showOverlayNotification(
      (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            width: 400,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(10),
              // boxShadow: shadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    status.icon,
                    color: status.color,
                    size: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: SelectableText(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      duration: duration,
    );
  }
}

class InfiniteSnackBar {
  static void snackBar() {
    showOverlayNotification((context) {
      return SnackBar(
        content: SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
            width: 400,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(10),
              // boxShadow: shadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: const [
                  Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: SelectableText(
                      'Потеряно интернет соединение',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        action: SnackBarAction(label: 'Закрыть', onPressed: () {}),
      );
    });
  }
}

class SnackBarStatus {
  SnackBarStatus(
    this.icon,
    this.color,
  );

  final IconData icon;
  final Color color;

  static SnackBarStatus success() {
    return SnackBarStatus(
      Icons.done,
      Colors.white,
    );
  }

  static SnackBarStatus warning() {
    return SnackBarStatus(
      Icons.error,
      Colors.white,
    );
  }

  static SnackBarStatus message() {
    return SnackBarStatus(
      Icons.sms_rounded,
      Colors.yellow.shade800,
    );
  }

  static SnackBarStatus internetResultSuccess() {
    return SnackBarStatus(
      Icons.check_circle,
      Colors.white,
    );
  }

  static SnackBarStatus loading() {
    return SnackBarStatus(
      Icons.info,
      Colors.white,
    );
  }
}
