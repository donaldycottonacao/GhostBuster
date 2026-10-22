// Phase 9: deterministic controller tests for CallProvider.
//
// Every timer runs on a fake clock (package:fake_async) so 10–180 s countdowns
// are exercised instantly and race conditions are reproducible.

import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_client/models/call_state.dart';
import 'package:frontend_client/providers/call_provider.dart';

import 'helpers/audio_fakes.dart';

const _momVoice = 'assets/audio/peer_mom.mp3';
final _landlord = CallerPersona.defaultPersonas[1];
final _noAudioPersona = CallerPersona.defaultPersonas[2];

/// Runs [body] on a fake clock with a fresh provider and recording audio fake.
void runFake(
  void Function(
    FakeAsync async,
    CallProvider provider,
    RecordingAudioService audio,
  ) body,
) {
  fakeAsync((async) {
    final audio = RecordingAudioService();
    final provider = CallProvider(audioService: audio);
    body(async, provider, audio);
    provider.dispose();
    async.flushMicrotasks();
  });
}

/// Total live timers (periodic + one-shot) on the fake clock.
int timers(FakeAsync async) =>
    async.periodicTimerCount + async.nonPeriodicTimerCount;

/// Drives a fresh provider into the ringing state through a real countdown.
void ringAfter(FakeAsync async, CallProvider provider, {int delay = 10}) {
  expect(provider.startCountdown(delaySeconds: delay), isTrue);
  async.elapse(Duration(seconds: delay));
  expect(provider.state, CallLifecycleState.ringing);
}

