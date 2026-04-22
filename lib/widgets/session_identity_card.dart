import 'package:flutter/material.dart';

import '../services/app_session_service.dart';

class SessionIdentityCard extends StatelessWidget {
  final SessionIdentity identity;
  final VoidCallback onLogout;
  final Color backgroundColor;
  final Color primaryColor;
  final Color textColor;
  final Color secondaryTextColor;

  const SessionIdentityCard({
    super.key,
    required this.identity,
    required this.onLogout,
    this.backgroundColor = Colors.white,
    this.primaryColor = const Color(0xFF2E7D32),
    this.textColor = Colors.black87,
    this.secondaryTextColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    final roleLabel = identity.role == AppRole.vendor ? 'Vendor' : 'Customer';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: primaryColor.withValues(alpha: 0.12),
            child: Icon(
              identity.role == AppRole.vendor
                  ? Icons.storefront_rounded
                  : Icons.person_rounded,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      identity.title,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        identity.isDemo ? '$roleLabel Demo' : roleLabel,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  identity.subtitle,
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onLogout,
            icon: Icon(Icons.logout_rounded, color: primaryColor, size: 18),
            label: Text(
              'Logout',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
