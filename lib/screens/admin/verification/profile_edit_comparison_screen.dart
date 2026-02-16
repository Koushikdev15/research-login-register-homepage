import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class ProfileEditComparisonScreen extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> requestData;

  const ProfileEditComparisonScreen({
    super.key,
    required this.requestId,
    required this.requestData,
  });

  @override
  Widget build(BuildContext context) {
    final facultyName =
        requestData['facultyName'] ?? 'Unknown';

    final original =
        requestData['originalDataSnapshot']
            as Map<String, dynamic>;

    final updated =
        requestData['updatedDataSnapshot']
            as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text('Profile Edit Review'),
        backgroundColor: AppColors.pureWhite,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide =
              constraints.maxWidth > 900;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  facultyName,
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 24),

                _buildSection(
                  title: "Personal Information",
                  originalData:
                      original['personalInfo'],
                  updatedData:
                      updated['personalInfo'],
                  isWide: isWide,
                ),

                _buildSection(
                  title: "Research IDs",
                  originalData:
                      original['researchIDs'],
                  updatedData:
                      updated['researchIDs'],
                  isWide: isWide,
                ),

                _buildSection(
                  title: "CIT Experience",
                  originalData:
                      original['citExperience'],
                  updatedData:
                      updated['citExperience'],
                  isWide: isWide,
                ),

                _buildSection(
                  title: "Work Experience",
                  originalData:
                      original['workExperiences'],
                  updatedData:
                      updated['workExperiences'],
                  isWide: isWide,
                ),

                _buildSection(
                  title: "Education",
                  originalData:
                      original['educationQualifications'],
                  updatedData:
                      updated['educationQualifications'],
                  isWide: isWide,
                ),

                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                                      vertical:
                                          16),
                        ),
                   onPressed: () async {
  final facultyId =
      requestData['facultyId'];

  final updated =
      requestData['updatedDataSnapshot']
          as Map<String, dynamic>;

  final firestore =
      FirebaseFirestore.instance;

  final batch = firestore.batch();

  // 🔹 Overwrite Personal Info
  batch.set(
    firestore
        .collection('users')
        .doc(facultyId)
        .collection('personalInfo')
        .doc('info'),
    updated['personalInfo'],
  );

  // 🔹 Overwrite Research IDs
  batch.set(
    firestore
        .collection('users')
        .doc(facultyId)
        .collection('researchIDs')
        .doc('ids'),
    updated['researchIDs'],
  );

  // 🔹 Overwrite CIT Experience
  batch.set(
    firestore
        .collection('users')
        .doc(facultyId)
        .collection('citExperience')
        .doc('experience'),
    updated['citExperience'],
  );

  await batch.commit();

  // 🔹 Replace Work Experience
  final workRef = firestore
      .collection('users')
      .doc(facultyId)
      .collection('workExperience');

  final oldWork =
      await workRef.get();
  for (var doc in oldWork.docs) {
    await doc.reference.delete();
  }

  for (var item
      in updated['workExperiences']) {
    await workRef.add(item);
  }

  // 🔹 Replace Education
  final eduRef = firestore
      .collection('users')
      .doc(facultyId)
      .collection('educationQualification');

  final oldEdu =
      await eduRef.get();
  for (var doc in oldEdu.docs) {
    await doc.reference.delete();
  }

  for (var item
      in updated['educationQualifications']) {
    await eduRef.add(item);
  }

  // 🔹 Update Request Status
  await firestore
      .collection('profile_edit_requests')
      .doc(requestId)
      .update({
    'status': 'APPROVED',
    'reviewedAt':
        FieldValue.serverTimestamp(),
    'reviewedBy': 'ADMIN',
  });

  if (context.mounted) {
    Navigator.pop(context);
  }
},

                        child: const Text(
                            "Approve"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                                      vertical:
                                          16),
                        ),
                        onPressed: () async {
  await FirebaseFirestore.instance
      .collection('profile_edit_requests')
      .doc(requestId)
      .update({
    'status': 'REJECTED',
    'reviewedAt': FieldValue.serverTimestamp(),
    'reviewedBy': 'ADMIN', // later replace with actual admin id
  });

  if (context.mounted) {
    Navigator.pop(context);
  }
},

                        child: const Text(
                            "Reject"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required dynamic originalData,
    required dynamic updatedData,
    required bool isWide,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyLarge
                  .copyWith(
                      fontWeight:
                          FontWeight.bold),
            ),
            const SizedBox(height: 16),

            isWide
                ? Row(
                    children: [
                      Expanded(
                        child: _buildDataBox(
                            "Original",
                            originalData),
                      ),
                      const SizedBox(
                          width: 16),
                      Expanded(
                        child: _buildDataBox(
                            "Updated",
                            updatedData),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildDataBox(
                          "Original",
                          originalData),
                      const SizedBox(
                          height: 16),
                      _buildDataBox(
                          "Updated",
                          updatedData),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBox(
      String label, dynamic data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
            color: AppColors.mediumGray),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                fontWeight:
                    FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            data.toString(),
            style:
                const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
