import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class FdbVerificationPage extends StatelessWidget {
  const FdbVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.academicBlue.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_outlined,
                  size: 56,
                  color: AppColors.academicBlue,
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                'FDB & Certificate Verification',
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                'Admin verification of faculty development activities\n'
                'including FDPs, workshops, certifications\n'
                'and other academic training programs.',
                style: AppTextStyles.bodyRegular
                    .copyWith(color: AppColors.mediumGray),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Info Card
              Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      text:
                          'Verification applies to FDPs, workshops and certificates',
                    ),
                    SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      text:
                          'Activities can be verified year-wise and category-wise',
                    ),
                    SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.verified_user_outlined,
                      text:
                          'Only Admin users can verify or reject submissions',
                    ),
                    SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.visibility_outlined,
                      text:
                          'Verification status is visible to faculty as read-only',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Coming Soon Label
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.academicBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'FDB verification workflow coming next',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.academicBlue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* =======================================================
   🔹 SMALL INFO ROW WIDGET
   ======================================================= */

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.academicBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }
}
