import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';

void showCustomizableBottomSheet({
  required BuildContext context,
  required Widget centerContent,
  required String buttonText,
  required VoidCallback onPressed,
  double height = 400, // Base height of the bottom sheet
  VoidCallback? onSheetCreated,
  VoidCallback? onCancelPressed,
  bool showCancelButton = true,
  bool showActionButton = true,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the bottom sheet to move with keyboard
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 1), // No animation lag
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Container(
                height:
                    height, // Keeps base height but moves up when keyboard opens
                padding: const EdgeInsets.only(left: 30, right: 30, top: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 80,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 202, 202, 202),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Expanded(
                      child: Column(
                        children: [
                          Center(child: centerContent),
                          const SizedBox(height: 20),

                          // Conditionally show buttons
                          if (showCancelButton || showActionButton)
                            Row(
                              children: [
                                if (showCancelButton)
                                  Expanded(
                                    child: OutlineCustomButton(
                                      buttonText: 'Cancel',
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        if (onCancelPressed != null) {
                                          onCancelPressed();
                                        }
                                      },
                                    ),
                                  ),
                                if (showCancelButton && showActionButton)
                                  const SizedBox(width: 10),
                                if (showActionButton)
                                  Expanded(
                                    child: FilledCustomButton(
                                      buttonText: buttonText,
                                      onPressed: onPressed,
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
