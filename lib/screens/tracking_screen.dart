import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_root.dart';
import '../models/machine.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Live tracking screen, rebuilt from the `smartrep-tracking-screen-final`
/// design: a big rep counter, then four Voronoi-style cells (overall quality,
/// range of motion, speed, pause) divided by thin white lines. The ROM bar
/// bleeds off the left edge and the speed ring bleeds off the right edge.
///
/// The artwork is laid out in the design's own 390 x 844 coordinate space and
/// scaled to the phone's width, so every position below is taken straight from
/// the design file. Header and button are normal widgets.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key, required this.go, required this.machine});
  final GoTo go;
  final Machine machine;

  /// This design uses its own palette (slightly bluer/darker than the rest of
  /// the app). It is applied to this screen only.
  static const background = Color(0xFF0B0C0F);
  static const foreground = Color(0xFFF4F4F5);
  static const muted = Color(0xFF8B909A);
  static const good = Color(0xFF2FD18A);
  static const warn = Color(0xFFF5B942);
  static const orange = Color(0xFFF97316);
  static const poor = Color(0xFFEF4F4F);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int _rep = 6;
  bool _warning = false;

  // Simulated per-rep data (index = rep - 1). Rep 6 matches the design:
  // quality 85, ROM 74% (fair), speed 1.83 m/s (too fast), pause 0.8 s.
  static const _romValues = [86, 91, 94, 88, 82, 74, 68, 92, 89, 85];
  static const _speedValues = [0.92, 1.02, 1.1, 0.98, 0.84, 1.83, 0.54, 1.08, 0.93, 0.88];
  static const _qualityValues = [88, 91, 93, 89, 86, 85, 78, 92, 90, 87];
  static const _pauseValues = [1.2, 1.1, 1.3, 1.0, 0.9, 0.8, 0.7, 1.2, 1.1, 1.0];

  int get _i => (_rep - 1) % _romValues.length;
  int get _rom => _romValues[_i];
  double get _speed => _speedValues[_i];
  int get _quality => _qualityValues[_i];
  double get _pause => _pauseValues[_i];

  void _advance() {
    if (_rep >= 10) {
      widget.go(AppScreen.rest);
      return;
    }
    setState(() {
      _rep++;
      if (_rep == 7) _warning = true;
    });
  }

  // ---- derived display values -------------------------------------------

  Color get _qualityColor => _quality >= 80
      ? TrackingScreen.good
      : _quality >= 60
          ? TrackingScreen.warn
          : TrackingScreen.poor;

  (String, Color) get _romLevel {
    if (_rom >= 75) return ('GOOD', TrackingScreen.good);
    if (_rom >= 50) return ('FAIR', TrackingScreen.warn);
    if (_rom >= 25) return ('LOW', TrackingScreen.orange);
    return ('POOR', TrackingScreen.poor);
  }

  (String, Color) get _speedStatus {
    final s = _speed;
    // Same thresholds as the prototype's SpeedGauge.
    if (s < 0.55) return ('TOO SLOW!', TrackingScreen.poor);
    if (s < 0.8) return ('SLOW', TrackingScreen.warn);
    if (s <= 1.25) return ('IDEAL', TrackingScreen.good);
    if (s <= 1.5) return ('FAST', TrackingScreen.warn);
    return ('TOO FAST!', TrackingScreen.poor);
  }

  Color get _pauseColor => _pause >= 1.0
      ? TrackingScreen.good
      : _pause >= 0.6
          ? TrackingScreen.warn
          : TrackingScreen.poor;

  /// Needle angle in degrees (clockwise from 3 o'clock). Speed 0 -> 116.8
  /// (bottom, "too slow"), 0.9 m/s -> 180 (left, centre of the green band),
  /// 1.8+ m/s -> 243.2 (top, "too fast"), as in the design.
  double get _needleAngle => 116.8 + (_speed / 1.8).clamp(0.0, 1.0) * 126.4;

  /// ROM marker centre (design y). 0% -> bottom, 100% -> top of its travel.
  double get _romMarkerY => 640.0 - (_rom.clamp(0, 100) / 100) * 193.0;

  // ---- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TrackingScreen.background,
      child: Stack(
        children: [
          LayoutBuilder(builder: _buildBody),
          if (_warning) _alert(),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, BoxConstraints c) {
    const designW = 390.0;
    const headerH = 56.0;
    const buttonH = 56.0;
    const posterH = 610.0; // design y 90 .. 700
    const minFree = 36.0;

    // Scale the artwork to the phone's width. Spare height is shared between
    // three gaps in the same proportions as the design (34 / 39 / 49).
    var s = c.maxWidth / designW;
    var free = c.maxHeight - headerH - posterH * s - buttonH;
    if (free < minFree) {
      // Very short screen: shrink the artwork a little so nothing overflows.
      s = math.max(0.5, (c.maxHeight - headerH - buttonH - minFree) / posterH);
      free = math.max(0.0, c.maxHeight - headerH - posterH * s - buttonH);
    }
    final topGap = free * 34 / 122;
    final midGap = free * 39 / 122;
    final bottomGap = free * 49 / 122;
    final sidePad = 35 * c.maxWidth / designW;

    return SizedBox(
      width: c.maxWidth,
      height: c.maxHeight,
      child: Column(
        children: [
          _Header(
            title: widget.machine.name,
            onBack: () => widget.go(AppScreen.reservation),
            onPause: () => widget.go(AppScreen.rest),
          ),
          SizedBox(height: topGap),
          SizedBox(
            width: designW * s,
            height: posterH * s,
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: designW,
                height: posterH,
                // The artwork is pixel-positioned, so ignore system font scaling.
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                  child: _poster(),
                ),
              ),
            ),
          ),
          SizedBox(height: midGap),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sidePad),
            child: _ActionButton(
              label: _rep >= 10 ? 'Finish set' : 'Simulate next rep',
              onTap: _advance,
            ),
          ),
          SizedBox(height: bottomGap),
        ],
      ),
    );
  }

  // ---- the artwork ---------------------------------------------------------

  static const _posterTop = 90.0;

  Widget _poster() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: -_posterTop,
          width: 390,
          height: 844,
          child: ClipRect(clipper: _RightEdgeClipper(), child: _designLayer()),
        ),
      ],
    );
  }

  static final _label = Colors.white.withValues(alpha: 0.75);

  Widget _designLayer() {
    final (romLabel, romColor) = _romLevel;
    final (speedLabel, speedColor) = _speedStatus;
    // The gauge segments are drawn at 85% over black; the status text matches.
    final speedTextColor = Color.alphaBlend(speedColor.withValues(alpha: 0.85), TrackingScreen.background);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: CustomPaint(painter: _CellLinesPainter())),

        // Range-of-motion bar (left edge) with its animated marker.
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: _romMarkerY),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            builder: (context, y, _) => CustomPaint(painter: _RomBarPainter(markerY: y)),
          ),
        ),

        // Speed ring (right edge) with its animated needle.
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: _needleAngle),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            builder: (context, a, _) => CustomPaint(painter: _SpeedRingPainter(angle: a)),
          ),
        ),

        // Set + rep counter.
        _text('SET 2 OF 3', cx: 135.65, baseline: 114.9, size: 23, color: TrackingScreen.muted),
        _rich(
          cx: 136.5,
          baseline: 201.7,
          size: 96,
          spans: [
            TextSpan(text: '$_rep', style: const TextStyle(color: TrackingScreen.foreground)),
            const TextSpan(text: '/10', style: TextStyle(color: TrackingScreen.muted)),
          ],
        ),

        // Overall quality.
        _text('OVERALL', cx: 137.0, baseline: 301.3, size: 14, color: const Color(0xBFC2C2C3), ls: 3.1),
        _text('QUALITY', cx: 137.0, baseline: 318.1, size: 14, color: const Color(0xBFC2C2C3), ls: 3.1),
        _text('$_quality', cx: 138.5, baseline: 366.9, size: 44, color: _qualityColor),

        // Range of motion.
        _text('RANGE OF', cx: 101.7, baseline: 482.1, size: 14, color: _label, ls: 2.1),
        _text('MOTION', cx: 101.7, baseline: 499.0, size: 14, color: _label, ls: 2.1),
        _rich(
          cx: 101.5,
          baseline: 542.0,
          size: 40,
          spans: [
            TextSpan(text: '$_rom', style: const TextStyle(color: TrackingScreen.foreground)),
            TextSpan(
              text: '%',
              style: GoogleFonts.barlowCondensed(fontSize: 40, fontWeight: FontWeight.w400, color: _label),
            ),
          ],
        ),
        _text(romLabel, cx: 102.2, baseline: 573.0, size: 20, color: romColor),

        // Speed.
        _text('SPEED', cx: 320.05, baseline: 248.9, size: 16, color: _label, ls: 2.65),
        _rich(
          cx: 330.25,
          baseline: 293.9,
          size: 40,
          spans: [
            TextSpan(text: _speed.toStringAsFixed(2), style: const TextStyle(color: TrackingScreen.foreground)),
            TextSpan(text: ' m/s', style: TextStyle(color: _label, fontSize: 23)),
          ],
        ),
        _text(speedLabel, cx: 323.1, baseline: 322.0, size: 20, color: speedTextColor),

        // Pause.
        _text('PAUSE', cx: 225.65, baseline: 607.0, size: 15, color: _label, ls: 2.6),
        _rich(
          cx: 228.75,
          baseline: 641.0,
          size: 31,
          spans: [
            TextSpan(text: _pause.toStringAsFixed(1), style: TextStyle(color: _pauseColor)),
            const TextSpan(text: 's', style: TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }

  /// A single centred line of Barlow Condensed placed by its baseline.
  /// (With no explicit line height the baseline sits exactly one font-size
  /// below the top of the text box: Barlow Condensed's ascent is 1.0 em.)
  Widget _text(
    String text, {
    required double cx,
    required double baseline,
    required double size,
    required Color color,
    FontWeight weight = FontWeight.w600,
    double ls = 0,
  }) {
    const boxW = 260.0;
    return Positioned(
      // Flutter adds letter-spacing after the last glyph too, so nudge by half.
      left: cx - boxW / 2 + ls / 2,
      top: baseline - size,
      width: boxW,
      child: Text(
        text,
        textAlign: TextAlign.center,
        softWrap: false,
        overflow: TextOverflow.visible,
        style: GoogleFonts.barlowCondensed(fontSize: size, fontWeight: weight, color: color, letterSpacing: ls),
      ),
    );
  }

  Widget _rich({
    required double cx,
    required double baseline,
    required double size,
    required List<InlineSpan> spans,
  }) {
    const boxW = 260.0;
    return Positioned(
      left: cx - boxW / 2,
      top: baseline - size,
      width: boxW,
      child: Text.rich(
        TextSpan(
          style: GoogleFonts.barlowCondensed(fontSize: size, fontWeight: FontWeight.w600),
          children: spans,
        ),
        textAlign: TextAlign.center,
        softWrap: false,
        overflow: TextOverflow.visible,
      ),
    );
  }

  // ---- form-drift alert (unchanged behaviour) -------------------------------

  Widget _alert() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.popover,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.qualityWarn.withValues(alpha: 0.4)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 24, offset: Offset(0, 10))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.qualityWarn.withValues(alpha: 0.1)),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.qualityWarn, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('FORM IS DRIFTING', style: eyebrowStyle(size: 10)),
                        GestureDetector(
                          onTap: () => setState(() => _warning = false),
                          child: const Icon(Icons.close, size: 16, color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Your range dropped 12%. Keep your chest tall\u2014you're close. Two strong reps left.",
                      style: AppText.sans(size: 12, color: AppColors.mutedForeground),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Header + button
// ===========================================================================

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack, required this.onPause});
  final String title;
  final VoidCallback onBack;
  final VoidCallback onPause;

  static const _chevron =
      '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none">'
      '<path d="M12.5 15L7.5 10L12.5 5" stroke="#F4F4F5" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
      '</svg>';

  static const _pause =
      '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 20 20" fill="none" '
      'stroke="#F4F4F5" stroke-width="2" stroke-linejoin="round">'
      '<rect x="5" y="3.3" width="3.3" height="13.4" rx="0.8"/>'
      '<rect x="11.7" y="3.3" width="3.3" height="13.4" rx="0.8"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          Positioned(left: 8, top: 6, child: _IconButton(svg: _chevron, label: 'Go back', onTap: onBack)),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                title.toUpperCase(),
                style: GoogleFonts.barlowCondensed(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: TrackingScreen.foreground,
                ),
              ),
            ),
          ),
          Positioned(right: 8, top: 6, child: _IconButton(svg: _pause, label: 'Pause workout', onTap: onPause)),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.svg, required this.label, required this.onTap});
  final String svg;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(child: SvgPicture.string(svg, width: 20, height: 20)),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  // lucide "activity" icon, 16px, 1.6px stroke (as in the design).
  static const _activity =
      '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" '
      'stroke="#0B0C0F" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
      '<path d="M22 12h-2.48a2 2 0 0 0-1.93 1.46l-2.35 8.36a.25.25 0 0 1-.48 0L9.24 2.18a.25.25 0 0 0-.48 0l-2.35 8.36A2 2 0 0 1 4.49 12H2"/>'
      '</svg>';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: TrackingScreen.foreground,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: TrackingScreen.background,
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.string(_activity, width: 16, height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// Painters (all in the design's 390 x 844 coordinate space)
// ===========================================================================

/// Clips the artwork at the right edge of the 390-wide design (so the speed
/// ring and hub are cut off there) but lets the ROM bar run off the left.
class _RightEdgeClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) => Rect.fromLTRB(-600, -600, size.width, size.height + 600);

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

