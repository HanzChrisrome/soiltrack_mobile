// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/utils/toast_service.dart';
import 'package:soiltrack_mobile/features/device_registration/provider/device_provider.dart';
import 'package:toastification/toastification.dart';
import 'package:wifi_iot/wifi_iot.dart';

class DeviceController {
  final BuildContext context;
  final WidgetRef ref;

  DeviceController(this.context, this.ref);

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

    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      ToastService.showToast(
        context: context,
        message: 'Please enable location to proceed.',
        type: ToastificationType.error,
      );

      return;
    }

    bool isWifiEnabled = await WiFiForIoTPlugin.isEnabled();

    if (!isWifiEnabled) {
      ToastService.showToast(
        context: context,
        message: 'Please enable Wi-Fi to proceed.',
        type: ToastificationType.error,
      );
      return;
    }

    print('Navigating to wifi-scan');
    context.pushNamed('wifi-scan');
  }

  Future<void> scanForDevice() async {
    try {
      await ref.read(deviceProvider.notifier).scanForDevices();
      context.pushNamed('wifi-setup');
    } catch (e) {
      ToastService.showToast(
        context: context,
        message: e.toString(),
        type: ToastificationType.error,
      );
    }
  }

  Future<void> scanForAvailableWifi() async {
    try {
      await ref.read(deviceProvider.notifier).scanForAvailableWifi();
    } catch (e) {
      ToastService.showToast(
        context: context,
        message: e.toString(),
        type: ToastificationType.error,
      );
    }
  }

  Future<void> connectDeviceToWifi(String password) async {
    try {
      if (password.isEmpty) {
        ToastService.showToast(
          context: context,
          message: 'Please enter a password',
          type: ToastificationType.error,
        );
        return;
      }
      await ref.read(deviceProvider.notifier).connectESPToWiFi(password);
      context.pushNamed('setup-config');
    } catch (e) {
      ToastService.showToast(
        context: context,
        message: e.toString(),
        type: ToastificationType.error,
      );
    }
  }

  Future<void> saveToDatabase() async {
    final deviceState = ref.watch(deviceProvider);
    final deviceNotifier = ref.read(deviceProvider.notifier);

    if (!deviceState.isSaving && deviceState.savingError == null) {
      await deviceNotifier.saveToDatabase();
      if (!ref.read(deviceProvider).isSaving &&
          ref.read(deviceProvider).savingError == null) {
        context.pushNamed('home');
      }
    }
  }
}
