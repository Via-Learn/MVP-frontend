import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AnimatedMarkdownMessage extends StatefulWidget {
  final String fullText;
  final Duration delay;
  final TextStyle? style;

  const AnimatedMarkdownMessage({
    super.key,
    required this.fullText,
    this.delay = const Duration(milliseconds: 20),
    this.style,
  });

  @override
  State<AnimatedMarkdownMessage> createState() => _AnimatedMarkdownMessageState();
}

class _AnimatedMarkdownMessageState extends State<AnimatedMarkdownMessage> {
  int _visibleCharCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startUnrolling();
  }

  void _startUnrolling() {
    _timer = Timer.periodic(widget.delay, (timer) {
      if (_visibleCharCount < widget.fullText.length) {
        setState(() => _visibleCharCount++);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleText = widget.fullText.substring(0, _visibleCharCount);

    return MarkdownBody(
      data: visibleText,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        p: widget.style ?? const TextStyle(fontSize: 16),
      ),
    );
  }
}
