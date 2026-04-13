import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_utility_toolkit_hng_14_mobile_stage_0/app.dart';
import 'package:smart_utility_toolkit_hng_14_mobile_stage_0/core/theme/theme_provider.dart';

void main() {
  testWidgets('App renders onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    // Verify onboarding screen renders with first page title
    expect(find.text('Measure Anything'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });
}
