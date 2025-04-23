import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomNavBar({
    required this.selectedIndex,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      height: 65,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      margin: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: screenWidth * 0.05,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(255, 153, 228, 118)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                icon: Icon(
                  [
                    Icons.home,
                    Icons.layers_rounded,
                    Icons.developer_board_rounded,
                    Icons.settings,
                  ][index],
                  size: screenWidth < 360 ? 24 : 30,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Colors.white.withOpacity(0.9),
                ),
                onPressed: () {
                  if (index == 0) {
                    context.go('/home');
                  } else if (index == 1) {
                    context.go('/home/soil-dashboard');
                  } else if (index == 2) {
                    context.go('/home/device-screen');
                  } else if (index == 3) {
                    context.go('/home/settings-screen');
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }
}
