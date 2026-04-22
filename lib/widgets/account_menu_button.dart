import 'package:flutter/material.dart';

import '../services/app_session_service.dart';
import '../services/session_actions.dart';

class AccountMenuButton extends StatelessWidget {
  final VoidCallback onProfileTap;

  const AccountMenuButton({super.key, required this.onProfileTap});

  String _profileLabel(SessionIdentity identity) {
    final roleLabel = identity.isDemo
        ? 'Vendor Demo'
        : identity.role == AppRole.vendor
        ? 'Vendor'
        : 'Customer';
    return 'Profile ($roleLabel)';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SessionIdentity>(
      future: AppSessionService.currentIdentity(),
      builder: (context, snapshot) {
        final identity =
            snapshot.data ??
            const SessionIdentity(
              role: AppRole.customer,
              title: 'Customer Account',
              subtitle: 'Customer browsing session',
            );

        return PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'profile') {
              onProfileTap();
            } else if (value == 'logout') {
              SessionActions.logout(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded),
                  const SizedBox(width: 10),
                  Text(_profileLabel(identity)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded),
                  SizedBox(width: 10),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
