import 'package:flutter/material.dart';

Future<T?> showCustomModalBottomSheet<T>({
  required BuildContext context,
  required Widget Function(
          BuildContext context, void Function(void Function()) setState)
      builder,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: builder(context, setState),
          );
        },
      );
    },
  );
}
