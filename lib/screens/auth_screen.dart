import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/logo.dart';

/// Matches `AuthScreen`: sign-in / create-account tabs over a form, with the
/// SmartRep mark pinned above.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.go});
  final GoTo go;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _signup = false;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Logo(size: LogoSize.large),
          const SizedBox(height: 36),
          Text(
            'Your strongest rep starts here.',
            textAlign: TextAlign.center,
            style: AppText.sans(size: 13, weight: FontWeight.w700, color: AppColors.mutedForeground),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _tab('Sign in', !_signup, () => setState(() => _signup = false))),
              Expanded(child: _tab('Create account', _signup, () => setState(() => _signup = true))),
            ],
          ),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),
          if (_signup) ...[
            const AppField(icon: Icons.person, label: 'Full name', initialValue: 'Muhammad Umar'),
            const SizedBox(height: 10),
          ],
          const AppField(icon: Icons.phone, label: 'Phone number', initialValue: '+92 300 1234567'),
          const SizedBox(height: 10),
          AppField(
            icon: Icons.lock,
            label: 'Password',
            initialValue: _showPassword ? 'smartrep26' : '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
            suffix: IconButton(
              icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.mutedForeground),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            onPressed: () => widget.go(AppScreen.scan),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_signup ? 'Create account' : 'Continue'),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "By continuing, you agree to SmartRep's Terms and Privacy Policy.",
            textAlign: TextAlign.center,
            style: AppText.sans(size: 11, color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: active ? AppColors.foreground : Colors.transparent, width: 2)),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppText.sans(size: 12, weight: FontWeight.w700, color: active ? AppColors.foreground : AppColors.mutedForeground),
        ),
      ),
    );
  }
}
