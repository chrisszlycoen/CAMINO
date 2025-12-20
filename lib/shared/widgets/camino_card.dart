import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// A pure structural card widget focusing on layout rather than decoration
class CaminoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? width;
  final bool highlighted;

  const CaminoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.backgroundColor,
    this.highlighted = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget cardContent = Container(
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.cardTheme.color,
        borderRadius: AppSpacing.borderRadiusLg,
        border: highlighted
            ? Border.all(color: AppColors.primary, width: 2.0)
            : theme.cardTheme.shape is RoundedRectangleBorder
                ? Border.all(
                    color: (theme.cardTheme.shape as RoundedRectangleBorder).side.color,
                    width: (theme.cardTheme.shape as RoundedRectangleBorder).side.width, 
                  )
                : null,
        boxShadow: !isDark && !highlighted ? AppColors.premiumShadowLight : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusLg,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    return cardContent;
  }
}
