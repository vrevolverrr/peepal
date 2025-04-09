import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepal/features/login_page/view/login_page.dart';

void main() {
  group('LoginPage Tests', () {
    testWidgets('should show error if email is empty', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Tap the login button without entering email or password
      final loginButton = find.text('Log In');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify error message for email
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should show error if email format is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');

      // Tap the login button
      final loginButton = find.text('Log In');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify error message for invalid email
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('should show error if password is empty', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Enter valid email but leave password empty
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      // Tap the login button
      final loginButton = find.text('Log In');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify error message for password
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show error if password is less than 6 characters', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Enter valid email and short password
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '123');

      // Tap the login button
      final loginButton = find.text('Log In');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify error message for short password
      expect(find.text('Password must be at least 6 characters long'), findsOneWidget);
    });

    testWidgets('should show success message if login is successful', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Enter valid email and password
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      // Tap the login button
      final loginButton = find.text('Log In');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify success message
      expect(find.text('Logging in...'), findsOneWidget);
    });

    testWidgets('should show error if login fails with wrong credentials', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Enter invalid email and password
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;
      await tester.enterText(emailField, 'wrong@example.com');
      await tester.enterText(passwordField, 'wrongpassword');

      // Tap the login button
      final loginButton = find.text('Log In');
      await tester.tap(loginButton);
      await tester.pump();

      // Verify error message for invalid credentials
      expect(find.text('Invalid email or password'), findsOneWidget);
    });
  });
}