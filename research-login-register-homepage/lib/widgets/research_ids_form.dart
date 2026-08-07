import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class ResearchIDsForm extends StatefulWidget {
  final Function(Map<String, String>) onSaved;
  final GlobalKey<FormState> formKey;

  const ResearchIDsForm({
    super.key,
    required this.onSaved,
    required this.formKey,
  });

  @override
  State<ResearchIDsForm> createState() => _ResearchIDsFormState();
}

class _ResearchIDsFormState extends State<ResearchIDsForm> {
  final TextEditingController _vidwanController = TextEditingController();
  final TextEditingController _scopusController = TextEditingController();
  final TextEditingController _orcidController = TextEditingController();
  final TextEditingController _scholarController = TextEditingController();

  Map<String, String> _formData = {};

  @override
  void dispose() {
    _vidwanController.dispose();
    _scopusController.dispose();
    _orcidController.dispose();
    _scholarController.dispose();
    super.dispose();
  }

  void _updateFormData() {
    _formData = {
      'vidwanId': _vidwanController.text.trim(),
      'scopusId': _scopusController.text.trim(),
      'orcidId': _orcidController.text.trim(),
      'googleScholarId': _scholarController.text.trim(),
    };
    widget.onSaved(_formData);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      onChanged: _updateFormData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Research IDs',
            style: AppConstants.subheadingStyle,
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          const Text(
            'Add your research profile identifiers (Optional)',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          TextFormField(
            controller: _vidwanController,
            decoration: const InputDecoration(
              labelText: 'Vidwan ID',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          TextFormField(
            controller: _scopusController,
            decoration: const InputDecoration(
              labelText: 'Scopus ID',
              prefixIcon: Icon(Icons.science_outlined),
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          TextFormField(
            controller: _orcidController,
            decoration: const InputDecoration(
              labelText: 'ORCID ID',
              hintText: '0000-0000-0000-0000',
              prefixIcon: Icon(Icons.fingerprint),
            ),
            validator: Validators.validateORCID,
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          TextFormField(
            controller: _scholarController,
            decoration: const InputDecoration(
              labelText: 'Google Scholar ID',
              prefixIcon: Icon(Icons.school_outlined),
            ),
          ),
        ],
      ),
    );
  }
}
