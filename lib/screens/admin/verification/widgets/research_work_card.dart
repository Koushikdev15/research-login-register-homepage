import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class ResearchWorkCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;

  const ResearchWorkCard({
    super.key,
    required this.docId,
    required this.data,
  });

  /// 🔒 Final decision writer (single source of truth)
  Future<void> _setDecision(
    BuildContext context, {
    required String decision,
  }) async {
    await FirebaseFirestore.instance
        .collection('research_verifications')
        .doc(docId)
        .update({
      'verificationDecision': decision,
      'verifiedAt': FieldValue.serverTimestamp(),
      'verifiedBy': 'ADMIN',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked as $decision'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? decision = data['verificationDecision'];

    /// 🔐 Once decided → lock card
    final bool isLocked = decision != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Faculty header
            Row(
              children: [
                Expanded(
                  child: Text(
                    data['facultyName'] ?? 'Unknown Faculty',
                    style: AppTextStyles.h4,
                  ),
                ),
                Chip(
                  label: Text(
                    data['department'] ?? '',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            /// Work title
            Text(
              data['workTitle'] ?? 'Untitled Work',
              style: AppTextStyles.bodyRegular
                  .copyWith(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 6),

            /// Meta
            Text(
              '${data['publicationYear']} • ${_label(data['workType'])}',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.mediumGray),
            ),

            const Divider(height: 24),

            /// 🔘 FIVE DECISION BUTTONS
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _decisionButton(
                  label: 'Scopus',
                  decisionKey: 'SCOPUS',
                  activeDecision: decision,
                  locked: isLocked,
                  color: AppColors.universityNavy,
                  onTap: () => _setDecision(
                    context,
                    decision: 'SCOPUS',
                  ),
                ),
                _decisionButton(
                  label: 'SCI Journal',
                  decisionKey: 'SCI',
                  activeDecision: decision,
                  locked: isLocked,
                  color: Colors.indigo,
                  onTap: () => _setDecision(
                    context,
                    decision: 'SCI',
                  ),
                ),
                _decisionButton(
                  label: 'ISBN',
                  decisionKey: 'ISBN',
                  activeDecision: decision,
                  locked: isLocked,
                  color: Colors.teal,
                  onTap: () => _setDecision(
                    context,
                    decision: 'ISBN',
                  ),
                ),
                _decisionButton(
                  label: 'Verified',
                  decisionKey: 'VERIFIED',
                  activeDecision: decision,
                  locked: isLocked,
                  color: AppColors.successGreen,
                  onTap: () => _setDecision(
                    context,
                    decision: 'VERIFIED',
                  ),
                ),
                _decisionButton(
                  label: 'Not Verified',
                  decisionKey: 'NOT_VERIFIED',
                  activeDecision: decision,
                  locked: isLocked,
                  color: AppColors.errorRed,
                  onTap: () => _setDecision(
                    context,
                    decision: 'NOT_VERIFIED',
                  ),
                ),
              ],
            ),

            if (isLocked) ...[
              const Divider(height: 24),
              Text(
                'Final Decision: $decision',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mediumGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 🔘 Decision Button (single-select, lock-safe)
  Widget _decisionButton({
    required String label,
    required String decisionKey,
    required String? activeDecision,
    required bool locked,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isActive = activeDecision == decisionKey;

    return OutlinedButton(
      onPressed: locked ? null : onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: isActive ? color : AppColors.divider),
        backgroundColor:
            isActive ? color.withOpacity(0.12) : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? color : AppColors.mediumGray,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  static String _label(String? type) {
    switch (type) {
      case 'journal-article':
        return 'Journal';
      case 'conference-paper':
        return 'Conference';
      case 'book':
        return 'Book';
      case 'book-chapter':
        return 'Book Chapter';
      case 'patent':
        return 'Utility Patent';
      case 'design':
        return 'Design Patent';
      default:
        return 'Research';
    }
  }
}
