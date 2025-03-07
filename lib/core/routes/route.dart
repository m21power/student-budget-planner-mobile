import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hackathon_mobile/core/constants/route_constant.dart';
import 'package:hackathon_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:hackathon_mobile/features/home/presentation/pages/bottom_nav_page.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: <RouteBase>[
    GoRoute(
        path: '/',
        name: RouteConstants.login,
        builder: (context, state) {
          // Assuming you have a BlocProvider set up in your app
          return BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              print('authState: $authState');
              if (authState is IsLoggedInSuccessState) {
                print('authState is AuthIsLoggedInSuccess');
                return BottomNavPage();
              } else if (authState is IsLoggedInFailureState) {
                return SignInPage();
              } else if (authState is AuthInitial) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                return SignInPage();
              }
            },
          );
        }),
  ],
);