/// The thin white Voronoi dividers between the four cells.
class _CellLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    void line(double x1, double y1, double x2, double y2) => canvas.drawLine(Offset(x1, y1), Offset(x2, y2), p);

    // Boundaries of the range-of-motion and pause cells.
    line(136.425, 413.737, 221.716, 551.737);
    line(221.661, 553.336, 114.661, 671.336);
    line(-120, 277.02, 136.235, 413.559); // runs off the left edge
    line(221.594, 551.602, 325.303, 630.602);
    line(114.387, 671.491, -120, 717.18); // runs off the left edge
    line(114, 670.5, 268, 670.5);
    line(325, 630.5, 400, 630.5);
    line(267.713, 670.591, 324.713, 630.591);

    // Speed cell.
    line(276.844, 224.525, 400, 184.1);
    line(201.605, 321.694, 277.605, 223.694);

    // Overall-quality cell.
    line(94, 267.5, 178.374, 267.5);
    line(94.458, 267.2, 70.458, 322.2);
    line(70.492, 321.911, 82, 384.5);
    line(178, 267, 202, 322);
    line(201.966, 321.711, 189.966, 387.711);
    line(190.217, 387.451, 136.217, 413.451);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Four stacked bands (good / fair / low / poor) with a dart-shaped marker.
