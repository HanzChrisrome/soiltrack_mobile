import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/widgets/divider_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_header.dart';

class WarningWidget extends StatelessWidget {
  final String headerText;
  final String bodyText;

  const WarningWidget({
    super.key,
    required this.headerText,
    required this.bodyText,
  });

  @override
  Widget build(BuildContext context) {
    return DynamicContainer(
      borderColor: Colors.red.withOpacity(0.6),
      backgroundColor: Colors.red.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.withOpacity(0.8),
              ),
              SizedBox(width: 8),
              TextHeader(
                text: headerText,
                fontSize: 17,
                color: Colors.red,
                letterSpacing: -1,
              ),
              const Spacer(),
              if (headerText == 'UNASSIGNED SENSORS')
                GestureDetector(
                  onTap: () {
                    context.go('/home/device-screen');
                  },
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.red,
                  ),
                )
            ],
          ),
          DividerWidget(
            verticalHeight: 1,
            color: Colors.red,
          ),
          Text(
            bodyText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
