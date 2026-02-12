import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

import 'research_verification_page.dart';
import 'fdb_verification_page.dart';

class VerificationHomeScreen extends StatelessWidget {
  const VerificationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        appBar: AppBar(
          title: const Text('Verification'),
          backgroundColor: AppColors.pureWhite,
          elevation: 2,
          bottom: const TabBar(
            indicatorColor: AppColors.universityNavy,
            labelColor: AppColors.universityNavy,
            unselectedLabelColor: AppColors.mediumGray,
            tabs: [
              Tab(
                icon: Icon(Icons.article),
                text: 'Research',
              ),
              Tab(
                icon: Icon(Icons.card_membership),
                text: 'FDB & Certificates',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ResearchVerificationPage(),
            FdbVerificationPage(),
          ],
        ),
      ),
    );
  }
}
