import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/soil_dashboard_provider.dart';

class PlotCondition extends ConsumerWidget {
  const PlotCondition({super.key, required this.plotName});

  final String plotName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPlotId = ref.watch(soilDashboardProvider).selectedPlotId;
    final plotConditions = ref.watch(soilDashboardProvider).plotConditions;
    final lastRead = ref.watch(soilDashboardProvider).lastReadingTime;

    final condition = plotConditions[selectedPlotId] ?? 'No data available';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Update:',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                lastRead != null
                    ? 'As of ${DateFormat('MMMM d, yyyy').format(lastRead)}'
                    : '', // Handle null case
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (lastRead == null)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'No data available for this selected plot.',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      height: 1.1,
                      letterSpacing: -1.0,
                      fontSize: 28,
                    ),
                textAlign: TextAlign.start,
              ),
            ),
          if (lastRead != null)
            RichText(
              text: TextSpan(
                text: '$plotName condition are ', // Normal text
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      height: 1.1,
                      letterSpacing: -1.0,
                      fontSize: 28,
                    ),
                children: [
                  TextSpan(
                    text: condition,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  TextSpan(
                    text: '.',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
