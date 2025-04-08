import 'package:flutter/material.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';

class AccordionWidget extends StatefulWidget {
  const AccordionWidget({
    super.key,
  });

  @override
  _AccordionWidgetState createState() => _AccordionWidgetState();
}

class _AccordionWidgetState extends State<AccordionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DynamicContainer(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          backgroundColor: Colors.transparent,
          borderColor: Colors.black12,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.insights, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Summary of Findings',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.8),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Animated additional content below the DynamicContainer, if expanded
        AnimatedOpacity(
          opacity: _isExpanded
              ? 1.0
              : 0.0, // Fade-in when expanded, fade-out when collapsed
          duration: const Duration(milliseconds: 300),
          child: _isExpanded
              ? Column(
                  children: [
                    DynamicContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Findings:',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          // You can add more widgets here as needed
                        ],
                      ),
                    ),
                    DynamicContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional content goes here!',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          // You can add more widgets here as needed
                        ],
                      ),
                    ),
                  ],
                )
              : Container(),
        ),
      ],
    );
  }
}
