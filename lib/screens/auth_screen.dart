import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/logo.dart';

/// Matches `AuthScreen`: the logo centred in the upper area, and a docked
/// panel (full-width tabs + form) pinned to the bottom.
///
/// Transitions mirror the prototype's CSS:
///  * `.auth-form-transition`  - form fades/slides up 6px on entry (380ms)
///  * `.auth-tab`              - tab underline/text colour cross-fade (200ms)
///  * `.auth-signup-row`       - full-name row expands/collapses + fades (380ms)
///  * `.auth-primary-action-content` - button label re-enters on mode change (460ms)
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.go});
  final GoTo go;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _signup = false;
  bool _showPassword = false;

  static const _ease = Curves.ease; // CSS `ease`
  static const _outExpo = Cubic(0.22, 1, 0.36, 1);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const Expanded(
                    child: Center(child: Logo(size: LogoSize.large, muted: true)),
                  ),
                  _panel(),
                  const SizedBox(height: 32), // pb-8
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _panel() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          _tabs(),
          // .auth-form-transition: opacity 0->1, translateY 6px->0, 380ms ease-out
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOut,
            builder: (context, t, child) => Opacity(
              opacity: t,
              child: Transform.translate(offset: Offset(0, 6 * (1 - t)), child: child),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: _form(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return SizedBox(
      height: 57, // 56 + bottom border
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                Expanded(child: _tab('Sign in', !_signup, () => setState(() => _signup = false))),
                Expanded(child: _tab('Create account', _signup, () => setState(() => _signup = true))),
              ],
            ),
          ),
          // centre divider
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(child: SizedBox(width: 1, child: ColoredBox(color: AppColors.border, child: SizedBox.expand()))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: _ease,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: active ? AppColors.foreground : Colors.transparent, width: 2)),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          curve: _ease,
          style: AppText.sans(
            size: 12,
            weight: FontWeight.w500,
            color: active ? AppColors.foreground : AppColors.mutedForeground,
          ),
          child: Text(label.toUpperCase()),
        ),
      ),
    );
  }

  Widget _form() {
    return Column(
      children: [
        // .auth-signup-row: grid-template-rows 0fr <-> 1fr + opacity, 380ms ease
        TweenAnimationBuilder<double>(
          tween: Tween(end: _signup ? 1.0 : 0.0),
          duration: const Duration(milliseconds: 380),
          curve: _ease,
          builder: (context, t, child) => ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: t,
              child: Opacity(opacity: t, child: child),
            ),
          ),
          child: const AppField(icon: Icons.person, label: 'Full name', initialValue: 'Muhammad Umar'),
        ),
        const SizedBox(height: 10),
        const AppField(icon: Icons.phone, label: 'Phone number', initialValue: '+92 300 1234567'),
        const SizedBox(height: 10),
        AppField(
          icon: Icons.lock,
          label: 'Password',
          initialValue: _showPassword ? 'smartrep26' : '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
          suffix: IconButton(
            tooltip: _showPassword ? 'Hide password' : 'Show password',
            icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 18, color: AppColors.mutedForeground),
            onPressed: () => setState(() => _showPassword = !_showPassword),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          onPressed: () => widget.go(AppScreen.scan),
          // key on mode => re-runs the entrance animation each time the label changes
          child: TweenAnimationBuilder<double>(
            key: ValueKey(_signup),
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 460),
            curve: _outExpo,
            builder: (context, t, child) {
              final blur = 2 * (1 - t);
              Widget content = Transform.translate(
                offset: Offset(0, 4 * (1 - t)),
                child: Transform.scale(scale: 0.985 + 0.015 * t, child: child),
              );
              if (blur > 0.05) {
                content = ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur), child: content);
              }
              return content;
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_signup ? 'Create account' : 'Continue'),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "By continuing, you agree to SmartRep's Terms and Privacy Policy.",
          textAlign: TextAlign.center,
          style: AppText.sans(size: 11, color: AppColors.mutedForeground),
        ),
      ],
    );
  }
}
