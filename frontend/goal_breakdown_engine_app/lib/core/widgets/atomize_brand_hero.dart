import 'package:flutter/material.dart';

/// Visual identity for pre-auth screens: center mark + orbiting feature icons
/// + wordmark, aligned with product onboarding themes.
enum AtomizeBrandVariant {
  /// Light ink on splash gradient (navy / teal).
  splashOnGradient,

  /// Primary-tinted mark on light UI (onboarding, sheets).
  onLightSurface,

  /// Mark on dark surfaces.
  onDarkSurface,
}

class AtomizeBrandHero extends StatelessWidget {
  const AtomizeBrandHero({
    super.key,
    required this.variant,
    this.compact = false,
    this.horizontal = false,
    this.showWordmark = true,
    this.showOrbitIcons = true,
    this.tagline,
  });

  final AtomizeBrandVariant variant;
  final bool compact;
  final bool horizontal;

  /// When false, only the graphic cluster is shown (e.g. loading gate).
  final bool showWordmark;

  final bool showOrbitIcons;

  final String? tagline;

  static const String wordmarkText = 'ATOMIZE';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _colors(theme);

    final cluster = _AtomizeMark(
      variant: variant,
      compact: compact,
      showOrbitIcons: showOrbitIcons,
      centerColor: colors.centerFill,
      centerBorder: colors.centerBorder,
      orbitFill: colors.orbitFill,
      orbitBorder: colors.orbitBorder,
      iconColor: colors.icon,
    );

    if (!showWordmark && tagline == null) {
      return cluster;
    }

    final wordmark = Text(
      wordmarkText,
      style: TextStyle(
        color: colors.wordmark,
        fontSize: compact ? 22 : 32,
        fontWeight: FontWeight.w800,
        letterSpacing: compact ? 2.8 : 4,
        height: 1.05,
      ),
    );

    final tag = tagline != null
        ? Padding(
            padding: EdgeInsets.only(top: compact ? 8 : 12),
            child: Text(
              tagline!,
              textAlign: horizontal ? TextAlign.start : TextAlign.center,
              style: TextStyle(
                color: colors.tagline,
                fontSize: compact ? 13 : 15,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : null;

    if (horizontal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          cluster,
          SizedBox(width: compact ? 14 : 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showWordmark) wordmark,
                ?tag,
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        cluster,
        if (showWordmark) ...[
          SizedBox(height: compact ? 18 : 24),
          wordmark,
        ],
        ?tag,
      ],
    );
  }

  _BrandPalette _colors(ThemeData theme) {
    switch (variant) {
      case AtomizeBrandVariant.splashOnGradient:
        return const _BrandPalette(
          centerFill: Color(0x33FFFFFF),
          centerBorder: Color(0x8FFFFFFF),
          orbitFill: Color(0x26FFFFFF),
          orbitBorder: Color(0x59FFFFFF),
          icon: Colors.white,
          wordmark: Colors.white,
          tagline: Color(0xEBFFFFFF),
        );
      case AtomizeBrandVariant.onLightSurface:
        final p = theme.colorScheme.primary;
        return _BrandPalette(
          centerFill: p.withValues(alpha: 0.12),
          centerBorder: p.withValues(alpha: 0.35),
          orbitFill: p.withValues(alpha: 0.08),
          orbitBorder: p.withValues(alpha: 0.28),
          icon: p,
          wordmark: theme.colorScheme.onSurface,
          tagline: theme.colorScheme.onSurfaceVariant,
        );
      case AtomizeBrandVariant.onDarkSurface:
        final p = theme.colorScheme.primary;
        return _BrandPalette(
          centerFill: p.withValues(alpha: 0.22),
          centerBorder: p.withValues(alpha: 0.45),
          orbitFill: Colors.white.withValues(alpha: 0.08),
          orbitBorder: Colors.white.withValues(alpha: 0.2),
          icon: theme.colorScheme.primary,
          wordmark: theme.colorScheme.onSurface,
          tagline: theme.colorScheme.onSurfaceVariant,
        );
    }
  }
}

class _BrandPalette {
  const _BrandPalette({
    required this.centerFill,
    required this.centerBorder,
    required this.orbitFill,
    required this.orbitBorder,
    required this.icon,
    required this.wordmark,
    required this.tagline,
  });

  final Color centerFill;
  final Color centerBorder;
  final Color orbitFill;
  final Color orbitBorder;
  final Color icon;
  final Color wordmark;
  final Color tagline;
}

class _AtomizeMark extends StatelessWidget {
  const _AtomizeMark({
    required this.variant,
    required this.compact,
    required this.showOrbitIcons,
    required this.centerColor,
    required this.centerBorder,
    required this.orbitFill,
    required this.orbitBorder,
    required this.iconColor,
  });

  final AtomizeBrandVariant variant;
  final bool compact;
  final bool showOrbitIcons;
  final Color centerColor;
  final Color centerBorder;
  final Color orbitFill;
  final Color orbitBorder;
  final Color iconColor;

  static const _orbitIcons = <IconData>[
    Icons.flag_rounded,
    Icons.auto_awesome_rounded,
    Icons.account_tree_rounded,
    Icons.track_changes_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final scale = compact ? 0.72 : 1.0;
    final center = 88.0 * scale;
    final orbit = 40.0 * scale;
    final iconSz = 19.0 * scale;
    final centerIcon = 44.0 * scale;
    final spread = 52.0 * scale;

    Widget orbitBubble(IconData icon, Alignment align) {
      return Align(
        alignment: align,
        child: Container(
          width: orbit,
          height: orbit,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: orbitFill,
            border: Border.all(color: orbitBorder, width: 1.2),
            boxShadow: variant == AtomizeBrandVariant.splashOnGradient
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Icon(icon, size: iconSz, color: iconColor),
        ),
      );
    }

    final stack = SizedBox(
      width: center + spread,
      height: center + spread * 0.85,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (showOrbitIcons) ...[
            orbitBubble(_orbitIcons[0], const Alignment(-0.95, -0.92)),
            orbitBubble(_orbitIcons[1], const Alignment(0.95, -0.85)),
            orbitBubble(_orbitIcons[2], const Alignment(-0.88, 0.88)),
            orbitBubble(_orbitIcons[3], const Alignment(0.92, 0.92)),
          ],
          Container(
            width: center,
            height: center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26 * scale),
              color: centerColor,
              border: Border.all(color: centerBorder, width: 1.5),
              boxShadow: variant == AtomizeBrandVariant.splashOnGradient
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Icon(
              Icons.hexagon_outlined,
              size: centerIcon,
              color: iconColor,
            ),
          ),
        ],
      ),
    );

    return stack;
  }
}
