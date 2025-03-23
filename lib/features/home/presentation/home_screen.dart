// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/presentation/device_screen.dart';
import 'package:soiltrack_mobile/features/home/presentation/landing_dashboard.dart';
import 'package:soiltrack_mobile/features/home/presentation/settings_screen.dart';
import 'package:soiltrack_mobile/features/home/presentation/soil_dashboard.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _selectedIndex;

  // Navigation bar icons
  final List<IconData> navIcons = [
    Icons.space_dashboard,
    Icons.layers_rounded,
    Icons.electrical_services_rounded,
    Icons.settings,
  ];

  // Navigation bar titles
  final List<String> navTitle = [
    'Home',
    'Soil',
    'Devices',
    'Settings',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; // Set initial index from widget
  }

  // Navigation bar widget
  Widget _navBar() {
    return Container(
      width: 300,
      height: 65,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.onPrimary,
            const Color.fromARGB(255, 34, 121, 37)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navIcons.length, (index) {
          final isSelected = _selectedIndex == index;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 153, 228, 118)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    navIcons[index],
                    size: 23,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Colors.white.withOpacity(0.4),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = index; // Update selected index on tap
                    });
                  },
                ),
                if (isSelected)
                  Text(
                    navTitle[index],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                    ),
                  ),
                if (isSelected) const SizedBox(width: 15),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Determine which screen to display based on the selected index
  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const LandingDashboard();
      case 1:
        return const SoilDashboardScreen();
      case 2:
        return const DeviceScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const LandingDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _getSelectedScreen(),
          Align(
            alignment: Alignment.bottomCenter,
            child: _navBar(),
          ),
        ],
      ),
    );
  }
}
