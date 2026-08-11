import 'package:flutter/material.dart';

import '../engine/core.dart';
import '../theme.dart';

/// Art with a graceful fallback — missing files must never crash a run.
class Art extends StatelessWidget {
  const Art(this.key_, {super.key, this.fit = BoxFit.cover, this.opacity = 1});
  final String key_;
  final BoxFit fit;
  final double opacity;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: opacity,
        child: Image.asset(
          'assets/img/$key_.webp',
          fit: fit,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => Container(
            color: Ae.panel,
            child: const Center(
                child: Icon(Icons.auto_stories, color: Ae.panelHi, size: 30)),
          ),
        ),
      );
}

class HpBar extends StatelessWidget {
  const HpBar({
    super.key,
    required this.hp,
    required this.maxHp,
    this.block = 0,
    this.width = 150,
    this.height = 22,
    this.showText = true,
  });

  final int hp;
  final int maxHp;
  final int block;
  final double width;
  final double height;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final f = maxHp <= 0 ? 0.0 : (hp / maxHp).clamp(0.0, 1.0);
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A0E10),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Ae.panelHi, width: 1.2),
            ),
          ),
          FractionallySizedBox(
            widthFactor: f,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFD5493A), Color(0xFF8F2B22)]),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          if (showText)
            Center(
              child: Text('$hp / $maxHp',
                  style: Ae.body(height * .62, w: 700, c: Colors.white, h: 1)),
            ),
          if (block > 0)
            Positioned(
              left: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF12354A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Ae.frost, width: 1.4),
                ),
                child: Text('⛨ $block',
                    style: Ae.body(13, w: 800, c: Ae.frost, h: 1)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Conditions and the elemental aura, as tappable chips. Tapping any of them
/// explains what it does — nothing in a fight should be a mystery.
class StatusRow extends StatelessWidget {
  const StatusRow(
    this.statuses, {
    super.key,
    this.aura = Elem.none,
    this.size = 15,
    this.compact = false,
  });

  final Map<String, int> statuses;
  final Elem aura;
  final double size;

  /// Icon-and-number chips on a single scrollable rail, for the cramped foe
  /// columns. Off means full names on a wrapping layout, for the hero bar.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (aura != Elem.none) {
      chips.add(_chip(context, compact ? aura.glyph : '${aura.glyph} ${aura.label}',
          aura.color,
          filled: true, onTap: () => _auraInfo(context, aura)));
    }
    statuses.forEach((k, v) {
      final def = kStatus[k];
      if (def == null || v == 0) return;
      chips.add(_chip(
        context,
        compact ? '${def.glyph}$v' : '${def.glyph} ${def.name} $v',
        def.color,
        onTap: () => _statusInfo(context, def, v),
      ));
    });
    if (chips.isEmpty) return const SizedBox.shrink();

    if (!compact) {
      return Wrap(
          spacing: 5, runSpacing: 5, alignment: WrapAlignment.center, children: chips);
    }

    // Compact mode: a single scrollable rail. Nothing is hidden and nothing is
    // clipped — a foe carrying eight conditions just becomes a strip you swipe.
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
        stops: [0, .06, .94, 1],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 4),
        itemBuilder: (_, i) => Center(child: chips[i]),
      ),
    );
  }

  Widget _chip(BuildContext context, String text, Color c,
          {bool filled = false, VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 8, vertical: compact ? 3 : 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                c.withValues(alpha: filled ? .34 : .20),
                const Color(0xE60A0D14),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.withValues(alpha: .8), width: 1.1),
          ),
          child: Text(text, style: Ae.body(size, w: 800, c: c, h: 1)),
        ),
      );

  static void _statusInfo(BuildContext context, StatusDef def, int stacks) {
    aeDialog(
      context,
      glyph: def.glyph,
      accent: def.color,
      kicker: def.debuff ? 'DEBUFF' : 'BUFF',
      title: '${def.name} $stacks',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(def.desc, style: Ae.body(17, c: Ae.bone, h: 1.55)),
          const SizedBox(height: 14),
          Text(
            def.debuff
                ? 'Bad for whoever is carrying it — including you.'
                : 'Good for whoever is carrying it — including foes.',
            style: Ae.body(14, c: Ae.dim),
          ),
        ],
      ),
    );
  }

  static void _auraInfo(BuildContext context, Elem e) {
    final others = Elem.values.where((x) => x != Elem.none && x != e).toList();
    aeDialog(
      context,
      glyph: e.glyph,
      accent: e.color,
      kicker: 'ELEMENTAL AURA',
      title: '${e.label} Aura',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Strike this with a DIFFERENT element and the two collide into a '
            'Reaction — a free bonus effect. The aura is consumed, and returns '
            'two turns later.',
            style: Ae.body(16, c: Ae.bone, h: 1.55),
          ),
          const SizedBox(height: 16),
          Text('WHAT BEATS IT', style: Ae.label(11, c: e.color)),
          const SizedBox(height: 10),
          for (final o in others)
            Builder(builder: (_) {
              final id = reactionFor(e, o);
              if (id == null) return const SizedBox.shrink();
              final r = kReactions[id]!;
              return Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: o.color.withValues(alpha: .6)),
                      ),
                      child: Text(o.glyph,
                          style: TextStyle(fontSize: 15, color: o.color)),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${o.label}  →  ${r.name}',
                              style: Ae.label(13, c: r.color)),
                          const SizedBox(height: 2),
                          Text(r.blurb, style: Ae.body(14, c: Ae.dim, h: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

/// A playable frame. Sized for thumbs and readable at arm's length.
class FrameCard extends StatelessWidget {
  const FrameCard({
    super.key,
    required this.card,
    this.width = 148,
    this.playable = true,
    this.selected = false,
    this.onTap,
    this.showCost = true,
  });

  final CardInst card;
  final double width;
  final bool playable;
  final bool selected;
  final VoidCallback? onTap;
  final bool showCost;

  @override
  Widget build(BuildContext context) {
    final e = card.def.elem;
    final tint = e == Elem.none ? Ae.gold : e.color;
    final h = width * 1.52;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: width,
        height: h,
        transform: Matrix4.translationValues(0, selected ? -18 : 0, 0),
        decoration: BoxDecoration(
          color: Ae.ink2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Ae.bone : tint.withValues(alpha: playable ? .85 : .3),
            width: selected ? 2.6 : 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: (selected ? tint : Colors.black).withValues(alpha: selected ? .5 : .55),
              blurRadius: selected ? 22 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Opacity(
          opacity: playable ? 1 : .5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: h * .40,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Art(card.def.artKey()),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Ae.ink2.withValues(alpha: .95),
                            ],
                          ),
                        ),
                      ),
                      if (showCost)
                        Positioned(
                          left: 5,
                          top: 5,
                          child: Container(
                            width: 30,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Ae.ink.withValues(alpha: .92),
                              shape: BoxShape.circle,
                              border: Border.all(color: tint, width: 2),
                            ),
                            child: Text(
                              card.def.unplayable ? '—' : '${card.cost}',
                              style: Ae.body(17, w: 800, c: Ae.bone, h: 1),
                            ),
                          ),
                        ),
                      Positioned(
                        right: 5,
                        top: 6,
                        child: Text(e == Elem.none ? '◇' : e.glyph,
                            style: TextStyle(fontSize: 18, color: tint)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  color: tint.withValues(alpha: .16),
                  child: Text(
                    card.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Ae.label(width * .088, c: Ae.bone),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(7, 6, 7, 4),
                    child: Text(
                      card.text,
                      textAlign: TextAlign.center,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: Ae.body(width * .088, c: Ae.bone, h: 1.24, w: 500),
                    ),
                  ),
                ),
                Container(
                  height: 3,
                  color: card.def.rarity.color.withValues(alpha: .9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Large section heading used across menus.
class Heading extends StatelessWidget {
  const Heading(this.text, {super.key, this.sub, this.size = 26});
  final String text;
  final String? sub;
  final double size;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: Ae.display(size)),
          if (sub != null) ...[
            const SizedBox(height: 6),
            Text(sub!, style: Ae.body(15, c: Ae.dim)),
          ],
          const SizedBox(height: 10),
          Container(height: 2, width: 70, color: Ae.gold.withValues(alpha: .7)),
        ],
      );
}

/// Reusable top bar with a back affordance.
class AeBar extends StatelessWidget implements PreferredSizeWidget {
  const AeBar(this.title, {super.key, this.onBack, this.trailing});
  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(58);

  @override
  Widget build(BuildContext context) => Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Ae.ink.withValues(alpha: .88),
          border: const Border(bottom: BorderSide(color: Ae.panelHi)),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, color: Ae.goldSoft, size: 26),
                ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(title,
                    style: Ae.display(19), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      );
}

/// Big, readable prose block for story text.
class Prose extends StatelessWidget {
  const Prose(this.text, {super.key, this.size = 17, this.color = Ae.bone});
  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final parts = text.split('**');
    return RichText(
      text: TextSpan(
        style: Ae.body(size, c: color, h: 1.6),
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i],
              style: i.isOdd ? Ae.body(size, c: Ae.gold, w: 800, h: 1.6) : null,
            ),
        ],
      ),
    );
  }
}
