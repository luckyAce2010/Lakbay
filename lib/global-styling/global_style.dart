// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'colors.dart';

//For Sign-In, Sign-Up, Onboarding
//To use this font example:
//OnboardHeader('Hello, Flutter!', AppColors.accentLightGreenColor)
class OnboardHeader extends StatelessWidget {
  final String text;
  final Color colorFont;

  const OnboardHeader(this.text, this.colorFont);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 36.0,
        fontWeight: FontWeight.bold,
        color: colorFont,
      ),
    );
  }
}

//Next classes is based on application content

class HeaderText extends StatelessWidget {
  final String text;

  const HeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24.0,
        fontWeight: FontWeight.bold,

        //Imported from colors.dart, to check colors go to colors.dart file
        color: AppColors.accentBlackColor,
      ),
    );
  }
}

class SectionHeaderText extends StatelessWidget {
  final String text;

  const SectionHeaderText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
        color: AppColors.accentBlackColor,
      ),
    );
  }
}

//Normal Texts requires colors
//To use this class, example:
//NormalText('Hello, Flutter!', AppColors.accentLightGreenColor)
class NormalText extends StatelessWidget {
  final String text;
  final Color colorFont;

  const NormalText(this.text, this.colorFont);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
        color: colorFont,
      ),
    );
  }
}

class BoldNormalText extends StatelessWidget {
  final String text;
  final Color colorFont;

  const BoldNormalText(this.text, this.colorFont);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: colorFont,
      ),
    );
  }
}

//Card Titles Text requires colors
class CardTitleText extends StatelessWidget {
  final String text;
  final Color colorFont;

  const CardTitleText(this.text, this.colorFont);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: colorFont,
      ),
    );
  }
}

class ColumnsTitleText extends StatelessWidget {
  final String text;
  final Color colorFont;

  const ColumnsTitleText(this.text, this.colorFont);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16.0,
        fontWeight: FontWeight.w700,
        color: colorFont,
      ),
    );
  }
}