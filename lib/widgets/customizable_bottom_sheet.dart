import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';

void showCustomizableBottomSheet({
  required BuildContext context,
  required Widget centerContent,
  required String buttonText,
  required void Function(BuildContext bottomSheetContext) onPressed,
  double height = 400,
  void Function(BuildContext bottomSheetContext)? onCancelPressed,
  bool showCancelButton = true,
  bool showActionButton = true,
  bool enableDrag = true,
  bool isDismissible = true,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
    ),
    builder: (bottomSheetContext) {
      // <-- Note: bottomSheetContext!
      return StatefulBuilder(
        builder: (context, setState) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 1),
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              height: height,
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
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(child: centerContent),
                        const SizedBox(height: 20),
                        if (showCancelButton || showActionButton)
                          Row(
                            children: [
                              if (showCancelButton)
                                Expanded(
                                  child: OutlineCustomButton(
                                    buttonText: 'Cancel',
                                    onPressed: () {
                                      if (onCancelPressed != null) {
                                        onCancelPressed(bottomSheetContext);
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
                                    onPressed: () {
                                      onPressed(bottomSheetContext);
                                    },
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
    },
  );
}
