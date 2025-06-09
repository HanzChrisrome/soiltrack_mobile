import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/core/utils/page_transition.dart';
import 'package:soiltrack_mobile/features/settings/presentation/ask_questions.dart';
import 'package:soiltrack_mobile/features/settings/presentation/help_topics.dart';
import 'package:soiltrack_mobile/features/settings/presentation/user_information.dart';
import 'package:soiltrack_mobile/features/user_plots/presentation/irrigation_schedule.dart';

final settingsRoutes = [
  GoRoute(
    path: '/user-information',
    name: 'user-information',
    pageBuilder: (context, state) {
      return customPageTransition(context, const UserInformation(),
          transitionType: 'slide');
    },
  ),
  GoRoute(
    path: '/help-topics',
    name: 'help-topics',
    pageBuilder: (context, state) {
      return customPageTransition(context, const HelpTopics(),
          transitionType: 'slide');
    },
  ),
  GoRoute(
    path: '/ask-question',
    name: 'ask-question',
    pageBuilder: (context, state) {
      return customPageTransition(context, const AskQuestionsScreen(),
          transitionType: 'slide');
    },
  ),
];
