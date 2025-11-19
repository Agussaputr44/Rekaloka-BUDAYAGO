import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/auth/verification_page.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/provider/auth_notifier.dart';
import 'common/constants.dart';
import 'common/utils.dart';
import 'injection.dart' as sl;
import 'presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sl.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => sl.sl<AuthNotifier>())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Rekaloka App',
        theme: ThemeData.light().copyWith(
          colorScheme: kColorScheme,
          primaryColor: kPrimaryBrown,
          scaffoldBackgroundColor: kPrimaryBrown,
          textTheme: kTextTheme,
          appBarTheme: AppBarTheme(
            backgroundColor: kPrimaryBrown,
            foregroundColor: kTextWhite,
            elevation: 0,
            titleTextStyle: kHeading5.copyWith(color: kTextWhite),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentOrange,
              foregroundColor: kTextWhite,
              textStyle: kButtonText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: kInputBackground,
            hintStyle: kBodyText.copyWith(color: kInputIconColor),
            prefixIconColor: kInputIconColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: SplashScreen(),
        navigatorObservers: [routeObserver],
        onGenerateRoute: (RouteSettings settings) {
          final arguments = settings.arguments;

          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case HomePage.ROUTE_NAME:
              return MaterialPageRoute(builder: (_) => const HomePage());

            case RegisterPage.ROUTE_NAME:
              return MaterialPageRoute(builder: (_) => const RegisterPage());

            case LoginPage.ROUTE_NAME:
              return MaterialPageRoute(builder: (_) => const LoginPage());

            case VerificationPage.ROUTE_NAME:
              final email = arguments is String ? arguments : '';
              return MaterialPageRoute(
                builder: (_) => VerificationPage(email: email),
                settings: settings,
              );

            // --- Rute Default (Error 404) ---
            default:
              return MaterialPageRoute(
                builder: (_) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Error: Halaman tidak ditemukan (404)'),
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }
}
