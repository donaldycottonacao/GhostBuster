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
    expect(provider.currentLocale.languageCode, 'tl');

    final situationField = find.byType(TextField).first;
    await tester.ensureVisible(situationField);
    await tester.enterText(situationField, 'At a party and ready to leave');
    expect(provider.situationText, 'At a party and ready to leave');

    final scriptField = find.byType(TextField).last;
    await tester.ensureVisible(scriptField);
    await tester.enterText(scriptField, 'Please call me when you can.');
    expect(provider.voiceScriptText, 'Please call me when you can.');
  });

  testWidgets('call lifecycle transitions through countdown and call states', (
    tester,
  ) async {
    final provider = CallProvider();
    addTearDown(provider.dispose);

    provider.startCountdown();
    expect(provider.state, CallLifecycleState.countdown);
    provider.cancelCountdown();
    expect(provider.state, CallLifecycleState.configuration);

    provider.setDelaySeconds(1);
    provider.startCountdown();
    await tester.pump(const Duration(seconds: 1));
    expect(provider.state, CallLifecycleState.ringing);

    provider.answerCall();
    expect(provider.state, CallLifecycleState.active);
    provider.endCall();
    expect(provider.state, CallLifecycleState.configuration);
  });

  testWidgets('declining a ringing call ends the session', (tester) async {
    final provider = CallProvider();
    addTearDown(provider.dispose);

    provider.setDelaySeconds(1);
    provider.startCountdown();
    await tester.pump(const Duration(seconds: 1));
    expect(provider.state, CallLifecycleState.ringing);

    provider.declineCall();
    expect(provider.state, CallLifecycleState.ended);
  });
}
