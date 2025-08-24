// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class UnassignedSensor extends ConsumerWidget {
  const UnassignedSensor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DynamicContainer(
      width: double.infinity,
      backgroundColor: Colors.red.withOpacity(0.2),
      borderColor: Colors.red.withOpacity(0.6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
