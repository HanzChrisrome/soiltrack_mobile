import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:toastification/toastification.dart';

class NotifierHelper {
  static void logError(dynamic error,
      [BuildContext? context, String? message]) {
    final errorMessage = error.toString();
    debugPrint('Error: $errorMessage');

    if (context != null && message != null) {
      showErrorToast(context, message);
    }
  }

  static void showLoadingToast(BuildContext context, String message) {
    ToastService.showLoadingToast(context, message: message);
  }

  static void showSuccessToast(BuildContext context, String message) {
    ToastService.dismissLoadingToast(
        context, message, ToastificationType.success);
  }

  static void showErrorToast(BuildContext context, String message,
      {String? description}) {
    ToastService.dismissLoadingToast(
      context,
      message,
      description: description,
      ToastificationType.error,
    );
  }

  static void logMessage(String message) {
    if (kDebugMode) debugPrint(message);
  }
}
