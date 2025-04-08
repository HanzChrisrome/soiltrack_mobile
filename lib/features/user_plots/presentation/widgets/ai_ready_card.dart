import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:soiltrack_mobile/widgets/text_rounded_enclose.dart';

class AiReadyCard extends ConsumerWidget {
  const AiReadyCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isGenerating = ref.watch(soilDashboardProvider).isGeneratingAi;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 190,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: DecorationImage(
            image: AssetImage('assets/elements/ai_ready.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextGradient(
                      text: 'AI analysis can be generated.', fontSize: 22),
                ],
              ),
              const SizedBox(height: 5),
              if (isGenerating)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2.0,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Generating Analysis',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              if (!isGenerating)
                TextRoundedEnclose(
                    text: 'Tap to generate AI analysis',
                    color: Theme.of(context).colorScheme.onPrimary,
                    textColor: Theme.of(context).colorScheme.onSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
