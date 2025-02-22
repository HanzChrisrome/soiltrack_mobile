import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/core/utils/loading_toast.dart';

class SettingsController {
  final BuildContext context;
  final WidgetRef ref;

  SettingsController(this.context, this.ref);

  Future<void> resetDevice() async {
    ToastLoadingService.showLoadingToast(context,
        message: 'Resetting device...');
  }
}