class _RomBarPainter extends CustomPainter {
  _RomBarPainter({required this.markerY});
  final double markerY;

  static const _bands = [
    (407.5, 468.0, TrackingScreen.good),
    (469.0, 529.5, TrackingScreen.warn),
    (530.5, 591.0, TrackingScreen.orange),
    (592.0, 652.5, TrackingScreen.poor),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const left = -80.0; // extends past the screen edge
    const right = 39.79;
    const corner = Radius.circular(19.5);

    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < _bands.length; i++) {
      final (top, bottom, color) = _bands[i];
      final rrect = RRect.fromLTRBAndCorners(
        left,
        top,
        right,
        bottom,
        topRight: i == 0 ? corner : Radius.zero,
        bottomRight: i == _bands.length - 1 ? corner : Radius.zero,
      );
      canvas.drawRRect(rrect, Paint()..color = color);
      canvas.drawRRect(rrect, stroke);
    }

    // Marker: the design draws it centred on y = 497.3.
    final dy = markerY - 497.3;
    final marker = Path()
      ..moveTo(18.2911, 497.3 + dy)
      ..lineTo(4.07896, 502.091 + dy)
      ..lineTo(-2.70892, 510.3 + dy)
      ..lineTo(-2.70892, 484.3 + dy)
      ..lineTo(4.07896, 492.084 + dy)
      ..close();
    // Radial white -> grey gradient, an ellipse 75 x 91 centred at (13.3, 497).
    final m = Float64List.fromList([75.08, 0, 0, 0, 0, 91.15, 0, 0, 0, 0, 1, 0, 13.29, 497.0 + dy, 0, 1]);
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset.zero,
        1.0,
        const [Colors.white, Color(0xFF989898)],
        null,
        TileMode.clamp,
        m,
      );
    canvas.drawPath(marker, paint);
  }

  @override
  bool shouldRepaint(covariant _RomBarPainter old) => old.markerY != markerY;
}

