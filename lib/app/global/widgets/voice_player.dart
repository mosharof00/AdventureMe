import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/extensions/sizedbox_extension.dart';
import '../../core/extensions/text_style_extension.dart';
import '../../core/theme/app_color.dart';
import 'app_text.dart';

/// WhatsApp-style voice note: play/pause, a seekable waveform and the time.
/// [path] is a local file; [levels] are 0–1 loudness samples for the bars.
class VoicePlayer extends StatefulWidget {
  const VoicePlayer({
    super.key,
    required this.path,
    this.levels = const [],
    this.initialDuration = Duration.zero,
    this.enabled = true,
  });

  final String path;
  final List<double> levels;
  final Duration initialDuration;
  final bool enabled;

  @override
  State<VoicePlayer> createState() => _VoicePlayerState();
}

class _VoicePlayerState extends State<VoicePlayer> {
  final _player = AudioPlayer();
  final _subscriptions = <StreamSubscription>[];

  bool _isPlaying = false;
  Duration _position = Duration.zero;
  late Duration _duration = widget.initialDuration;

  @override
  void initState() {
    super.initState();
    // After recording, iOS would otherwise play through the quiet earpiece.
    _player.setAudioContext(
      AudioContextConfig(route: AudioContextConfigRoute.speaker).build(),
    );
    _player.setReleaseMode(ReleaseMode.stop);
    _player.setSource(DeviceFileSource(widget.path));
    _subscriptions.addAll([
      _player.onDurationChanged.listen((d) {
        if (mounted && d > Duration.zero) setState(() => _duration = d);
      }),
      _player.onPositionChanged.listen((p) {
        if (mounted) setState(() => _position = p);
      }),
      _player.onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
      }),
      _player.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _position = Duration.zero);
      }),
    ]);
  }

  Future<void> _toggle() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  Future<void> _seekTo(double fraction) async {
    if (_duration == Duration.zero) return;
    final target = _duration * fraction.clamp(0.0, 1.0);
    setState(() => _position = target);
    await _player.seek(target);
  }

  @override
  void didUpdateWidget(VoicePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && _isPlaying) _player.pause();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
    final showPosition = _isPlaying || _position > Duration.zero;

    return Row(
      children: [
        GestureDetector(
          onTap: widget.enabled ? _toggle : null,
          child: Container(
            width: 52.r,
            height: 52.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primary,
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: AppColor.white,
              size: 30.sp,
            ),
          ),
        ),
        12.width,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  void seek(Offset local) =>
                      _seekTo(local.dx / constraints.maxWidth);
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: widget.enabled
                        ? (d) => seek(d.localPosition)
                        : null,
                    onHorizontalDragUpdate: widget.enabled
                        ? (d) => seek(d.localPosition)
                        : null,
                    child: SizedBox(
                      height: 32.h,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: VoiceWaveformPainter(
                          levels: VoiceWaveformPainter.resample(
                            widget.levels,
                            32,
                          ),
                          progress: progress,
                          showThumb: true,
                        ),
                      ),
                    ),
                  );
                },
              ),
              4.height,
              AppText(
                formatVoiceDuration(showPosition ? _position : _duration),
                style: context.labelSmall.copyWith(color: AppColor.hintText),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// `75s` → `01:15`.
String formatVoiceDuration(Duration d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.inMinutes)}:${two(d.inSeconds % 60)}';
}

/// Vertical rounded bars; the first [progress] part is drawn in [playedColor].
class VoiceWaveformPainter extends CustomPainter {
  VoiceWaveformPainter({
    required this.levels,
    this.progress = 0,
    this.playedColor = AppColor.primary,
    this.idleColor = const Color(0xFFB8C4D1),
    this.showThumb = false,
  });

  final List<double> levels;
  final double progress;
  final Color playedColor;
  final Color idleColor;
  final bool showThumb;

  /// Averages [levels] into exactly [count] bars (flat bars when empty).
  static List<double> resample(List<double> levels, int count) {
    if (levels.isEmpty) return List.filled(count, 0.25);
    return List.generate(count, (i) {
      final start = i * levels.length ~/ count;
      final end = math.max(start + 1, (i + 1) * levels.length ~/ count);
      final bucket = levels.sublist(start, math.min(end, levels.length));
      return bucket.reduce((a, b) => a + b) / bucket.length;
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;
    final slot = size.width / levels.length;
    final barWidth = math.max(2.0, slot * 0.55);
    final paint = Paint()
      ..strokeWidth = barWidth
      ..strokeCap = StrokeCap.round;
    final centerY = size.height / 2;

    for (var i = 0; i < levels.length; i++) {
      final x = slot * i + slot / 2;
      final height = math.max(barWidth, levels[i].clamp(0.0, 1.0) * size.height);
      paint.color = x / size.width <= progress ? playedColor : idleColor;
      canvas.drawLine(
        Offset(x, centerY - height / 2 + barWidth / 2),
        Offset(x, centerY + height / 2 - barWidth / 2),
        paint,
      );
    }

    if (showThumb) {
      canvas.drawCircle(
        Offset((size.width * progress).clamp(6.0, size.width - 6), centerY),
        6,
        Paint()..color = playedColor,
      );
    }
  }

  @override
  bool shouldRepaint(VoiceWaveformPainter old) =>
      old.progress != progress || old.levels != levels;
}
