import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/main.dart';
import 'package:frontend_client/widgets/slide_button.dart';

void main() {
  testWidgets('setup previews a static countdown with the selected delay', (
    tester,
  ) async {
    await tester.pumpWidget(const GhostBusterApp());
    await tester.pumpAndSettle();

    expect(find.text('ARM STEALTH MODE'), findsOneWidget);
    await tester.tap(find.text('1 min'));
    await tester.pump();

    final armButton = find.text('ARM STEALTH MODE');
    await tester.ensureVisible(armButton);
    await tester.tap(armButton);
    await tester.pumpAndSettle();

    expect(find.text('01:00'), findsOneWidget);
    expect(find.text('SILENT COUNTDOWN'), findsOneWidget);

    final cancelButton = find.text('CANCEL');
    await tester.ensureVisible(cancelButton);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
    expect(find.text('ARM STEALTH MODE'), findsOneWidget);
  });

  testWidgets('preview flow shows incoming, active, ended, and setup screens', (
    tester,
  ) async {
    await tester.pumpWidget(const GhostBusterApp());
    await tester.pumpAndSettle();

    final armButton = find.text('ARM STEALTH MODE');
    await tester.ensureVisible(armButton);
    await tester.tap(armButton);
    await tester.pumpAndSettle();

    final incomingPreview = find.text('Preview incoming call screen');
    await tester.ensureVisible(incomingPreview);
    await tester.tap(incomingPreview);
    await tester.pumpAndSettle();
    expect(find.text('Incoming call...'), findsOneWidget);
    expect(find.text('Riley Morgan'), findsOneWidget);

    final slideButton = find.byType(SlideButton);
    await tester.ensureVisible(slideButton);
    final sliderRect = tester.getRect(slideButton);
    await tester.dragFrom(
      Offset(sliderRect.left + 35, sliderRect.center.dy),
      Offset(sliderRect.width, 0),
    );
    await tester.pumpAndSettle();
    expect(find.text('Connected'), findsOneWidget);
    // Phase 9: the live flow shows the provider's real simulated duration,
    // which starts at 00:00 (previously a hard-coded 00:18 placeholder).
    expect(find.text('00:00'), findsOneWidget);

    final muteButton = find.text('Mute');
    await tester.ensureVisible(muteButton);
    await tester.tap(muteButton);
    await tester.pump();
    expect(find.text('Unmute'), findsOneWidget);

    await tester.tap(find.text('Keypad'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    final hideKeypad = find.text('HIDE KEYPAD');
    await tester.ensureVisible(hideKeypad);
    await tester.tap(hideKeypad);
    await tester.pump();

    final endCall = find.byIcon(Icons.call_end_rounded);
    await tester.ensureVisible(endCall);
    await tester.tap(endCall);
    await tester.pumpAndSettle();
    expect(find.text('Call ended'), findsOneWidget);

    final returnButton = find.text('RETURN TO SETUP');
    await tester.ensureVisible(returnButton);
    await tester.tap(returnButton);
    await tester.pumpAndSettle();
    expect(find.text('ARM STEALTH MODE'), findsOneWidget);
  });

  testWidgets('AI button inserts a local sample that remains editable', (
    tester,
  ) async {
    await tester.pumpWidget(const GhostBusterApp());
    await tester.pumpAndSettle();

    final bisayaOption = find.text('Cebuano / Bisaya');
    await tester.ensureVisible(bisayaOption);
    await tester.tap(bisayaOption);
    await tester.pump();

    final generateOption = find.text('Generate with AI');
    await tester.ensureVisible(generateOption);
    await tester.tap(generateOption);
    await tester.pump();

    final scriptField = find.byType(TextField).last;
    await tester.ensureVisible(scriptField);
    expect(
      (tester.widget<TextField>(scriptField).controller!).text,
      'Uy, matawagan ko nimo? Kinahanglan kog rason para makagawas.',
    );

    await tester.enterText(scriptField, 'My custom script');
    expect(
      (tester.widget<TextField>(scriptField).controller!).text,
      'My custom script',
    );
  });
}
