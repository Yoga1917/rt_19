import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rt_19/app/splash_screen.dart';

void main() async {
  Intl.defaultLocale = 'id_ID';
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: [Locale('id', 'ID')],
      locale: Locale('id', 'ID'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Sistem Rt 19',
      home: SplashScreen(),
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Color(0xff30C083),
          cursorColor: Color(0xff30C083),
          selectionHandleColor: Color(0xff30C083),
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          titleTextStyle: TextStyle(color: Color(0xff30C083)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xff30C083),
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xff30C083),
          textTheme: ButtonTextTheme.primary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xff30C083)),
          ),
        ),
      ),
    );
  }
}
