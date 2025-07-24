import 'dart:ui';

import 'package:flutter/material.dart';

class BlurAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? foregroundColor;
  final double blurSigma;
  final Color? backgroundColor;

  const BlurAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.foregroundColor,
    this.blurSigma = 16,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: AppBar(
          title: title,
          actions: actions,
          leading: leading,
          backgroundColor: backgroundColor ?? Colors.white.withOpacity(0.15),
          elevation: 0,
          foregroundColor: foregroundColor ?? colorScheme.onBackground,
          shadowColor: Colors.black12,
          surfaceTintColor: Colors.transparent,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
