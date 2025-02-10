// home_routes.dart
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/features/home/presentation/home_screen.dart';
import 'package:soiltrack_mobile/features/home/presentation/soil_dashboard.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_adding.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_assigning.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/crops_screen.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/custom_add.dart';

final homeRoutes = [
  GoRoute(
    path: '/home',
    name: 'home',
    builder: (context, state) => const HomeScreen(),
    routes: [
      GoRoute(
        path: 'crops',
        name: 'crops',
        builder: (context, state) => const CropsScreen(),
      ),
      GoRoute(
        path: 'add-crops',
        name: 'add-crops',
        builder: (context, state) => const AddingCropsScreen(),
      ),
      GoRoute(
        path: 'assign-crops',
        name: 'assign-crops',
        builder: (context, state) => const AssignCrops(),
      ),
      GoRoute(
        path: 'add-custom-crops',
        name: 'add-custom-crops',
        builder: (context, state) => const AddCustomCrop(),
      ),
      GoRoute(
        path: 'soil-dashboard',
        name: 'soil-dashboard',
        builder: (context, state) => const SoilDashboard(),
      ),
    ],
  ),
];
