import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rekaloka_app/common/constants.dart';
import 'package:rekaloka_app/common/utils.dart';
import 'package:rekaloka_app/injection.dart' as sl;
import 'package:rekaloka_app/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sl.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Brisikla App',
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
          switch (settings.name) {
            // Tambahkan rute halaman lainnya di sini
            default:
              return MaterialPageRoute(
                builder: (_) {
                  return Scaffold(
                    body: Center(child: Text('Page not found :(')),
                  );
                },
              );
          }
        },
    );
  }
}
