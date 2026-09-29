import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

enum LogoSize { compact, normal, large }

/// Matches the web prototype's `Logo`: mark + "SMARTREP" wordmark. The large
/// size adds the BLE signal arcs above the mark and the tagline underneath.
///
/// Like the prototype, [muted] defaults to true (grey mark, dark-grey
/// "SMART"); pass `muted: false` for the blue-accent variant.
class Logo extends StatelessWidget {
  const Logo({
    super.key,
    this.size = LogoSize.normal,
    this.muted = true,
    this.animatedSignal = false,
  });
  final LogoSize size;
  final bool muted;
  final bool animatedSignal;

  static const _grayMark = 'assets/images/smartrep-mark-gray.svg';

  @override
  Widget build(BuildContext context) {
    // size-9 / size-24 / size-16 and text-xl / text-5xl / text-3xl in the prototype.
    final markSize = switch (size) { LogoSize.compact => 36.0, LogoSize.large => 96.0, LogoSize.normal => 64.0 };
    final textSize = switch (size) { LogoSize.compact => 20.0, LogoSize.large => 48.0, LogoSize.normal => 30.0 };

    final mark = SvgPicture.asset(
      _grayMark,
      width: markSize,
      height: markSize,
      semanticsLabel: 'SmartRep',
      // If the SVG ever fails to parse, show a visible placeholder instead of
      // silently rendering nothing.
      placeholderBuilder: (_) => SizedBox(width: markSize, height: markSize),
    );

    final wordmark = RichText(
      text: TextSpan(
        style: AppText.display(size: textSize, weight: FontWeight.w700),
        children: [
          TextSpan(
            text: 'SMART',
            style: TextStyle(color: muted ? const Color(0xFF525252) : AppColors.brandBlue),
          ),
          const TextSpan(text: 'REP', style: TextStyle(color: Colors.white)),
        ],
      ),
    );

    if (size == LogoSize.large) {
      return Padding(
        // The arcs sit in the 36px band above the mark (`pt-9` / `-top-9`).
        padding: const EdgeInsets.only(top: 36),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                mark,
                const SizedBox(height: 4),
                wordmark,
                const SizedBox(height: 8),
                Text(
                  'LIFT SMART, NOT HARD',
                  style: AppText.sans(size: 12, weight: FontWeight.w500, color: AppColors.mutedForeground)
                      .copyWith(letterSpacing: 12 * 0.22),
                ),
              ],
            ),
            Positioned(
              top: -36,
              child: BleSignalArcs(animated: animatedSignal),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [mark, const SizedBox(width: 12), wordmark],
    );
  }
}

/// Matches `.bluetooth-signal`: three nested arcs (with end dots) above the
/// logo. When [animated] they pulse in sequence like `ble-arc-pulse`
/// (3.2s loop, inner -> mid -> wide, 0.3s apart).
class BleSignalArcs extends StatefulWidget {
  const BleSignalArcs({super.key, this.animated = false});
  final bool animated;

  @override
  State<BleSignalArcs> createState() => _BleSignalArcsState();
}

class _BleSignalArcsState extends State<BleSignalArcs> with SingleTickerProviderStateMixin {
  static const _cycle = Duration(milliseconds: 3200);
  late final AnimationController _c = AnimationController(vsync: this, duration: _cycle);

  // 0% / 100%: opacity .35 #525252 | 30%: 1 #e5e5e5 | 60%: .55 #737373
  static final _opacity = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.35, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.55).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 0.55, end: 0.35).chain(CurveTween(curve: Curves.easeInOut)), weight: 40),
  ]);
  static final _color = TweenSequence<Color?>([
    TweenSequenceItem(
        tween: ColorTween(begin: const Color(0xFF525252), end: const Color(0xFFE5E5E5)).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30),
    TweenSequenceItem(
        tween: ColorTween(begin: const Color(0xFFE5E5E5), end: const Color(0xFF737373)).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30),
    TweenSequenceItem(
        tween: ColorTween(begin: const Color(0xFF737373), end: const Color(0xFF525252)).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40),
  ]);

  @override
  void initState() {
    super.initState();
    if (widget.animated) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant BleSignalArcs old) {
    super.didUpdateWidget(old);
    if (widget.animated && !_c.isAnimating) _c.repeat();
    if (!widget.animated) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  _ArcStyle _styleFor(double delaySeconds) {
    if (!widget.animated) return const _ArcStyle(Color(0xFF525252), 0.9);
    final phase = (_c.value - delaySeconds / 3.2) % 1.0;
    return _ArcStyle(_color.transform(phase) ?? const Color(0xFF525252), _opacity.transform(phase));
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: 80,
        height: 48,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _ArcsPainter(
              wide: _styleFor(0.6),
              mid: _styleFor(0.3),
              inner: _styleFor(0.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcStyle {
  const _ArcStyle(this.color, this.opacity);
  final Color color;
  final double opacity;
}

class _ArcsPainter extends CustomPainter {
  _ArcsPainter({required this.wide, required this.mid, required this.inner});
  final _ArcStyle wide;
  final _ArcStyle mid;
  final _ArcStyle inner;

  // width, height and bottom offset per arc, from styles.css
  // (.bluetooth-signal-arc-wide/-mid/-inner).
  void _arc(Canvas canvas, Size size, double w, double h, double bottom, _ArcStyle st) {
    final color = st.color.withValues(alpha: st.opacity);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.butt;
    final dot = Paint()..color = color;

    final cx = size.width / 2;
    final baseY = 42.0 - bottom; // container is 42px tall
    final r = w / 2 - 1; // centre of the 2px border
    final straight = math.max(0.0, h - w / 2); // border-radius clamps to a semicircle
    final left = cx - r;
    final right = cx + r;
    final arcCenterY = baseY - straight;

    final path = Path()
      ..moveTo(left, baseY)
      ..lineTo(left, arcCenterY)
      ..arcTo(Rect.fromCircle(center: Offset(cx, arcCenterY), radius: r), math.pi, math.pi, false)
      ..lineTo(right, baseY);
    canvas.drawPath(path, stroke);

    // ::before / ::after end dots (6px, sitting just below the arc ends)
    canvas.drawCircle(Offset(left, baseY + 1), 3, dot);
    canvas.drawCircle(Offset(right, baseY + 1), 3, dot);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _arc(canvas, size, 76, 38, 0, wide);
    _arc(canvas, size, 52, 28, 10, mid);
    _arc(canvas, size, 28, 18, 20, inner);
  }

  @override
  bool shouldRepaint(covariant _ArcsPainter old) =>
      old.wide.color != wide.color ||
      old.wide.opacity != wide.opacity ||
      old.mid.color != mid.color ||
      old.mid.opacity != mid.opacity ||
      old.inner.color != inner.color ||
      old.inner.opacity != inner.opacity;
}
