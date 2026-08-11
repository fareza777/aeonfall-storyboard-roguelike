import 'package:flutter/material.dart';

/// AEONFALL visual language. Text is deliberately large and high-contrast —
/// nothing under 15sp anywhere in the game.
class Ae {
  static const ink = Color(0xFF07070C);
  static const ink2 = Color(0xFF0E1018);
  static const panel = Color(0xFF161A26);
  static const panelHi = Color(0xFF232939);
  static const gold = Color(0xFFE8B04B);
  static const goldSoft = Color(0xFFF2D79A);
  static const bone = Color(0xFFF2EDE3);
  static const dim = Color(0xFFA9AFC0);
  static const blood = Color(0xFFC8452F);
  static const good = Color(0xFF57C98A);

  static const ember = Color(0xFFFF7A34);
  static const frost = Color(0xFF62CBEA);
  static const volt = Color(0xFFB47CF5);
  static const umbra = Color(0xFF8A6BD1);
  static const lumen = Color(0xFFFFD86B);

  // ---- typography -------------------------------------------------------
  // Both families ship as variable fonts, so weight is set through the `wght`
  // axis. fontWeight is passed as well so the fallback face still looks right
  // if the variable axis is ever unavailable.
  static FontWeight _fw(double w) =>
      FontWeight.values[((w / 100).round() - 1).clamp(0, 8)];

  static TextStyle display(double size, {Color c = bone, double w = 700}) =>
      TextStyle(
        fontFamily: 'Cinzel',
        fontSize: size,
        color: c,
        height: 1.18,
        letterSpacing: size * .04,
        fontWeight: _fw(w),
        fontVariations: [FontVariation('wght', w)],
        shadows: const [
          Shadow(color: Colors.black, blurRadius: 14, offset: Offset(0, 2)),
          Shadow(color: Colors.black87, blurRadius: 4),
        ],
      );

  static TextStyle body(double size, {Color c = bone, double w = 400, double h = 1.45}) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        color: c,
        height: h,
        fontWeight: _fw(w),
        fontVariations: [FontVariation('wght', w)],
        shadows: const [Shadow(color: Colors.black54, blurRadius: 3)],
      );

  static TextStyle label(double size, {Color c = goldSoft, double w = 700}) =>
      TextStyle(
        fontFamily: 'Inter',
        fontSize: size,
        color: c,
        height: 1.2,
        letterSpacing: 1.1,
        fontWeight: _fw(w),
        fontVariations: [FontVariation('wght', w)],
        shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
      );

  static ThemeData theme() => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: ink,
        colorScheme: const ColorScheme.dark(
          primary: gold,
          secondary: volt,
          surface: panel,
        ),
        fontFamily: 'Inter',
        splashFactory: InkRipple.splashFactory,
      );
}

/// A lacquered panel: layered gradient, hairline top highlight, deep shadow and
/// optional corner brackets. Everything in the game sits on one of these, so
/// this is where the "expensive" feeling is won or lost.
class AePanel extends StatelessWidget {
  const AePanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.border = Ae.panelHi,
    this.fill,
    this.radius = 14,
    this.ornament = false,
    this.glow,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color border;

