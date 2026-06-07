import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_school_unified/core/theme/app_theme.dart';
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? valueColor;
  final Color? backgroundColor;
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueColor,
    this.backgroundColor,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppTheme.ambientShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primaryIndigo).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor ?? AppTheme.primaryIndigo, size: 24.sp),
          ),
          SizedBox(height: 14.h),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: valueColor ?? AppTheme.primaryIndigo,
              fontWeight: FontWeight.w800,
              fontSize: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}
class HeroStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  const HeroStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: AppTheme.ambientShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryIndigoLight, size: 28.sp),
          SizedBox(height: 12.h),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.tealLight,
              fontWeight: FontWeight.w800,
              fontSize: 32.sp,
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}