/// The half-ring speed gauge: five coloured bands (poor, warn, good, warn,
/// poor) around the left half of a circle, plus a needle and hub.
class _SpeedRingPainter extends CustomPainter {
  _SpeedRingPainter({required this.angle});

  /// Needle direction in degrees, clockwise from 3 o'clock.
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    // Dark track under the coloured bands.
    final track = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: const Offset(372.07, 461), radius: 98.4), math.pi / 2, math.pi, false, track);

    const center = Offset(374, 461);
    const radius = 97.5;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const colors = [
      TrackingScreen.poor,
      TrackingScreen.warn,
      TrackingScreen.good,
      TrackingScreen.warn,
      TrackingScreen.poor,
    ];
    const seg = math.pi / 5; // 36 degrees each, bottom -> top via the left
    for (var i = 0; i < colors.length; i++) {
      final p = Paint()
        ..color = colors[i].withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 30
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, math.pi / 2 + i * seg, seg, false, p);
    }

    // The two red ends continue flat off the right edge of the screen.
    final tail = Paint()..color = TrackingScreen.poor.withValues(alpha: 0.85);
    canvas.drawRect(Rect.fromLTRB(center.dx, center.dy + radius - 15, 420, center.dy + radius + 15), tail);
    canvas.drawRect(Rect.fromLTRB(center.dx, center.dy - radius - 15, 420, center.dy - radius + 15), tail);

    // Thin dark dividers between the bands.
    final divider = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5;
    for (final deg in const [126.0, 162.0, 198.0, 234.0]) {
      final a = deg * math.pi / 180;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(center + dir * (radius - 15.5), center + dir * (radius + 15.5), divider);
    }

    // Needle, rotated about the hub (the design shows it at 243.2 degrees).
    const hub = Offset(383.584, 464.608);
    canvas.save();
    canvas.translate(hub.dx, hub.dy);
    canvas.rotate((angle - 243.2) * math.pi / 180);
    canvas.translate(-hub.dx, -hub.dy);
    final needle = Path()
      ..moveTo(349.496, 397.174)
      ..lineTo(357.548, 409.718)
      ..lineTo(366.829, 421.063)
      ..lineTo(375.692, 433.301)
      ..lineTo(381.299, 446.107)
      ..lineTo(370.202, 451.737)
      ..lineTo(362.949, 439.791)
      ..lineTo(358.157, 425.367)
      ..lineTo(355.179, 410.954)
      ..close();
    final needlePaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(375.278, 446.894),
        const Offset(375.515, 421.847),
        const [Colors.white, Color(0xFF999999)],
      );
    canvas.drawPath(needle, needlePaint);
    canvas.restore();

    canvas.drawCircle(hub, 17.75, Paint()..color = const Color(0xFFE7E7E7));
    canvas.drawCircle(
      hub,
      17.75,
      Paint()
        ..color = TrackingScreen.background
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant _SpeedRingPainter old) => old.angle != angle;
}
