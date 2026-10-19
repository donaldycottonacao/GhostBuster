import 'package:flutter/material.dart';

const _background = Color(0xFF0A0D0C);
const _surface = Color(0xFF171B1D);
const _border = Color(0xFF33383D);
const _green = Color(0xFF86D78E);
const _muted = Color(0xFF9AA1A8);

class CountdownScreen extends StatelessWidget {
  const CountdownScreen({
    super.key,
    required this.delaySeconds,
    required this.onCancel,
    required this.onPreviewIncoming,
  });

  final int delaySeconds;
  final VoidCallback onCancel;
  final VoidCallback onPreviewIncoming;

  String get _staticTime {
    final minutes = (delaySeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (delaySeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _CountdownHeader(),
                  const SizedBox(height: 42),
                  const Text(
                    'Standing by...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 26),
                  Center(
                    child: SizedBox.square(
                      dimension: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox.expand(
                            child: CircularProgressIndicator(
                              value: 0.5,
                              strokeWidth: 4,
                              backgroundColor: _border,
                              color: _green,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _staticTime,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 58,
                                  fontWeight: FontWeight.w300,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'SILENT COUNTDOWN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const Text(
                    'Static countdown preview',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  const _CallerPreviewCard(),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(58),
                      side: const BorderSide(color: _muted),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onPreviewIncoming,
                    child: const Text(
                      'Preview incoming call screen',
                      style: TextStyle(color: _muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountdownHeader extends StatelessWidget {
  const _CountdownHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.menu_rounded, color: _muted, size: 25),
        SizedBox(width: 14),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: 'PHANTOM EXIT  ·  '),
                TextSpan(
                  text: 'STEALTH ACTIVE',
                  style: TextStyle(color: _green),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(width: 14),
        Icon(Icons.more_horiz_rounded, color: _muted, size: 25),
      ],
    );
  }
}

class _CallerPreviewCard extends StatelessWidget {
  const _CallerPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 31,
            backgroundColor: Color(0xFF343A40),
            child: Icon(Icons.person_rounded, color: Colors.white70, size: 38),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Riley Morgan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Emergency contact',
                  style: TextStyle(color: _muted, fontSize: 14),
                ),
              ],
            ),
          ),
          Icon(Icons.equalizer_rounded, color: Color(0xFFFFC247), size: 24),
        ],
      ),
    );
  }
}
