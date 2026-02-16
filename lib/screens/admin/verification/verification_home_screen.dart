import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

import 'research_verification_page.dart';
import 'fdb_verification_page.dart';
import 'profile_edit_verification_page.dart';

class VerificationHomeScreen extends StatelessWidget {
  const VerificationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 800;

          return Scaffold(
            backgroundColor: AppColors.offWhite,
            appBar: AppBar(
              title: const Text('Verification'),
              backgroundColor: AppColors.pureWhite,
              elevation: 2,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  alignment: isWide
                      ? Alignment.center
                      : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    isScrollable: !isWide,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.universityNavy.withOpacity(0.1),
                    ),
                    labelColor: AppColors.universityNavy,
                    unselectedLabelColor: AppColors.mediumGray,
                    labelStyle: AppTextStyles.label,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.article),
                        text: 'Research',
                      ),
                      Tab(
                        icon: Icon(Icons.card_membership),
                        text: 'FDB & Certificates',
                      ),
                      Tab(
                        icon: Icon(Icons.person),
                        text: 'Personal Info',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: const TabBarView(
              children: [
                ResearchVerificationPage(),
                FdbVerificationPage(),
                ProfileEditVerificationPage(),
              ],
            ),
          );
        },
      ),
    );
  }
}
