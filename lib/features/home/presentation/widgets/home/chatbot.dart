import 'package:flutter/material.dart';

class ChatbotCard extends StatelessWidget {
  const ChatbotCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 100,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            width: 1,
          ),
          image: const DecorationImage(
            image: AssetImage('assets/elements/ai_chatbot.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // DynamicContainer(
              //   backgroundColor: Theme.of(context).colorScheme.primary,
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              //   margin: const EdgeInsets.only(bottom: 5),
              //   borderRadius: 20,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         'Chat with out SoilTrack AI Bot',
              //         style: Theme.of(context).textTheme.titleSmall!.copyWith(
              //               fontSize: 15,
              //               color: Theme.of(context).colorScheme.secondary,
              //             ),
              //         textAlign: TextAlign.center,
              //       ),
              //       const SizedBox(width: 10),
              //       Icon(
              //         Icons.play_circle_fill,
              //         color: Theme.of(context).colorScheme.onPrimary,
              //         size: 24,
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
