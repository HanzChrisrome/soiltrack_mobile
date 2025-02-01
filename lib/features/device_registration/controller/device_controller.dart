// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:toastification/toastification.dart';

class DeviceController {
  final BuildContext context;

  DeviceController(this.context);

  Future<void> requestPermissionAndNavigate() async {
    PermissionStatus locationStatus = await Permission.location.request();

    if (!locationStatus.isGranted) {
      ToastService.showToast(
        context: context,
        message: 'Location permission is required to scan for devices',
        type: ToastificationType.error,
      );
      return;
    }

    context.go('/setup/wifi-scan');
  }
}
