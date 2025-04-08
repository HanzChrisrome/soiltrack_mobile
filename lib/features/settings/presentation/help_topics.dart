import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/settings/presentation/widgets/accordion_widget.dart';
import 'package:soiltrack_mobile/widgets/dynamic_container.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class HelpTopics extends ConsumerWidget {
  const HelpTopics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Icon(Icons.arrow_back_ios_new_outlined,
                        color: Colors.green),
                  ),
                  onPressed: () {
                    context.go('/home?index=1');
                  },
                ),
                pinned: true,
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    TextGradient(
                      text: 'How can\nwe help you?',
                      fontSize: 45,
                      heightSpacing: 1,
                      letterSpacing: -1.8,
                    ),
                    const SizedBox(height: 15),
                    // AccordionWidget(),
                    // AccordionWidget(),
                    // AccordionWidget(),
                    // AccordionWidget(),
                  ]),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
