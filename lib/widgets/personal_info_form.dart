import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';

class PersonalInfoForm extends StatefulWidget {
  final Function(Map<String, String>) onSaved;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final Map<String, String>? initialData;

  const PersonalInfoForm({
    super.key,
    required this.onSaved,
    required this.formKey,
    required this.emailController,
    this.initialData,
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

  String? _selectedDesignation;
  String? _selectedDepartment;

  Map<String, String> _formData = {};

  @override
  void initState() {
    super.initState();

    if (widget.initialData != null) {
      _nameController.text = widget.initialData!['name'] ?? '';
      _ageController.text = widget.initialData!['age'] ?? '';
      _dobController.text = widget.initialData!['dateOfBirth'] ?? '';
      _dojController.text = widget.initialData!['dateOfJoining'] ?? '';
      _panController.text = widget.initialData!['panNumber'] ?? '';
      _aadharController.text = widget.initialData!['aadharNumber'] ?? '';
      _contactController.text = widget.initialData!['contactNo'] ?? '';
      _whatsappController.text = widget.initialData!['whatsappNo'] ?? '';

      _selectedDesignation = widget.initialData!['designation'];
      _selectedDepartment = widget.initialData!['department'];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFormData();
    });
  }

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
    super.dispose();
  }

  /// DATE PICKER
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

  /// UPDATE DATA
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
      'mailId': widget.emailController.text.trim(),
    };

    widget.onSaved(_formData);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
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

          /// NAME
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Full Name'),
            validator: Validators.validateName,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          /// DESIGNATION
          DropdownButtonFormField<String>(
            value: _selectedDesignation,
            decoration: _inputDecoration('Designation'),
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

          /// DEPARTMENT
          DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: _inputDecoration('Department'),
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

          const SizedBox(height: AppConstants.paddingMedium),

          /// AGE
          TextFormField(
            controller: _ageController,
            decoration: _inputDecoration('Age'),
            keyboardType: TextInputType.number,
            validator: Validators.validateAge,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          /// DOB
          TextFormField(
            controller: _dobController,
            readOnly: true,
            decoration: _inputDecoration('Date of Birth (DD/MM/YYYY)')
                .copyWith(suffixIcon: const Icon(Icons.calendar_today)),
            onTap: () => _selectDate(context, _dobController),
            validator: Validators.validateDate,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          /// DOJ
          TextFormField(
            controller: _dojController,
            readOnly: true,
            decoration: _inputDecoration('Date of Joining (DD/MM/YYYY)')
                .copyWith(suffixIcon: const Icon(Icons.calendar_today)),
            onTap: () => _selectDate(context, _dojController),
            validator: (val) =>
                Validators.validateJoiningDate(val, _dobController.text),
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          /// PAN
          TextFormField(
            controller: _panController,
            decoration: _inputDecoration('PAN Number'),
            validator: Validators.validatePAN,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          /// AADHAR
          TextFormField(
            controller: _aadharController,
            decoration: _inputDecoration('Aadhar Number'),
            keyboardType: TextInputType.number,
            validator: Validators.validateAadhar,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          /// CONTACT
          TextFormField(
            controller: _contactController,
            decoration: _inputDecoration('Contact Number'),
            keyboardType: TextInputType.phone,
            validator: Validators.validatePhoneNumber,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          /// WHATSAPP
          TextFormField(
            controller: _whatsappController,
            decoration: _inputDecoration('WhatsApp Number'),
            keyboardType: TextInputType.phone,
            validator: Validators.validatePhoneNumber,
          ),

          const SizedBox(height: AppConstants.paddingMedium),

          /// EMAIL
          TextFormField(
            controller: widget.emailController,
            readOnly: true,
            decoration: _inputDecoration('Email ID')
                .copyWith(prefixIcon: const Icon(Icons.email)),
          ),
        ],
      ),
    );
  }
}