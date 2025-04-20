import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

// Helper method to create a navigation bar item
PersistentBottomNavBarItem buildNavBarItem(IconData icon, String title) {
  return PersistentBottomNavBarItem(
    icon: Align(
      alignment: Alignment.centerRight, // Align icon to the left
      child: Icon(icon),
    ),
    title: title,
    activeColorPrimary: Colors.purple,
    inactiveColorPrimary: Colors.grey,
  );
}

// Helper method to create navigation bar animation settings
NavBarAnimationSettings buildNavBarAnimationSettings() {
  return NavBarAnimationSettings(
    navBarItemAnimation: ItemAnimationSettings(
      duration: const Duration(milliseconds: 100),
      curve: Curves.ease,
    ),
    screenTransitionAnimation: ScreenTransitionAnimationSettings(
      animateTabTransition: true,
      duration: const Duration(milliseconds: 100),
      screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
      curve: Curves.bounceOut,
    ),
  );
}

// Helper method to create navigation bar decoration
NavBarDecoration buildNavBarDecoration() {
  return NavBarDecoration(
    colorBehindNavBar: Colors.white,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        spreadRadius: 10,
        blurRadius: 10,
        offset: Offset(0, 10),
      ),
    ],
  );
}
