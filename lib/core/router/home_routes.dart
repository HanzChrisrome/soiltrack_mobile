import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/utils/page_transition.dart';
import 'package:soiltrack_mobile/features/chat_bot/presentation/chat_history.dart';
import 'package:soiltrack_mobile/features/chat_bot/presentation/chat_screen.dart';
import 'package:soiltrack_mobile/features/crops_registration/presentation/soil_assigning.dart';
import 'package:soiltrack_mobile/features/home/presentation/chat_bot.dart';
import 'package:soiltrack_mobile/features/home/presentation/device_screen.dart';
import 'package:soiltrack_mobile/features/home/presentation/landing_dashboard.dart';
import 'package:soiltrack_mobile/features/home/presentation/settings_screen.dart';
import 'package:soiltrack_mobile/features/home/presentation/soil_dashboard.dart';
import 'package:soiltrack_mobile/features/home/presentation/notification_screen.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/plot_analytics_screen.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/user_plots_screen.dart';

final homeRoutes = [
  GoRoute(
    path: '/home',
    name: 'home',
    builder: (context, state) => const LandingDashboard(),
    pageBuilder: (context, state) {
      return CustomTransitionPage(
        child: const LandingDashboard(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      );
    },
    routes: [
      GoRoute(
        path: '/soil-dashboard',
        name: 'soil-dashboard',
        builder: (context, state) => const SoilDashboardScreen(),
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const SoilDashboardScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
          );
        },
      ),
      GoRoute(
        path: '/device-screen',
        name: 'device-screen',
        builder: (context, state) => const DeviceScreen(),
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const DeviceScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
          );
        },
      ),
      GoRoute(
        path: '/settings-screen',
        name: 'settings-screen',
        builder: (context, state) => const SettingsScreen(),
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const SettingsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
          );
        },
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: const NotificationScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return child;
            },
          );
        },
      ),
    ],
  ),
  GoRoute(
    path: '/user-plot',
    name: 'user-plot',
    builder: (context, state) => const UserPlotScreen(),
  ),
  GoRoute(
    path: '/plot-analytics',
    name: 'plot-analytics',
    builder: (context, state) => const PlotAnalyticsScreen(),
  ),
  GoRoute(
    path: '/soil-assigning',
    name: 'soil-assigning',
    builder: (context, state) => const SoilAssigningScreen(),
  ),
  GoRoute(
    path: '/ai-chatbot',
    name: 'ai-chatbot',
    pageBuilder: (context, state) {
      return customPageTransition(
          context, transitionType: 'slide', const ChatBotScreen());
    },
  ),
  GoRoute(
    path: '/chat-screen',
    name: 'chat-screen',
    pageBuilder: (context, state) {
      return customPageTransition(
          context, transitionType: 'slide', const ChatScreen());
    },
  ),
  GoRoute(
    path: '/chat-history',
    name: 'chat-history',
    pageBuilder: (context, state) {
      return customPageTransition(
          context, transitionType: 'slide', const ChatHistoryScreen());
    },
  ),
];

final goRouter = GoRouter(
  initialLocation: '/home',
  routes: homeRoutes,
  redirect: (BuildContext context, GoRouterState state) {
    if (state.uri.toString() != '/home' &&
        !state.uri.toString().startsWith('/home')) {
      return '/home';
    }
    return null;
  },
);
