import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/screens/login_screen.dart';
import 'package:social_media_app/theme/theme_provider.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  testWidgets('Login screen shows correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: MaterialApp(
          home: LoginScreen(
            auth: MockFirebaseAuth(),
            isTest: true, // Add this line
          ),
        ),
      ),
    );

    // Verify that the LoginScreen is displayed.
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
