import 'package:flutter/material.dart';
import '../models/faculty_model.dart';
import '../utils/constants.dart';

class WorkExperienceCard extends StatelessWidget {

  final WorkExperience experience;

  /// callbacks
  final Function(WorkExperience)? onEdit;
  final Function(String)? onDelete;

  final bool isReadOnly;

  const WorkExperienceCard({
    super.key,
    required this.experience,
    this.onEdit,
    this.onDelete,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(
        bottom: AppConstants.paddingMedium,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),

      child: Padding(
        padding: const EdgeInsets.all(
          AppConstants.paddingMedium,
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            /// LEFT ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConstants.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.work_outline,
                color: AppConstants.secondaryColor,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            /// EXPERIENCE DETAILS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Organization Name
                  Text(
                    experience.institutionName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  /// Years
                  Row(
                    children: [

                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        "${experience.yearsOfExperience} years",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),

            /// 3 DOT MENU
            if (!isReadOnly)
              PopupMenuButton<String>(

                icon: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),

                onSelected: (value) {

                  switch (value) {

                    case "edit":
                      if (onEdit != null) {
                        onEdit!(experience);
                      }
                      break;

                    case "delete":
                      if (onDelete != null) {
                        onDelete!(experience.id);
                      }
                      break;

                  }
                },

                itemBuilder: (context) => const [

                  PopupMenuItem(
                    value: "edit",
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text("Edit"),
                      ],
                    ),
                  ),

                  PopupMenuItem(
                    value: "delete",
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18),
                        SizedBox(width: 8),
                        Text("Delete"),
                      ],
                    ),
                  ),

                ],
              ),

          ],
        ),
      ),
    );
  }
}

