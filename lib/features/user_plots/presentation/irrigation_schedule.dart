import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:soiltrack_mobile/features/home/provider/soil_dashboard/plots_provider/soil_dashboard_provider.dart';
import 'package:soiltrack_mobile/features/user_plots/controller/user_plot_controller.dart';
import 'package:soiltrack_mobile/features/user_plots/helper/user_plots_helper.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/polygon_map.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/widgets/crop_threshold.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';

class IrrigationScheduleScreen extends ConsumerStatefulWidget {
  const IrrigationScheduleScreen({super.key});

  @override
  _IrrigationScheduleScreenState createState() =>
      _IrrigationScheduleScreenState();
}

class _IrrigationScheduleScreenState
    extends ConsumerState<IrrigationScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    final plotHelper = UserPlotsHelper();
    final userPlot = ref.watch(soilDashboardProvider);
    final userPlotNotifier = ref.read(soilDashboardProvider.notifier);
    final controller =
        UserPlotController(state: userPlot, plotHelper: plotHelper);

    final selectedPlot = controller.selectedPlot;
    final plotName = controller.plotName;
    final polygonList = controller.selectedPolygon;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSilverAppBar(context, plotName, selectedPlot,
                  userPlotNotifier, polygonList),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      const SizedBox(height: 10),
                      CropThresholdWidget(plotDetails: selectedPlot),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSilverAppBar(
      BuildContext context,
      String plotName,
      Map<String, dynamic> selectedPlot,
      SoilDashboardNotifier userPlotNotifier,
      List<LatLng> polygonList) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.green),
        ),
        onPressed: () {
          context.pop();
        },
      ),
      pinned: true,
      title: Container(
        padding: const EdgeInsets.only(bottom: 5),
        child: TextGradient(
          text: plotName,
          fontSize: 20,
        ),
      ),
      expandedHeight: polygonList.isNotEmpty ? 200 : 0,
      flexibleSpace: polygonList.isNotEmpty
          ? FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PolygonMap(polygonPoints: polygonList),
                ),
              ),
            )
          : null,
    );
  }
}
