import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/luqmah_theme.dart';

class PremiumPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PremiumPageAppBar({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isScrolled = false,
    this.leading,
    this.titleContent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isScrolled;
  final Widget? leading;
  final Widget? titleContent;

  @override
  Size get preferredSize => const Size.fromHeight(84);

  @override
  Widget build(BuildContext context) {
    final tokens = context.luqmah;
    final canPop = Navigator.of(context).canPop();
    final radius = isScrolled ? AppRadii.xl : AppRadii.md;
    final background = tokens.surface.withValues(alpha: isScrolled ? 0.95 : 0.90);
    final borderColor = tokens.border.withValues(alpha: isScrolled ? 0.75 : 0.55);
    final shadowColor = Colors.black.withValues(alpha: isScrolled ? 0.05 : 0.02);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(12, 10, 16, 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(radius),
            ),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: isScrolled ? 16 : 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              if (canPop)
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: tokens.strongText,
                  ),
                  visualDensity: VisualDensity.compact,
                )
              else
                const SizedBox(width: 8),
              leading ??
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: tokens.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(icon, color: tokens.primary, size: 20),
                  ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: titleContent ??
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            textStyle: Theme.of(context).textTheme.titleLarge,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOut,
                          opacity: isScrolled ? 0.92 : 1,
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: tokens.mutedText,
                            ),
                          ),
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
