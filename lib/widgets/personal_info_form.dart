import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class PersonalInfoForm extends StatefulWidget {
  final Function(Map<String, String>) onSaved;
  final GlobalKey<FormState> formKey;

  const PersonalInfoForm({
    super.key,
    required this.onSaved,
    required this.formKey,
  });

  @override
  State<PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _dojController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();

  String? _selectedDesignation;
  String? _selectedDepartment;

  Map<String, String> _formData = {};

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _dobController.dispose();
    _dojController.dispose();
    _panController.dispose();
    _aadharController.dispose();
    _contactController.dispose();
    _whatsappController.dispose();
    _mailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 22)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        controller.text = DateFormat('dd/MM/yyyy').format(picked);
        _updateFormData();
      });
    }
  }

  void _updateFormData() {
    _formData = {
      'name': _nameController.text.trim(),
      'designation': _selectedDesignation ?? '',
      'department': _selectedDepartment ?? '',
      'age': _ageController.text.trim(),
      'dateOfBirth': _dobController.text.trim(),
      'dateOfJoining': _dojController.text.trim(),
      'panNumber': _panController.text.trim(),
      'aadharNumber': _aadharController.text.trim(),
      'contactNo': _contactController.text.trim(),
      'whatsappNo': _whatsappController.text.trim(),
      'mailId': _mailController.text.trim(),
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
            'Personal Information',
            style: AppConstants.subheadingStyle,
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name'),
            validator: Validators.validateName,
          ),
          const SizedBox(height: AppConstants.paddingMedium),

          LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      // Mobile → Stack vertically
      return Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedDesignation,
            decoration: const InputDecoration(
              labelText: 'Designation',
            ),
            isExpanded: true,
            items: AppConstants.designations.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedDesignation = val;
                _updateFormData();
              });
            },
            validator: Validators.validateDesignation,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: const InputDecoration(
              labelText: 'Department',
            ),
            isExpanded: true,
            items: AppConstants.departments.map((value) {
              return DropdownMenuItem(
                value: value,
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedDepartment = val;
                _updateFormData();
              });
            },
            validator: Validators.validateDepartment,
          ),
        ],
      );
    } else {
      // Tablet/Desktop → Side by side
      return Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedDesignation,
              decoration:
                  const InputDecoration(labelText: 'Designation'),
              isExpanded: true,
              items: AppConstants.designations.map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedDesignation = val;
                  _updateFormData();
                });
              },
              validator: Validators.validateDesignation,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedDepartment,
              decoration:
                  const InputDecoration(labelText: 'Department'),
              isExpanded: true,
              items: AppConstants.departments.map((value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedDepartment = val;
                  _updateFormData();
                });
              },
              validator: Validators.validateDepartment,
            ),
          ),
        ],
      );
    }
  },
),
          const SizedBox(height: AppConstants.paddingMedium),

          LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return Column(
        children: [
          TextFormField(
            controller: _ageController,
            decoration:
                const InputDecoration(labelText: 'Age'),
            keyboardType: TextInputType.number,
            validator: Validators.validateAge,
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          TextFormField(
            controller: _dobController,
            decoration: const InputDecoration(
              labelText: 'Date of Birth (DD/MM/YYYY)',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () => _selectDate(context, _dobController),
            validator: Validators.validateDate,
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _ageController,
              decoration:
                  const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              validator: Validators.validateAge,
            ),
          ),
          const SizedBox(width: AppConstants.paddingMedium),
          Expanded(
            child: TextFormField(
              controller: _dobController,
              decoration: const InputDecoration(
                labelText: 'Date of Birth (DD/MM/YYYY)',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _dobController),
              validator: Validators.validateDate,
            ),
          ),
        ],
      );
    }
  },
),

          const SizedBox(height: AppConstants.paddingMedium),

          TextFormField(
            controller: _dojController,
            decoration: const InputDecoration(
              labelText: 'Date of Joining (DD/MM/YYYY)',
              suffixIcon: Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () => _selectDate(context, _dojController),
            validator: (val) =>
                Validators.validateJoiningDate(val, _dobController.text),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          TextFormField(
            controller: _panController,
            decoration:
                const InputDecoration(labelText: 'PAN Number'),
            validator: Validators.validatePAN,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          TextFormField(
            controller: _aadharController,
            decoration:
                const InputDecoration(labelText: 'Aadhar Number'),
            keyboardType: TextInputType.number,
            validator: Validators.validateAadhar,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          TextFormField(
            controller: _contactController,
            decoration:
                const InputDecoration(labelText: 'Contact Number'),
            keyboardType: TextInputType.phone,
            validator: Validators.validatePhoneNumber,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          TextFormField(
            controller: _whatsappController,
            decoration:
                const InputDecoration(labelText: 'WhatsApp Number'),
            keyboardType: TextInputType.phone,
            validator: Validators.validatePhoneNumber,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          TextFormField(
            controller: _mailController,
            decoration:
                const InputDecoration(labelText: 'Email ID'),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
          ),
        ],
      ),
    );
  }
}