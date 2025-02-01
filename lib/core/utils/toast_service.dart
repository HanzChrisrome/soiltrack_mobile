import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart'; // Import your Toastification package

class ToastService {
  static void showToast({
    required BuildContext context,
    required String message,
    String? description,
    ToastificationStyle style = ToastificationStyle.flat,
    ToastificationType type = ToastificationType.info,
    Alignment alignment = Alignment.topCenter,
    bool showProgressBar = false,
    bool applyBlurEffect = true,
    bool pauseOnHover = true,
    bool dragToClose = true,
    Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    toastification.show(
      context: context,
      title: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color.fromARGB(255, 77, 77, 77),
            ),
      ),
      description: description == null
          ? null
          : Text(
              description, // Display the description here
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Colors.black54, // Optional color for the description
                  ),
            ),
      style: style,
      type: type,
      alignment: alignment,
      showProgressBar: showProgressBar,
      applyBlurEffect: applyBlurEffect,
      pauseOnHover: pauseOnHover,
      dragToClose: dragToClose,
      autoCloseDuration: autoCloseDuration,
    );
  }
}
