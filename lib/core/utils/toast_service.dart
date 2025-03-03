import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static ToastificationItem? _loadingToast;

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
              description,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
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

  static void showLoadingToast(BuildContext context,
      {required String message}) {
    dismissLoadingToastOnly();

    _loadingToast = toastification.show(
      context: context,
      showIcon: false,
      title: Row(
        children: [
          LoadingAnimationWidget.beat(color: Colors.green, size: 20),
          const SizedBox(width: 20),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 77, 77, 77),
                ),
          ),
        ],
      ),
      style: ToastificationStyle.flatColored,
      type: ToastificationType.info,
      alignment: Alignment.topCenter,
      showProgressBar: false,
      applyBlurEffect: true,
      pauseOnHover: true,
      dragToClose: false,
      closeOnClick: false,
      closeButtonShowType: CloseButtonShowType.none,
      autoCloseDuration: null,
    );
  }

  static void dismissLoadingToastOnly() {
    if (_loadingToast != null) {
      toastification.dismiss(_loadingToast!);
      _loadingToast = null;
    }
  }

  static void dismissLoadingToast(
      BuildContext context, String message, ToastificationType type,
      {String? description}) {
    dismissLoadingToastOnly();
    showToast(
        context: context,
        message: message,
        type: type,
        description: description);
  }
}
