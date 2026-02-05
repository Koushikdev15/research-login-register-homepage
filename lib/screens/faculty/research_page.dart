import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ResearchPage extends StatelessWidget {
  const ResearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science_outlined,
            size: 80,
            color: AppConstants.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          const Text(
            'Research Module',
            style: AppConstants.headingStyle,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          const Text(
            'Coming Soon',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
