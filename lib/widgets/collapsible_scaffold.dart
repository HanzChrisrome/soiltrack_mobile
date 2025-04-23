import 'package:flutter/material.dart';

typedef HeaderBuilder = Widget Function(BuildContext context, bool isCollapsed);

class CollapsibleSliverScaffold extends StatefulWidget {
  final HeaderBuilder headerBuilder;
  final List<Widget> bodySlivers;
  final double expandedHeight;
  final Color backgroundColor;

  const CollapsibleSliverScaffold({
    Key? key,
    required this.headerBuilder,
    required this.bodySlivers,
    this.expandedHeight = 200.0,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  State<CollapsibleSliverScaffold> createState() =>
      _CollapsibleSliverScaffoldState();
}

class _CollapsibleSliverScaffoldState extends State<CollapsibleSliverScaffold> {
  bool isCollapsed = false;

  void _handleScroll(double offset) {
    bool shouldCollapse = offset > widget.expandedHeight - kToolbarHeight;
    if (shouldCollapse != isCollapsed) {
      setState(() {
        isCollapsed = shouldCollapse;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.axis == Axis.vertical) {
          _handleScroll(scrollNotification.metrics.pixels);
        }
        return true;
      },
      child: CustomScrollView(
        slivers: [
          widget.headerBuilder(context, isCollapsed),
          ...widget.bodySlivers,
        ],
      ),
    );
  }
}
