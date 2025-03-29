import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:radio_eurodance/core/router/routes.dart';

import '../../presentation/screens/explore_screen.dart';
import '../../presentation/screens/favorite_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/widgets/layout_scaffold.dart';


final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.homePage,
  routes: [
    StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => LayoutScaffold(
              navigationShell: navigationShell,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.homePage,
                builder: (context, state) => HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.explorePage,
                builder: (context, state) => ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.favoritesPage,
                builder: (context,state) => FavoritesScreen(),
              ),
            ],
          ),
        ]),
  ],
);
