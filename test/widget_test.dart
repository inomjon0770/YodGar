import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_flutter_app/main.dart';
import 'package:my_flutter_app/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('YodgarApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const YodgarApp(),
      ),
    );

    // Pump frames to complete async SharedPreferences load
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('YODGAR ga Xush Kelibsiz!'), findsOneWidget);
  });
}
