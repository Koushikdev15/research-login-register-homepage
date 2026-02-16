import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../providers/auth_provider.dart';

class ResearchWorkCard extends StatelessWidget {
  final String facultyId;
  final String year;
  final String workType;
  final String putCode;
  final Map<String, dynamic> data;

  const ResearchWorkCard({
    super.key,
    required this.facultyId,
    required this.year,
    required this.workType,
    required this.putCode,
    required this.data,
  });

  /// 🔹 Root reference
  DocumentReference get _rootRef => FirebaseFirestore.instance
      .collection('research_verifications_tree')
      .doc(facultyId);

  /// 🔹 Work reference
  DocumentReference get _workRef => _rootRef
      .collection('years')
      .doc(year)
      .collection('workTypes')
      .doc(workType)
      .collection('works')
      .doc(putCode);

  /// 🔹 VERIFIED with type
  Future<void> _verifyWithType(
    BuildContext context, {
    required String type,
  }) async {
    final auth = context.read<AuthProvider>();
    final adminId = auth.currentUserId;
    if (adminId == null) return;

    await _workRef.update({
      'verificationStatus': 'VERIFIED',
      'verificationType': type,
      'verifiedAt': FieldValue.serverTimestamp(),
      'verifiedBy': adminId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked as VERIFIED ($type)'),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  /// 🔹 NOT VERIFIED
  Future<void> _markNotVerified(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final adminId = auth.currentUserId;
    if (adminId == null) return;

    await _workRef.update({
      'verificationStatus': 'NOT_VERIFIED',
      'verificationType': null,
      'verifiedAt': FieldValue.serverTimestamp(),
      'verifiedBy': adminId,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Marked as NOT VERIFIED'),
        backgroundColor: AppColors.errorRed,
      ),
    );
  }

  /// 🔹 Reset to PENDING
  Future<void> _resetToPending(BuildContext context) async {
    await _workRef.update({
      'verificationStatus': 'PENDING',
      'verificationType': null,
      'verifiedAt': null,
      'verifiedBy': null,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to PENDING'),
        backgroundColor: AppColors.universityNavy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _workRef.snapshots(), // 🔥 LIVE LISTENING
      builder: (context, workSnapshot) {
        final workData =
            workSnapshot.data?.data() as Map<String, dynamic>? ?? data;

        final String status =
            workData['verificationStatus'] ?? 'PENDING';

        final String? type =
            workData['verificationType'];

        final bool isLocked = status != 'PENDING';

        return StreamBuilder<DocumentSnapshot>(
          stream: _rootRef.snapshots(),
          builder: (context, rootSnapshot) {
            final rootData =
                rootSnapshot.data?.data() as Map<String, dynamic>?;

            final facultyName =
                rootData?['facultyName'] ?? 'Unknown Faculty';

            final department =
                rootData?['department'] ?? '';

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

                    /// 🔹 Faculty Header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            facultyName,
                            style: AppTextStyles.h4,
                          ),
                        ),
                        if (department.isNotEmpty)
                          Chip(
                            label: Text(
                              department,
                              style: AppTextStyles.caption,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    /// 🔹 Work Title
                    Text(
                      workData['workTitle'] ?? 'Untitled Work',
                      style: AppTextStyles.bodyRegular
                          .copyWith(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 6),

                    /// 🔹 Meta
                    Text(
                      '$year • ${_label(workType)}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.mediumGray),
                    ),

                    const Divider(height: 24),

                    /// 🔹 Verification Type Buttons
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        _verifyButton(
                          label: 'SCOPUS',
                          active: type == 'SCOPUS',
                          locked: isLocked,
                          color: AppColors.universityNavy,
                          onTap: () =>
                              _verifyWithType(context, type: 'SCOPUS'),
                        ),
                        _verifyButton(
                          label: 'SCI',
                          active: type == 'SCI',
                          locked: isLocked,
                          color: Colors.indigo,
                          onTap: () =>
                              _verifyWithType(context, type: 'SCI'),
                        ),
                        _verifyButton(
                          label: 'ISBN',
                          active: type == 'ISBN',
                          locked: isLocked,
                          color: Colors.teal,
                          onTap: () =>
                              _verifyWithType(context, type: 'ISBN'),
                        ),
                        _verifyButton(
                          label: 'PATENT',
                          active: type == 'PATENT',
                          locked: isLocked,
                          color: Colors.deepPurple,
                          onTap: () =>
                              _verifyWithType(context, type: 'PATENT'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// 🔹 Not Verified Button
                    _statusButton(
                      label: 'Not Verified',
                      active: status == 'NOT_VERIFIED',
                      locked: isLocked,
                      color: AppColors.errorRed,
                      onTap: () => _markNotVerified(context),
                    ),

                    if (isLocked) ...[
                      const Divider(height: 24),

                      Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: status == 'VERIFIED'
        ? Colors.green.shade100
        : Colors.red.shade100,
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text(
    'Final Status: $status',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      color: status == 'VERIFIED'
          ? Colors.green.shade800
          : Colors.red.shade800,
    ),
  ),
),


                      if (type != null)
                        Text(
                          'Type: $type',
                          style: AppTextStyles.caption,
                        ),

                      const SizedBox(height: 4),

                      Text(
                        'Verified By: ${workData['verifiedBy'] ?? 'N/A'}',
                        style: AppTextStyles.caption,
                      ),

                      const SizedBox(height: 12),

                      /// 🔹 Edit Button
                      OutlinedButton(
                        onPressed: () => _resetToPending(context),
                        child: const Text('Edit'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _verifyButton({
  required String label,
  required bool active,
  required bool locked,
  required Color color,
  required VoidCallback onTap,
}) {
  final bool disabled = locked && !active;

  return ElevatedButton(
    onPressed: locked ? null : onTap,
    style: ElevatedButton.styleFrom(
      elevation: active ? 4 : 0,
      backgroundColor: active
          ? color
          : disabled
              ? Colors.grey.shade300
              : Colors.grey.shade200,
      foregroundColor: active
          ? Colors.white
          : disabled
              ? Colors.grey.shade500
              : Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(label),
  );
}


  Widget _statusButton({
  required String label,
  required bool active,
  required bool locked,
  required Color color,
  required VoidCallback onTap,
}) {
  final bool disabled = locked && !active;

  return ElevatedButton(
    onPressed: locked ? null : onTap,
    style: ElevatedButton.styleFrom(
      elevation: active ? 4 : 0,
      backgroundColor: active
          ? color
          : disabled
              ? Colors.grey.shade300
              : Colors.grey.shade200,
      foregroundColor: active
          ? Colors.white
          : disabled
              ? Colors.grey.shade500
              : Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: Text(label),
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
