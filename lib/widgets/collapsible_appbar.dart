import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class CollapsibleSliverAppBar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback? onBackTap;
  final String title;
  final String collapsedTitle;
  final Color backgroundColor;
  final bool showCollapsedBack;

  const CollapsibleSliverAppBar({
    Key? key,
    required this.isCollapsed,
    this.onBackTap,
    required this.title,
    required this.collapsedTitle,
    required this.backgroundColor,
    this.showCollapsedBack = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      expandedHeight: 200,
      automaticallyImplyLeading: false,
      leading: isCollapsed
          ? null
          : (onBackTap != null
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new_outlined,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: onBackTap,
                )
              : null),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        title: isCollapsed
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: GestureDetector(
                    onTap: showCollapsedBack ? onBackTap : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showCollapsedBack)
                          Icon(
                            Icons.arrow_back_ios_new,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 15,
                          ),
                        if (showCollapsedBack) const SizedBox(width: 10),
                        Text(
                          collapsedTitle,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 15,
                            letterSpacing: -1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        background: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 70),
                TextGradient(
                  text: title,
                  fontSize: 45,
                  textAlign: TextAlign.center,
                  letterSpacing: -1.8,
                  heightSpacing: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
