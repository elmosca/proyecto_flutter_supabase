// Test básico para la aplicación TFG
//
// Este test verifica que la aplicación se inicia correctamente
// y muestra la pantalla de login.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('App starts and shows login form', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Login form has correct structure', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the form structure is correct
    expect(find.byType(TextField), findsNWidgets(2)); // Email and Password fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Login button
    expect(find.byType(AppBar), findsOneWidget); // App bar
  });
} 
