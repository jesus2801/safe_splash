import 'package:flutter/material.dart';

import '../../../../core/app_colors.dart';

/// High-contrast provisional banner when drowning is detected.
class DrowningAlertBanner extends StatelessWidget {
  const DrowningAlertBanner({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : const Offset(0, -1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Material(
            elevation: 6,
            color: AppColors.alert,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.alertText),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Possible drowning detected',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.alertText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
