import 'package:flutter/material.dart';

class SoilDashboard extends StatelessWidget {
  const SoilDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
