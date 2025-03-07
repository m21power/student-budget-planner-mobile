import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hackathon_mobile/core/routes/route.dart';
import 'package:hackathon_mobile/dependency_injection.dart';
import 'package:hackathon_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:hackathon_mobile/features/auth/presentation/pages/regiser_page.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initNotifications();
  await init();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      // overrideMode: AdaptiveThemeMode.dark,
      builder: (theme, darkTheme) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => sl<AuthBloc>()..add(IsLoggedInEvent()),
          )
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme,
          title: 'Student Budget Planner',
          routerConfig: router,
        ),
        // child: MaterialApp(
        //   title: 'Adaptive Theme Demo',
        //   theme: theme,
        //   darkTheme: darkTheme,
        //   debugShowCheckedModeBanner: false,
        //   home: SignInPage(),
        // ),
      ),

      debugShowFloatingThemeButton: true,
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaptive Theme Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'This is a sample app to demonstrate the usage of adaptive theme.',
              ),
              const Text(
                'You can switch between light and dark theme using the switch below.',
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Light'),
                  const SizedBox(width: 10),
                  Switch(
                    value: AdaptiveTheme.of(context).mode.isDark,
                    onChanged: (value) {
                      if (value) {
                        AdaptiveTheme.of(context).setDark();
                      } else {
                        AdaptiveTheme.of(context).setLight();
                      }
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text('Dark'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
