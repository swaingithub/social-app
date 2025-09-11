import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jivvi/providers/user_provider.dart';
import 'package:jivvi/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/screens/login_screen.dart';
import 'package:jivvi/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Login screen shows correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
          ChangeNotifierProvider(
            create: (context) => UserProvider(
              ApiService(),
            ),
          ),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify that the LoginScreen is displayed.
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
