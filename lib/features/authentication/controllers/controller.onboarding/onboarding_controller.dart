import 'package:flutter/cupertino.dart';

class OnBoardingController {
  // Logic migrated to OnBoardingBloc. 
  // This class is no longer used but kept for historical reference during migration.
  final pageController = PageController();
  int currentIndex = 0;

  void dispose() {
    pageController.dispose();
  }
}
