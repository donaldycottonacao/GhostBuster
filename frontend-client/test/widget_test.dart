import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/main.dart';
import 'package:frontend_client/models/call_state.dart';
import 'package:frontend_client/providers/call_provider.dart';

void main() {
  testWidgets('setup selections are stored in the in-memory call session', (
    tester,
  ) async {
    final provider = CallProvider();
    await tester.pumpWidget(GhostBusterApp(provider: provider));
    await tester.pumpAndSettle();

    expect(find.text('Set your exit'), findsOneWidget);
    expect(provider.state, CallLifecycleState.configuration);

    await tester.tap(find.text('1 min'));
    await tester.pump();
    expect(provider.delaySeconds, 60);

    await tester.tap(find.text('Tagalog'));
    await tester.pumpAndSettle();
    expect(provider.languageCode, 'tl');
    expect(provider.currentLocale.languageCode, 'en');

    final situationField = find.byType(TextField).first;
    await tester.ensureVisible(situationField);
    await tester.enterText(situationField, 'At a party and ready to leave');
    expect(provider.situationText, 'At a party and ready to leave');

    final scriptField = find.byType(TextField).last;
    await tester.ensureVisible(scriptField);
    await tester.enterText(scriptField, 'Please call me when you can.');
    expect(provider.voiceScriptText, 'Please call me when you can.');
  });

  testWidgets('AI option uses a local sample for the selected language', (
    tester,
  ) async {
    final provider = CallProvider();
    await tester.pumpWidget(GhostBusterApp(provider: provider));
    await tester.pumpAndSettle();

    final bisayaOption = find.text('Cebuano / Bisaya');
    await tester.ensureVisible(bisayaOption);
    await tester.tap(bisayaOption);
    await tester.pumpAndSettle();
    expect(provider.languageCode, 'ceb');

    final generateOption = find.text('Generate with AI');
    await tester.ensureVisible(generateOption);
    await tester.tap(generateOption);
    await tester.pump();

    const bisayaSample =
        'Uy, matawagan ko nimo? Kinahanglan kog rason para makagawas.';
    expect(provider.voiceScriptText, bisayaSample);
    expect(provider.currentLocale.languageCode, 'en');

    final ownOption = find.text('Write my own');
    await tester.ensureVisible(ownOption);
    await tester.tap(ownOption);
    await tester.pump();
    final scriptField = find.byType(TextField).last;
    await tester.ensureVisible(scriptField);
    await tester.enterText(scriptField, 'Akong kaugalingong script');
    expect(provider.voiceScriptText, 'Akong kaugalingong script');
  });

  testWidgets('arm control does not start a call flow yet', (tester) async {
    final provider = CallProvider();
    await tester.pumpWidget(GhostBusterApp(provider: provider));
    await tester.pumpAndSettle();

    final armButton = find.text('ARM STEALTH MODE');
    await tester.ensureVisible(armButton);
    await tester.tap(armButton);
    await tester.pump();
    expect(provider.state, CallLifecycleState.configuration);
  });
}
