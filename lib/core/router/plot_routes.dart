import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/user_plot_edit.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_adding.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_assigning.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_screen.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/custom_add.dart';

final plotRoutes = [
  GoRoute(
    path: '/user-plot-edit',
    name: 'user-plot-edit',
    builder: (context, state) => const UserPlotEditScreen(),
  ),
  GoRoute(
    path: '/select-category',
    name: 'select-category',
    builder: (context, state) => const CropsScreen(),
  ),
  GoRoute(
    path: '/add-crops',
    name: 'add-crops',
    builder: (context, state) => const AddingCropsScreen(),
  ),
  GoRoute(
    path: '/assign-crops',
    name: 'assign-crops',
    builder: (context, state) => const AssignCrops(),
  ),
  GoRoute(
    path: '/add-custom-crops',
    name: 'add-custom-crops',
    builder: (context, state) => const AddCustomCrop(),
  ),
];
