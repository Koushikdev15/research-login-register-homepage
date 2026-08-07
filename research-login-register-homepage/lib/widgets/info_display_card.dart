import 'package:flutter/material.dart';
import '../utils/constants.dart';

class InfoDisplayCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final bool initiallyExpanded;

  const InfoDisplayCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppConstants.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        childrenPadding: const EdgeInsets.all(AppConstants.paddingMedium),
        children: [
          child,
        ],
      ),
    );
  }
}