  /// Overrides the default two-stop gradient with a flat colour.
  final Color? fill;
  final double radius;
  final bool ornament;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          const BoxShadow(color: Color(0xB3000000), blurRadius: 24, offset: Offset(0, 10)),
          const BoxShadow(color: Color(0x66000000), blurRadius: 4, offset: Offset(0, 2)),
          if (glow != null) BoxShadow(color: glow!.withValues(alpha: .28), blurRadius: 26),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Container(
          decoration: BoxDecoration(
            gradient: fill != null
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xF21C2131), Color(0xF20B0E16)],
                  ),
            color: fill,
            borderRadius: r,
            border: Border.all(color: border.withValues(alpha: .55), width: 1.1),
          ),
          child: Stack(
            children: [
              // hairline of light along the top edge — reads as bevelled glass
              Positioned(
                left: 10,
                right: 10,
                top: 0,
                child: Container(height: 1, color: Colors.white.withValues(alpha: .07)),
              ),
              if (ornament)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _CornerBrackets(border)),
                  ),
                ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _CornerBrackets extends CustomPainter {
  _CornerBrackets(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withValues(alpha: .85)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const m = 7.0, len = 13.0;
    final w = size.width, h = size.height;
    for (final c in [
      [Offset(m, m + len), Offset(m, m), Offset(m + len, m)],
      [Offset(w - m - len, m), Offset(w - m, m), Offset(w - m, m + len)],
      [Offset(m, h - m - len), Offset(m, h - m), Offset(m + len, h - m)],
      [Offset(w - m - len, h - m), Offset(w - m, h - m), Offset(w - m, h - m - len)],
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(c[0].dx, c[0].dy)
          ..lineTo(c[1].dx, c[1].dy)
          ..lineTo(c[2].dx, c[2].dy),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CornerBrackets old) => old.color != color;
}

/// A hairline rule with a diamond at its centre. Used to separate sections.
class AeRule extends StatelessWidget {
  const AeRule({super.key, this.color = Ae.gold, this.width = 200});
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: 10,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, color.withValues(alpha: .7)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Transform.rotate(
                angle: .785,
                child: Container(width: 5, height: 5, color: color),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: .7), Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

/// Large, unmistakable tappable button.
class AeButton extends StatefulWidget {
  const AeButton({
    super.key,
    required this.label,
    required this.onTap,
    this.sub,
    this.color = Ae.gold,
    this.enabled = true,
    this.expand = true,
    this.big = false,
  });

  final String label;
  final String? sub;
  final VoidCallback? onTap;
  final Color color;
  final bool enabled;
  final bool expand;
  final bool big;

  @override
  State<AeButton> createState() => _AeButtonState();
}

class _AeButtonState extends State<AeButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final on = widget.enabled && widget.onTap != null;
    return GestureDetector(
      onTapDown: on ? (_) => setState(() => _down = true) : null,
      onTapUp: on ? (_) => setState(() => _down = false) : null,
      onTapCancel: on ? () => setState(() => _down = false) : null,
      onTap: on ? widget.onTap : null,
      child: AnimatedScale(
        scale: _down ? .975 : 1,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _down ? .35 : .6),
                blurRadius: _down ? 8 : 16,
                offset: Offset(0, _down ? 2 : 6),
              ),
              if (on && !_down)
                BoxShadow(color: widget.color.withValues(alpha: .16), blurRadius: 20),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: widget.expand ? double.infinity : null,
              padding: EdgeInsets.symmetric(
                  horizontal: widget.big ? 26 : 20, vertical: widget.big ? 17 : 13),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: on
                      ? [
                          widget.color.withValues(alpha: .26),
                          widget.color.withValues(alpha: .07),
                          const Color(0xCC0B0E16),
                        ]
                      : const [Color(0xCC151A25), Color(0xCC0B0E16)],
                  stops: on ? const [0, .55, 1] : null,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: on ? widget.color.withValues(alpha: .9) : Ae.panelHi,
                  width: 1.3,
                ),
              ),
              child: Stack(
                // Without this the label sits against the left edge, because a
                // Stack aligns non-positioned children to its top-start corner.
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 14,
                    right: 14,
                    top: 0,
                    child: Container(
                      height: 1,
                      color: Colors.white.withValues(alpha: on ? .13 : .05),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: Ae.label(widget.big ? 19 : 16,
                            c: on ? Ae.bone : Ae.dim.withValues(alpha: .55)),
                      ),
                      if (widget.sub != null) ...[
                        const SizedBox(height: 5),
                        Text(widget.sub!,
                            textAlign: TextAlign.center,
                            style: Ae.body(14.5,
                                c: on ? Ae.dim : Ae.dim.withValues(alpha: .4))),
                      ],
                    ],
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

/// The house modal. Replaces Material's AlertDialog everywhere so every popup
/// in the game shares one deliberate look instead of the stock grey box.
Future<void> aeDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  String? kicker,
  String? glyph,
  Color accent = Ae.gold,
  String close = 'Close',
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierColor: const Color(0xCC02030A),
    barrierDismissible: true,
    barrierLabel: title,
    transitionDuration: const Duration(milliseconds: 260),
    transitionBuilder: (_, anim, __, child) {
      final t = Curves.easeOutCubic.transform(anim.value);
      return Opacity(
        opacity: anim.value,
        child: Transform.scale(scale: .94 + .06 * t, child: child),
      );
    },
    pageBuilder: (ctx, _, __) => Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 48),
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: AePanel(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
              border: accent,
              ornament: true,
              glow: accent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (glyph != null) ...[
                        Text(glyph, style: TextStyle(fontSize: 27, color: accent)),
                        const SizedBox(width: 13),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (kicker != null) ...[
                              Text(kicker, style: Ae.label(11, c: accent)),
                              const SizedBox(height: 4),
                            ],
                            Text(title, style: Ae.display(21)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerLeft, child: AeRule(color: accent, width: 130)),
                  const SizedBox(height: 14),
                  Flexible(child: SingleChildScrollView(child: content)),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: accent.withValues(alpha: .7)),
                        ),
                        child: Text(close.toUpperCase(), style: Ae.label(13, c: accent)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The house bottom sheet. Same lacquered treatment as [AePanel], with a
/// title, a drawn rule and a grab handle.
Future<void> aeSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget Function(BuildContext) builder,
  double heightFactor = .78,
  Color accent = Ae.gold,
  Widget? trailing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    barrierColor: const Color(0xC402030A),
    builder: (ctx) => Container(
      height: MediaQuery.of(ctx).size.height * heightFactor,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B2030), Color(0xFF07090F)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(top: BorderSide(color: accent.withValues(alpha: .8), width: 1.4)),
        boxShadow: const [BoxShadow(color: Colors.black, blurRadius: 40)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 11),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Ae.panelHi,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Ae.display(21)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle, style: Ae.body(14, c: Ae.dim)),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: AeRule(color: accent, width: 140),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(child: builder(ctx)),
        ],
      ),
    ),
  );
}

/// Full-bleed background image with a readability scrim.
class AeBackdrop extends StatelessWidget {
  const AeBackdrop({super.key, required this.image, required this.child, this.dark = .62});
  final String image;
  final Widget child;
  final double dark;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/img/$image.webp',
              fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Ae.ink)),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Ae.ink.withValues(alpha: dark + .18),
                  Ae.ink.withValues(alpha: dark - .10),
                  Ae.ink.withValues(alpha: dark + .30),
                ],
                stops: const [0, .45, 1],
              ),
            ),
          ),
          child,
        ],
      );
}
