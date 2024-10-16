import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled4/main.dart'; // تأكد من أن هذا المسار صحيح

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // بناء التطبيق وتشغيل الإطار.
    await tester.pumpWidget(MyApp());

    // تحقق من أن العداد يبدأ عند 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // الضغط على أيقونة '+' وتشغيل الإطار.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(); // تحديث الويدجيت بعد الضغط

    // تحقق من أن العداد قد زاد.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
