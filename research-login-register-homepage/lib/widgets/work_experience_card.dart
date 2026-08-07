import 'package:flutter/material.dart';
import '../models/faculty_model.dart';
import '../utils/constants.dart';

class WorkExperienceCard extends StatelessWidget {
  final WorkExperience experience;
  final VoidCallback? onDelete;
  final bool isReadOnly;

  const WorkExperienceCard({
    super.key,
    required this.experience,
    this.onDelete,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConstants.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.work_outline,
                color: AppConstants.secondaryColor,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience.institutionName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${experience.yearsOfExperience} years',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!isReadOnly && onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Remove',
              ),
          ],
        ),
      ),
    );
  }
}
