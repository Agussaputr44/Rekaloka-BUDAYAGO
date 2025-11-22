import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Colors ---
const Color kPrimaryBrown = Color(0xFF5C3317);
const Color kAccentOrange = Color(0xFFD36A3C);
const Color kTextWhite = Color(0xFFFFFFFF);
const Color kTextBlack = Color.fromARGB(255, 0, 0, 0);
const Color kInputBackground = Color(0xFFF7F7F7);
const Color kInputIconColor = Color(0xFF946E56);
const Color kSecondaryBrown = Color(0xFF8B4513);
const Color kScaffoldBackground = Color.fromARGB(255, 255, 255, 255);
const Color kInputFillColor = Color(0xFFE2B79A);

// --- Text Style ---
final TextStyle kHeading1 = GoogleFonts.poppins(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  color: kPrimaryBrown,
);

final TextStyle kHeading5 = GoogleFonts.poppins(
  fontSize: 23,
  fontWeight: FontWeight.w600,
  color: kPrimaryBrown,
);

final TextStyle kHeadingRekaloka = GoogleFonts.irishGrover(
  fontSize: 23,
  fontWeight: FontWeight.w600,
  color: kPrimaryBrown,
);

final TextStyle kSubtitle = GoogleFonts.poppins(
  fontSize: 15,
  fontWeight: FontWeight.w500,
  letterSpacing: 0.15,
  color: kPrimaryBrown,
);

final TextStyle kBodyText = GoogleFonts.poppins(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  letterSpacing: 0.25,
  color: kPrimaryBrown,
);

final TextStyle kButtonText = GoogleFonts.poppins(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: kTextWhite,
);

// --- Text Theme ---
final kTextTheme = TextTheme(
  headlineLarge: kHeading1,
  headlineMedium: kHeading5,
  labelLarge: kSubtitle,
  bodyMedium: kBodyText,
  labelMedium: kBodyText.copyWith(color: kInputIconColor),
  labelSmall: kBodyText.copyWith(fontSize: 11, color: kInputIconColor),
);

const kColorScheme = ColorScheme(
  primary: kAccentOrange,
  secondary: kInputIconColor,
  surface: kInputBackground,
  error: Colors.red,
  onPrimary: kTextWhite,
  onSecondary: kTextWhite,
  onSurface: kPrimaryBrown,
  onError: kTextWhite,
  brightness: Brightness.light,
);