void main() {
  group('A. Initial state', () {
    test('starts in configuration with no timers and no audio', () {
      runFake((async, provider, audio) {
        expect(provider.state, CallLifecycleState.configuration);
        expect(timers(async), 0);
        async.elapse(const Duration(minutes: 5));
        expect(audio.log, isEmpty);
        expect(provider.state, CallLifecycleState.configuration);
      });
    });
  });

  group('B. Valid trigger', () {
    test('starts exactly one silent countdown and keeps the scenario', () {
      runFake((async, provider, audio) {
        final started =
            provider.startCountdown(delaySeconds: 30, persona: _landlord);

        expect(started, isTrue);
        expect(provider.state, CallLifecycleState.countdown);
        expect(provider.persona.id, 'landlord');
        expect(provider.remainingCountdown, 30);
        expect(async.periodicTimerCount, 1);
        expect(audio.log, isEmpty);
      });
    });
  });

  group('C. Invalid input', () {
    for (final delay in [0, 9, 181, 600]) {
      test('rejects delay $delay s without timers, audio or partial state', () {
        runFake((async, provider, audio) {
          expect(provider.startCountdown(delaySeconds: delay), isFalse);
          expect(provider.state, CallLifecycleState.configuration);
          expect(provider.remainingCountdown, 10);
          expect(timers(async), 0);
          async.elapse(const Duration(minutes: 4));
          expect(audio.log, isEmpty);
        });
      });
    }

    test('accepts the inclusive 10 s and 180 s boundaries', () {
      runFake((async, provider, audio) {
        expect(provider.startCountdown(delaySeconds: 10), isTrue);
        provider.cancelCountdown();
        expect(provider.startCountdown(delaySeconds: 180), isTrue);
        expect(provider.remainingCountdown, 180);
      });
    });

    test('a persona without a voice track answers silently, no crash', () {
      runFake((async, provider, audio) {
        provider.setPersona(_noAudioPersona);
        ringAfter(async, provider);
        provider.answerCall();
        async.flushMicrotasks();

        expect(provider.state, CallLifecycleState.active);
        expect(audio.count('playPeerAudio'), 0);
      });
    });
  });

  group('D. Countdown progression', () {
    test('ticks down silently, never negative, rings exactly once', () {
      runFake((async, provider, audio) {
        final remainingSeen = <int>[];
        var ringingNotifications = 0;
        var triggered = 0;
        provider.addListener(() {
          remainingSeen.add(provider.remainingCountdown);
          if (provider.state == CallLifecycleState.ringing) {
            ringingNotifications++;
          }
        });

        provider.startCountdown(
            delaySeconds: 10, onTriggered: () => triggered++);
        async.elapse(const Duration(seconds: 1));
        expect(provider.remainingCountdown, 9);

        async.elapse(const Duration(seconds: 8));
        expect(provider.state, CallLifecycleState.countdown);
        expect(provider.remainingCountdown, 1);
        expect(audio.log, isEmpty, reason: 'countdown must stay silent');

        async.elapse(const Duration(seconds: 1));
        expect(provider.state, CallLifecycleState.ringing);
        expect(provider.remainingCountdown, 0);
        expect(audio.log, ['playRingtone']);
        expect(triggered, 1);
        expect(timers(async), 0, reason: 'countdown timer must be released');

        async.elapse(const Duration(minutes: 3));
        expect(audio.count('playRingtone'), 1);
        expect(ringingNotifications, 1);
        expect(remainingSeen.every((value) => value >= 0), isTrue);
        expect(remainingSeen.first, 10);
        expect(remainingSeen.last, 0);
      });
    });

    test('a 180 s countdown expires at exactly 180 s', () {
      runFake((async, provider, audio) {
        provider.startCountdown(delaySeconds: 180);
        async.elapse(const Duration(seconds: 179, milliseconds: 999));
        expect(provider.state, CallLifecycleState.countdown);
        async.elapse(const Duration(milliseconds: 1));
        expect(provider.state, CallLifecycleState.ringing);
      });
    });
  });

  group('E. Cancellation', () {
    test('cancel stops the timer and no ringing happens later', () {
      runFake((async, provider, audio) {
        provider.startCountdown(delaySeconds: 10, persona: _landlord);
        async.elapse(const Duration(seconds: 5));
        provider.cancelCountdown();

        expect(provider.state, CallLifecycleState.configuration);
        expect(provider.remainingCountdown, 10);
        expect(timers(async), 0);

        async.elapse(const Duration(minutes: 5));
        expect(provider.state, CallLifecycleState.configuration);
        expect(audio.log, isEmpty);
        // Configuration preferences survive a cancel; only the run is cleared.
        expect(provider.persona.id, 'landlord');
        expect(provider.delaySeconds, 10);
      });
    });

    test('cancel 1 ms before the deadline wins', () {
      runFake((async, provider, audio) {
        provider.startCountdown(delaySeconds: 10);
        async.elapse(const Duration(milliseconds: 9999));
        provider.cancelCountdown();
        async.elapse(const Duration(seconds: 10));

        expect(provider.state, CallLifecycleState.configuration);
        expect(audio.log, isEmpty);
      });
    });

    test('same-instant race: expiry processed first rings, late cancel ignored',
        () {
      runFake((async, provider, audio) {
        provider.startCountdown(delaySeconds: 10);
        // Created after the countdown timer, so it fires after the final tick.
        Future<void>.delayed(
          const Duration(seconds: 10),
          provider.cancelCountdown,
        );
        async.elapse(const Duration(seconds: 10));

        expect(provider.state, CallLifecycleState.ringing);
        expect(audio.count('playRingtone'), 1);
      });
    });

    test('same-instant race: cancel processed first leaves no ringing', () {
      runFake((async, provider, audio) {
        // Created before the countdown timer, so it fires first at t = 10 s.
        Future<void>.delayed(
          const Duration(seconds: 10),
          provider.cancelCountdown,
        );
        provider.startCountdown(delaySeconds: 10);
        async.elapse(const Duration(seconds: 30));

        expect(provider.state, CallLifecycleState.configuration);
        expect(audio.log, isEmpty);
        expect(timers(async), 0);
      });
    });
  });

  group('F. Invalid transitions', () {
    test('double trigger during countdown keeps one timer and one scenario',
        () {
      runFake((async, provider, audio) {
        provider.startCountdown(delaySeconds: 20);
        async.elapse(const Duration(seconds: 3));
        final second =
            provider.startCountdown(delaySeconds: 10, persona: _landlord);

        expect(second, isFalse);
        expect(async.periodicTimerCount, 1);
        expect(provider.remainingCountdown, 17);
        expect(provider.persona, CallerPersona.defaultPersona);

        async.elapse(const Duration(seconds: 17));
        expect(provider.state, CallLifecycleState.ringing);
        expect(audio.count('playRingtone'), 1);
      });
    });

    test('trigger is rejected while ringing and while active', () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        expect(provider.startCountdown(delaySeconds: 10), isFalse);
        expect(provider.state, CallLifecycleState.ringing);

        provider.answerCall();
        expect(provider.startCountdown(delaySeconds: 10), isFalse);
        expect(provider.state, CallLifecycleState.active);
        expect(audio.count('playRingtone'), 1);
      });
    });

    test('answer, decline and hang-up are ignored in the wrong states', () {
      runFake((async, provider, audio) {
        provider.answerCall();
        provider.declineCall();
        provider.endCall();
        expect(provider.state, CallLifecycleState.configuration);

        provider.startCountdown(delaySeconds: 10);
        provider.answerCall();
        provider.declineCall();
        provider.endCall();
        expect(provider.state, CallLifecycleState.countdown);
        expect(async.periodicTimerCount, 1);

        async.elapse(const Duration(seconds: 10));
        provider.endCall();
        expect(provider.state, CallLifecycleState.ringing);

        provider.answerCall();
        provider.declineCall();
        expect(provider.state, CallLifecycleState.active);
        expect(
            audio.log, ['playRingtone', 'stopAll', 'playPeerAudio:$_momVoice']);
      });
    });

    test('returnToSetup cannot abandon a running countdown (regression)', () {
      runFake((async, provider, audio) {
        provider.startCountdown(delaySeconds: 10);
        provider.returnToSetup();
        expect(provider.state, CallLifecycleState.countdown);

        provider.cancelCountdown();
        async.elapse(const Duration(seconds: 30));
        expect(provider.state, CallLifecycleState.configuration);
        expect(audio.log, isEmpty);
      });
    });

    test('returnToSetup cannot leave an active call running (regression)', () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        provider.answerCall();
        provider.returnToSetup();
        expect(provider.state, CallLifecycleState.active);

        provider.endCall();
        provider.returnToSetup();
        expect(provider.state, CallLifecycleState.configuration);
        expect(timers(async), 0);
      });
    });
  });

  group('G. Decline and ringing timeout', () {
    test('decline stops audio and ends the call with no timers left', () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        provider.declineCall();

        expect(provider.state, CallLifecycleState.ended);
        expect(audio.log, ['playRingtone', 'stopAll']);
        expect(timers(async), 0);

        provider.reset();
        expect(provider.state, CallLifecycleState.configuration);
      });
    });

    test('handleRingingTimeout cleans up like decline and is ignored elsewhere',
        () {
      runFake((async, provider, audio) {
        provider.handleRingingTimeout();
        expect(provider.state, CallLifecycleState.configuration);

        ringAfter(async, provider);
        provider.handleRingingTimeout();
        expect(provider.state, CallLifecycleState.ended);
        expect(audio.count('stopAll'), 1);
      });
    });

    test('no automatic ringing timeout is configured (documented behavior)',
        () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        async.elapse(const Duration(minutes: 10));
        expect(provider.state, CallLifecycleState.ringing);
        expect(timers(async), 0);
      });
    });

    test('answer then timeout: answer wins, timeout is ignored', () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        provider.answerCall();
        provider.handleRingingTimeout();
        expect(provider.state, CallLifecycleState.active);
        expect(audio.count('playPeerAudio'), 1);
      });
    });

    test('timeout then answer: timeout wins, no voice starts', () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        provider.handleRingingTimeout();
        provider.answerCall();
        expect(provider.state, CallLifecycleState.ended);
        expect(audio.count('playPeerAudio'), 0);
      });
    });
  });

  group('H. Answer and active call', () {
    test('stops ringtone before voice, then counts simulated duration', () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        provider.answerCall();
        async.flushMicrotasks();

        expect(provider.state, CallLifecycleState.active);
        expect(
            audio.log, ['playRingtone', 'stopAll', 'playPeerAudio:$_momVoice']);
        expect(async.periodicTimerCount, 1, reason: 'one duration timer');

        async.elapse(const Duration(seconds: 3));
        expect(provider.activeDurationSeconds, 3);
        expect(provider.formattedElapsedTime, '00:03');
      });
    });

    test('duplicate answer starts one voice and one duration timer', () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        provider.answerCall();
        provider.answerCall();
        provider.answerCall();

        expect(audio.count('playPeerAudio'), 1);
        expect(async.periodicTimerCount, 1);
        async.elapse(const Duration(seconds: 2));
        expect(provider.activeDurationSeconds, 2);
      });
    });

    test('async voice-start failure is contained; hang-up still cleans up', () {
      runFake((async, provider, audio) {
        audio.failingOps.add('playPeerAudio');
        ringAfter(async, provider);
        provider.answerCall();
        async.flushMicrotasks();

        // Documented policy: the visual call continues; nothing escapes.
        expect(provider.state, CallLifecycleState.active);
        provider.endCall();
        expect(provider.state, CallLifecycleState.ended);
        expect(timers(async), 0);
      });
    });

    test('synchronous voice-start throw is contained', () {
      runFake((async, provider, audio) {
        audio
          ..failingOps.add('playPeerAudio')
          ..throwSynchronously = true;
        ringAfter(async, provider);
        expect(provider.answerCall, returnsNormally);
        expect(provider.state, CallLifecycleState.active);
      });
    });

    test('reset right after answer leaves no stale active state', () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        provider.answerCall();
        provider.reset();
        async.elapse(const Duration(seconds: 10));

        expect(provider.state, CallLifecycleState.configuration);
        expect(provider.activeDurationSeconds, 0);
        expect(timers(async), 0);
      });
    });
  });

  group('I. Hang-up and reset', () {
    test('hang-up stops media and freezes the duration', () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        provider.answerCall();
        provider.toggleMute();
        provider.toggleSpeaker();
        async.elapse(const Duration(seconds: 5));
        provider.endCall();

        expect(provider.state, CallLifecycleState.ended);
        expect(audio.log.last, 'stopAll');
        expect(provider.isMuted, isFalse);
        expect(provider.isSpeakerOn, isFalse);
        expect(timers(async), 0);

        async.elapse(const Duration(seconds: 30));
        expect(provider.activeDurationSeconds, 5);
      });
    });

    test('reset from every state restores a clean default session', () {
      for (final reach in <void Function(FakeAsync, CallProvider)>[
        (async, p) {},
        (async, p) => p.startCountdown(delaySeconds: 15, persona: _landlord),
        (async, p) => ringAfter(async, p),
        (async, p) {
          ringAfter(async, p);
          p.answerCall();
        },
        (async, p) {
          ringAfter(async, p);
          p.declineCall();
        },
      ]) {
        runFake((async, provider, audio) {
          reach(async, provider);
          provider.reset();
          provider.reset();

          expect(provider.state, CallLifecycleState.configuration);
          expect(provider.session.persona, CallerPersona.defaultPersona);
          expect(provider.delaySeconds, 10);
          expect(provider.activeDurationSeconds, 0);
          expect(timers(async), 0);
          final logLength = audio.log.length;
          async.elapse(const Duration(minutes: 4));
          expect(audio.log.length, logLength);
        });
      }
    });

    test('a new simulation works after reset', () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        provider.reset();
        ringAfter(async, provider, delay: 30);
        expect(audio.count('playRingtone'), 2);
      });
    });
  });

  group('Race conditions', () {
    test('stale countdown from before a reset cannot ring the new session', () {
      runFake((async, provider, audio) {
        provider.startCountdown(delaySeconds: 10);
        async.elapse(const Duration(seconds: 5));
        provider.reset();
        provider.startCountdown(delaySeconds: 20);

        async.elapse(const Duration(seconds: 10));
        expect(provider.state, CallLifecycleState.countdown);
        expect(provider.remainingCountdown, 10);
        expect(audio.count('playRingtone'), 0);
        expect(async.periodicTimerCount, 1);

        async.elapse(const Duration(seconds: 10));
        expect(provider.state, CallLifecycleState.ringing);
        expect(audio.count('playRingtone'), 1);
      });
    });

    test('dispose during countdown cancels timers and stays silent', () {
      fakeAsync((async) {
        final audio = RecordingAudioService();
        final provider = CallProvider(audioService: audio);
        var notifications = 0;
        provider.startCountdown(delaySeconds: 10);
        provider.addListener(() => notifications++);

        provider.dispose();
        expect(timers(async), 0);
        async.elapse(const Duration(minutes: 1));

        expect(notifications, 0);
        expect(audio.count('playRingtone'), 0);
        expect(audio.log, ['stopAll']);
      });
    });

    test('dispose during an active call stops the duration timer', () {
      fakeAsync((async) {
        final audio = RecordingAudioService();
        final provider = CallProvider(audioService: audio);
        ringAfter(async, provider);
        provider.answerCall();
        provider.dispose();

        expect(timers(async), 0);
        expect(audio.log.last, 'stopAll');
        expect(() => async.elapse(const Duration(seconds: 5)), returnsNormally);
      });
    });
  });

  group('Audio failures inside the controller', () {
    test('ringtone failure at expiry still shows ringing and can be declined',
        () {
      runFake((async, provider, audio) {
        audio.failingOps.add('playRingtone');
        ringAfter(async, provider);
        async.flushMicrotasks();
        provider.declineCall();
        expect(provider.state, CallLifecycleState.ended);
      });
    });

    test('synchronous ringtone throw inside the timer callback is contained',
        () {
      runFake((async, provider, audio) {
        audio
          ..failingOps.add('playRingtone')
          ..throwSynchronously = true;
        var ringingNotified = false;
        provider.addListener(() {
          if (provider.state == CallLifecycleState.ringing) {
            ringingNotified = true;
          }
        });
        ringAfter(async, provider);
        expect(ringingNotified, isTrue);
      });
    });

    test('stopAll failure during decline, hang-up and reset is contained', () {
      runFake((async, provider, audio) {
        audio.failingOps.add('stopAll');
        ringAfter(async, provider);
        provider.declineCall();
        async.flushMicrotasks();
        expect(provider.state, CallLifecycleState.ended);

        provider.reset();
        ringAfter(async, provider);
        provider.answerCall();
        provider.endCall();
        async.flushMicrotasks();
        expect(provider.state, CallLifecycleState.ended);
        expect(timers(async), 0);
      });
    });

    test('a valid simulation succeeds after a previous failure', () {
      runFake((async, provider, audio) {
        audio.failingOps.addAll(['playRingtone', 'playPeerAudio']);
        ringAfter(async, provider);
        provider.answerCall();
        provider.endCall();
        provider.reset();
        async.flushMicrotasks();

        audio.failingOps.clear();
        ringAfter(async, provider);
        provider.answerCall();
        async.flushMicrotasks();
        expect(provider.state, CallLifecycleState.active);
        expect(audio.isVoicePlaying, isTrue);
      });
    });
  });

  group('Lifecycle policy', () {
    for (final event in [
      AppLifecycleState.paused,
      AppLifecycleState.hidden,
      AppLifecycleState.detached,
    ]) {
      test('${event.name} cancels a countdown; resume does not revive it', () {
        runFake((async, provider, audio) {
          provider.startCountdown(delaySeconds: 10);
          async.elapse(const Duration(seconds: 4));
          provider.handleAppLifecycle(event);
          provider.handleAppLifecycle(AppLifecycleState.resumed);
          async.elapse(const Duration(minutes: 1));

          expect(provider.state, CallLifecycleState.configuration);
          expect(audio.log, isEmpty);
          expect(timers(async), 0);
        });
      });

      test('${event.name} while ringing stops audio and resets', () {
        runFake((async, provider, audio) {
          ringAfter(async, provider);
          provider.handleAppLifecycle(event);
          provider.handleAppLifecycle(AppLifecycleState.resumed);

          expect(provider.state, CallLifecycleState.configuration);
          expect(audio.log, ['playRingtone', 'stopAll']);
        });
      });

      test('${event.name} during the active call stops voice and timers', () {
        runFake((async, provider, audio) {
          ringAfter(async, provider);
          provider.answerCall();
          async.elapse(const Duration(seconds: 2));
          provider.handleAppLifecycle(event);
          provider.handleAppLifecycle(AppLifecycleState.resumed);
          async.elapse(const Duration(seconds: 10));

          expect(provider.state, CallLifecycleState.configuration);
          expect(provider.activeDurationSeconds, 0);
          expect(audio.log.last, 'stopAll');
          expect(timers(async), 0);
        });
      });
    }

    test('inactive (e.g. notification shade) does not interrupt a countdown',
        () {
      runFake((async, provider, audio) {
        provider.startCountdown(delaySeconds: 10);
        provider.handleAppLifecycle(AppLifecycleState.inactive);
        async.elapse(const Duration(seconds: 10));
        expect(provider.state, CallLifecycleState.ringing);
      });
    });

    test('background events leave the ended screen untouched', () {
      runFake((async, provider, audio) {
        ringAfter(async, provider);
        provider.declineCall();
        provider.handleAppLifecycle(AppLifecycleState.paused);
        expect(provider.state, CallLifecycleState.ended);
      });
    });
  });

  group('Repeated use', () {
    test('mixed cycles leave no timers, overlaps or stale scenario', () {
      runFake((async, provider, audio) {
        for (var cycle = 0; cycle < 3; cycle++) {
          // 1. full call
          provider.setPersona(_landlord);
          ringAfter(async, provider);
          provider.answerCall();
          expect(
              audio.log.last, 'playPeerAudio:assets/audio/peer_landlord.mp3');
          async.elapse(const Duration(seconds: 4));
          provider.endCall();
          provider.reset();
          expect(timers(async), 0);
          expect(provider.persona, CallerPersona.defaultPersona);

          // 2. cancelled countdown
          provider.startCountdown(delaySeconds: 30);
          async.elapse(const Duration(seconds: 12));
          provider.cancelCountdown();
          expect(timers(async), 0);

          // 3. declined call
          ringAfter(async, provider);
          provider.declineCall();
          provider.reset();

          // 4. playback failure, recovery, retry
          audio.failingOps.add('playPeerAudio');
          ringAfter(async, provider);
          provider.answerCall();
          async.flushMicrotasks();
          provider.endCall();
          provider.reset();
          audio.failingOps.clear();

          expect(provider.state, CallLifecycleState.configuration);
          expect(timers(async), 0);
          expect(audio.isPlaying, isFalse);
        }

        // 3 cycles x 3 rings, 3 x 2 answers; nothing extra.
        expect(audio.count('playRingtone'), 9);
        expect(audio.count('playPeerAudio'), 6);
        async.elapse(const Duration(minutes: 5));
        expect(audio.count('playRingtone'), 9);
      });
    });
  });
}
