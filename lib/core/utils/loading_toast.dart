import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:toastification/toastification.dart';

class ToastLoadingService {
  static ToastificationItem? _loadingToast;

  static void showLoadingToast(BuildContext context,
      {required String message}) {
    if (_loadingToast != null) {
      dismissLoadingToastOnly();
    }

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
      type: ToastificationType.values[2],
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
      BuildContext context, String message, ToastificationType type) {
    if (_loadingToast != null) {
      toastification.dismiss(_loadingToast!);
      _loadingToast = null;
      ToastService.showToast(context: context, message: message, type: type);
    }
  }
}
