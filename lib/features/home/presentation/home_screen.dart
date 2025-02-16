import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soiltrack_mobile/features/home/presentation/landing_dashboard.dart';
import 'package:soiltrack_mobile/features/home/presentation/settings_screen.dart';
import 'package:soiltrack_mobile/features/home/presentation/soil_dashboard.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<IconData> navIcons = [
    Icons.dashboard_customize_outlined,
    Icons.grass,
    Icons.cloud,
    Icons.settings,
  ];

  final List<String> navTitle = [
    'Home',
    'Soil',
    'Weather',
    'Settings',
  ];

  Widget _navBar() {
    return Container(
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 32, 32, 32),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color.fromARGB(255, 117, 117, 117), // Add border color
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navIcons.length, (index) {
          final isSelected = _selectedIndex == index;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              icon: Icon(
                navIcons[index],
                size: 25,
                color: isSelected
                    ? const Color.fromARGB(255, 82, 230, 87)
                    : Colors.white.withOpacity(0.6),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Builder(
            builder: (context) {
              switch (_selectedIndex) {
                case 0:
                  return const LandingDashboard();
                case 1:
                  return const SoilDashboard();
                case 3:
                  return const SettingsScreen();
                default:
                  return const LandingDashboard();
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _navBar(),
          ),
        ],
      ),
    );
  }
}
