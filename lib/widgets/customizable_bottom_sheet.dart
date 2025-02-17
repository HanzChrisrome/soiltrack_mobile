import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';

void showCustomizableBottomSheet({
  required BuildContext context,
  required Widget centerContent,
  required String buttonText,
  required VoidCallback onPressed,
  double height = 400,
  VoidCallback? onSheetCreated,
  bool showCancelButton = true, // Flag to show/hide Cancel button
  bool showActionButton = true, // Flag to show/hide action button
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
    ),
    builder: (context) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (onSheetCreated != null) {
          onSheetCreated(); // Call the callback after the sheet is created
        }
      });

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Container(
          height: height, // Height is now customizable
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
              const SizedBox(height: 40),

              Expanded(
                child: Column(
                  children: [
                    Center(
                      child: centerContent,
                    ),
                    const SizedBox(height: 20),

                    // Conditionally show buttons based on the flags
                    if (showCancelButton || showActionButton)
                      Row(
                        children: [
                          if (showCancelButton)
                            Expanded(
                              child: OutlineCustomButton(
                                buttonText: 'Cancel',
                                onPressed: () => Navigator.of(context).pop(),
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
      );
    },
  );
}
