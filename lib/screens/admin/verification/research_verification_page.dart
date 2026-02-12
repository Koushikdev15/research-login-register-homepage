import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import 'widgets/research_work_card.dart';
import '../../../services/research_verification_seeder.dart';

class ResearchVerificationPage extends StatefulWidget {
  const ResearchVerificationPage({super.key});

  @override
  State<ResearchVerificationPage> createState() =>
      _ResearchVerificationPageState();
}

class _ResearchVerificationPageState extends State<ResearchVerificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSyncing = false;

  final List<_WorkFilter> _filters = const [
    _WorkFilter('All', null),
    _WorkFilter('Journal', 'journal-article'),
    _WorkFilter('Conference', 'conference-paper'),
    _WorkFilter('Utility Patent', 'patent'),
    _WorkFilter('Design Patent', 'design'),
    _WorkFilter('Book', 'book'),
    _WorkFilter('Book Chapter', 'book-chapter'),
  ];

  int get _currentYear => DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 🔄 Manual admin-triggered sync
  Future<void> _syncCurrentYearWorks() async {
    setState(() => _isSyncing = true);

    try {
      await ResearchVerificationSeeder.seedCurrentYearIfNeeded();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Current year research works synced successfully'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sync failed: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// 🔹 Sync + Filter Bar
        Container(
          color: AppColors.pureWhite,
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: AppColors.universityNavy,
                  labelColor: AppColors.universityNavy,
                  unselectedLabelColor: AppColors.mediumGray,
                  tabs: _filters.map((f) => Tab(text: f.label)).toList(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isSyncing ? null : _syncCurrentYearWorks,
                icon: _isSyncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(
                  _isSyncing ? 'Syncing...' : 'Sync $_currentYear',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.universityNavy,
                ),
              ),
            ],
          ),
        ),

        /// 🔹 Data View
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('research_verifications')
                .where('publicationYear', isEqualTo: _currentYear)
                .where('verificationStatus', isEqualTo: 'PENDING')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.universityNavy,
                  ),
                );
              }

              if (snapshot.hasError) {
                return _ErrorState(
                  message: snapshot.error.toString(),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const _EmptyState();
              }

              return TabBarView(
                controller: _tabController,
                children: _filters.map((filter) {
                  final filteredDocs = filter.workType == null
                      ? docs
                      : docs.where((d) {
                          final data =
                              d.data() as Map<String, dynamic>;
                          return data['workType'] == filter.workType;
                        }).toList();

                  if (filteredDocs.isEmpty) {
                    return const _EmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data =
                          doc.data() as Map<String, dynamic>;

                      return ResearchWorkCard(
                        docId: doc.id,
                        data: data,
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}

/* =======================================================
   🔹 FILTER MODEL
   ======================================================= */

class _WorkFilter {
  final String label;
  final String? workType;

  const _WorkFilter(this.label, this.workType);
}

/* =======================================================
   🔹 EMPTY STATE
   ======================================================= */

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 64, color: AppColors.mediumGray),
          const SizedBox(height: 12),
          Text(
            'No pending verification works',
            style: AppTextStyles.bodyRegular
                .copyWith(color: AppColors.mediumGray),
          ),
        ],
      ),
    );
  }
}

/* =======================================================
   🔹 ERROR STATE
   ======================================================= */

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style:
            AppTextStyles.bodyRegular.copyWith(color: AppColors.errorRed),
      ),
    );
  }
}
