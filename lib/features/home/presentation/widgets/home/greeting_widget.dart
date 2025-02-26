import 'package:flutter/material.dart';

class GreetingWidget extends StatelessWidget {
  final String userName;

  const GreetingWidget({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int hour = DateTime.now().hour;
    String greeting;
    String backgroundImage;

    if (hour >= 5 && hour < 12) {
      greeting = "Good morning!";
      backgroundImage = 'assets/weather/morning.png';
    } else if (hour >= 12 && hour < 18) {
      greeting = "Good afternoon!";
      backgroundImage = 'assets/weather/afternoon.png';
    } else {
      greeting = "Good evening!";
      backgroundImage = 'assets/weather/night.png';
    }

    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: -1.5,
                height: 1,
                color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            'Welcome back, $userName!',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.white,
                ),
          ),
        ],
      ),
    );
  }
}
