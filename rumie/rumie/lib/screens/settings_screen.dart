import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_provider.dart';
import '../state/theme_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/ui/app_dialog.dart';
import '../widgets/ui/circle_button.dart';
import '../widgets/ui/reveal.dart';
import '../widgets/ui/screen_header.dart';
import '../widgets/ui/settings_rows.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Settings',
              compact: true,
              leading: CircleButton(
                iconAsset: 'assets/icons/ic_back.svg',
                semanticLabel: 'Back',
                onTap: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  Reveal(
                    index: 0,
                    child: SettingsGroup(
                      title: 'Appearance',
                      children: [
                        ToggleRow(
                          label: 'Dark mode',
                          subtitle: 'Easier on the eyes at night',
                          value: theme.isDark,
                          onChanged: (_) => theme.toggle(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Reveal(
                    index: 1,
                    child: SettingsGroup(
                      title: 'Discovery',
                      children: [
                        NavRow(label: 'Max distance', value: '10 miles', onTap: () {}),
                        ToggleRow(label: 'Verified only', value: false, onChanged: (_) {}),
                        NavRow(label: 'Budget filter', value: '\$800 to \$1,800', onTap: () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Reveal(
                    index: 2,
                    child: SettingsGroup(
                      title: 'Notifications',
                      children: [
                        ToggleRow(label: 'New matches', value: true, onChanged: (_) {}),
                        ToggleRow(label: 'Messages', value: true, onChanged: (_) {}),
                        ToggleRow(label: 'Listing alerts', value: false, onChanged: (_) {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Reveal(
                    index: 3,
                    child: SettingsGroup(
                      title: 'Account',
                      children: [
                        NavRow(label: 'Sign out', danger: true, onTap: () => _confirmSignOut(context, auth)),
                        NavRow(label: 'Delete account', danger: true, onTap: () => _confirmDelete(context, auth)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, AuthProvider auth) async {
    final ok = await showAppDialog(
      context,
      title: 'Sign out?',
      message: 'You can sign back in anytime.',
      confirmLabel: 'Sign out',
    );
    if (ok) auth.logout();
  }

  Future<void> _confirmDelete(BuildContext context, AuthProvider auth) async {
    final ok = await showAppDialog(
      context,
      title: 'Delete account?',
      message: 'This removes your profile and matches. It cannot be undone.',
      confirmLabel: 'Delete account',
      danger: true,
    );
    if (ok) auth.logout();
  }
}
