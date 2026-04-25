import 'package:flutter/material.dart';

// Notifiers globaux accessibles partout
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
final langNotifier  = ValueNotifier<String>('fr');