import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_edit_comparison_screen.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class ProfileEditVerificationPage extends StatelessWidget {
  const ProfileEditVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
stream: FirebaseFirestore.instance
    .collection('profile_edit_requests')
    .where('status', isEqualTo: 'PENDING')
    .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator());
        }

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No pending profile edit requests.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final requests = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: requests.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final doc = requests[index];
            final data =
                doc.data() as Map<String, dynamic>;

            final facultyName =
                data['facultyName'] ?? 'Unknown';
            final facultyId =
                data['facultyId'] ?? '';

            final Timestamp? requestedAtTimestamp =
                data['requestedAt'];

            String requestedDate = '';
            if (requestedAtTimestamp != null) {
              final date =
                  requestedAtTimestamp.toDate();
              requestedDate =
                  '${date.day}/${date.month}/${date.year}';
            }

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.person,
                  color: AppColors.universityNavy,
                ),
                title: Text(
                  facultyName,
                  style: AppTextStyles.bodyLarge
                      .copyWith(
                          fontWeight:
                              FontWeight.bold),
                ),
                subtitle: Text(
                  'Requested on: $requestedDate',
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ProfileEditComparisonScreen(
        requestId: doc.id,
        requestData: data,
      ),
    ),
  );
},

              ),
            );
          },
        );
      },
    );
  }
}
