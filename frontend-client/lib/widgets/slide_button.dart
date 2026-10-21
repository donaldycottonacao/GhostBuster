import 'package:flutter/material.dart';

/// Reusable horizontal gesture-slider widget scaffold (e.g., slide-to-answer).
class SlideButton extends StatefulWidget {
  final String label;
  final VoidCallback onSlideComplete;
  final Color backgroundColor;
  final Color sliderColor;
  final Color iconColor;
  final double height;
  final double width;

  const SlideButton({
    super.key,
    this.label = 'slide to answer',
    required this.onSlideComplete,
    this.backgroundColor = const Color(0x33FFFFFF),
    this.sliderColor = const Color(0xFF34C759), // iOS style green
    this.iconColor = Colors.white,
    this.height = 70.0,
    this.width = 280.0,
  });

  @override
  State<SlideButton> createState() => _SlideButtonState();
}

class _SlideButtonState extends State<SlideButton> {
  double _dragPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    final double maxDrag = widget.width - widget.height;

    return Semantics(
      label: '${widget.label}. Double tap or slide across to answer',
      button: true,
      onTap: widget.onSlideComplete,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.height / 2),
        ),
        child: Stack(
          children: [
            // Centered instructional label
            Center(
              child: Opacity(
                opacity: (1.0 - (_dragPosition / maxDrag)).clamp(0.0, 1.0),
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            // Draggable thumb button
            Positioned(
              left: _dragPosition,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragPosition =
                        (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
                  });
                },
                onHorizontalDragEnd: (details) {
                  if (_dragPosition >= maxDrag * 0.85) {
                    // Reached trigger threshold
                    setState(() {
                      _dragPosition = maxDrag;
                    });
                    widget.onSlideComplete();
                  } else {
                    // Animate back to start
                    setState(() {
                      _dragPosition = 0.0;
                    });
                  }
                },
                child: Container(
                  width: widget.height,
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: widget.sliderColor,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.call,
                    color: widget.iconColor,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
