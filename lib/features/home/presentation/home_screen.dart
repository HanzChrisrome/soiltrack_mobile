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
    Icons.home,
    Icons.layers_rounded,
    Icons.chat_bubble_outline_rounded,
    Icons.developer_board_rounded,
    Icons.settings,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // Navigation bar widget
  Widget _navBar() {
    return Container(
      width: double.infinity,
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(navIcons.length, (index) {
          final isSelected = _selectedIndex == index;
          return Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 3), // Reduced padding
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color.fromARGB(255, 153, 228, 118)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              icon: Icon(
                navIcons[index],
                size: 30,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Colors.white.withOpacity(0.9),
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          );
        }),
      ),
    );
  }

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
