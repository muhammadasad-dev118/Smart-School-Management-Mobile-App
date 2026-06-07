import 'package:flutter/material.dart';
import 'package:smart_school_unified/core/theme/app_theme.dart';
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/logo.png',
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Smart School',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: AppTheme.primaryIndigo,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select your role to continue',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              _RoleCard(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Administrator',
                subtitle: 'Manage school operations',
                onTap: () => Navigator.pushNamed(context, '/login', arguments: 'admin'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.cast_for_education_rounded,
                title: 'Teacher',
                subtitle: 'Manage classes and students',
                onTap: () => Navigator.pushNamed(context, '/login', arguments: 'teacher'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.person_rounded,
                title: 'Student / Parent',
                subtitle: 'View grades and activities',
                onTap: () => Navigator.pushNamed(context, '/login', arguments: 'student'),
              ),
              const Spacer(),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'POWERED BY  ',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurfaceVariant.withValues(alpha: 0.5),
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryIndigo,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.local_fire_department, color: Colors.white, size: 12),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Firebase',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: AppTheme.ghostBorder,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryIndigo,
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}