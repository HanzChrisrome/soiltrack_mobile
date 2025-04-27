import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class CustomAccordion extends StatefulWidget {
  final String? titleText;
  final Widget? titleWidget;
  final Widget content;
  final Color? titleColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final IconData? icon;
  final bool initiallyExpanded;

  const CustomAccordion({
    super.key,
    this.titleText,
    this.titleWidget,
    required this.content,
    this.icon,
    this.titleColor,
    this.borderColor,
    this.backgroundColor,
    this.initiallyExpanded = false,
  }) : assert(titleText != null || titleWidget != null,
            'Either titleText or titleWidget must be provided.');

  @override
  State<CustomAccordion> createState() => _CustomAccordionState();
}

class _CustomAccordionState extends State<CustomAccordion>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final defaultTitleStyle = Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: widget.titleColor ?? Theme.of(context).colorScheme.secondary,
        );

    return DynamicContainer(
      backgroundColor:
          widget.backgroundColor ?? Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      borderColor: widget.borderColor ??
          Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
      margin: const EdgeInsets.only(bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.titleColor ??
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(width: 10),
                      ],
                      widget.titleWidget ??
                          Text(widget.titleText!, style: defaultTitleStyle),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const DividerWidget(verticalHeight: 1),
                      widget.content,
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
