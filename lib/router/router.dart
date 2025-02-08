import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:radio_eurodance/router/routes.dart';
import 'package:radio_eurodance/screens/explore_screen.dart';
import 'package:radio_eurodance/screens/favorite_screen.dart';
import 'package:radio_eurodance/screens/home_screen.dart';
import 'package:radio_eurodance/screens/offline_screen.dart';
import 'package:radio_eurodance/screens/profile_screen.dart';

import '../layout/layout_scaffold.dart';

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
          /*StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.offlinePage,
                builder: (context,state) => OfflineScreen(),
              ),
            ],
          ),*/
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.favoritesPage,
                builder: (context,state) => FavoritesScreen(),
              ),
            ],
          ),
          /*StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profilePage,
                builder: (context,state) => ProfileScreen(),
              ),
            ],
          ),*/
        ]),
  ],
);
