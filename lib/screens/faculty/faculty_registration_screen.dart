import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/auth_provider.dart';
import '../../providers/faculty_provider.dart';
import '../../models/faculty_model.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/personal_info_form.dart';
import '../../widgets/research_ids_form.dart';
import '../../widgets/work_experience_card.dart';
import '../../widgets/education_card.dart';
import 'faculty_login_screen.dart';
import 'faculty_dashboard.dart';

class FacultyRegistrationScreen extends StatefulWidget {
  const FacultyRegistrationScreen({super.key});

  @override
  State<FacultyRegistrationScreen> createState() => _FacultyRegistrationScreenState();
}

class _FacultyRegistrationScreenState extends State<FacultyRegistrationScreen> {
  final _uuid = const Uuid();
  int _currentStep = 0;
  
  // Auth Form
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  
  // Form Keys
  final _authFormKey = GlobalKey<FormState>();
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _researchIDsFormKey = GlobalKey<FormState>();
  
  // Data State
  Map<String, String> _personalInfoData = {};
  Map<String, String> _researchIDsData = {};
  final List<WorkExperience> _workExperiences = [];
  final List<EducationQualification> _educationQualifications = [];
  final TextEditingController _citExperienceController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _citExperienceController.dispose();
    super.dispose();
  }

  // Handle step navigation
  void _nextStep() {
    bool isValid = false;

    switch (_currentStep) {
      case 0: // Auth
        isValid = _authFormKey.currentState!.validate();
        if (isValid && _passwordController.text != _confirmPasswordController.text) {
          _showErrorSnackBar('Passwords do not match');
          isValid = false;
        }
        break;
      case 1: // Personal Info
        isValid = _personalInfoFormKey.currentState!.validate();
        _personalInfoFormKey.currentState!.save();
        break;
      case 2: // Research IDs
        isValid = _researchIDsFormKey.currentState!.validate();
        _researchIDsFormKey.currentState!.save();
        break;
      case 3: // Work & Education
        // Manual validation for lists
        isValid = true; // Optional sections
        break;
    }

    if (isValid) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
        });
      } else {
        _registerFaculty();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // Dialogs for Adding Dynamic Content
  void _addWorkExperience() {
    final institutionController = TextEditingController();
    final yearsController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Work Experience'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: institutionController,
                decoration: const InputDecoration(labelText: 'Institution Name'),
                validator: Validators.validateInstitution,
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              TextFormField(
                controller: yearsController,
                decoration: const InputDecoration(labelText: 'Years of Experience'),
                keyboardType: TextInputType.number,
                validator: Validators.validateYearsOfExperience,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _workExperiences.add(WorkExperience(
                    id: _uuid.v4(),
                    institutionName: institutionController.text.trim(),
                    yearsOfExperience: int.parse(yearsController.text.trim()),
                    addedAt: DateTime.now(),
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addEducation() {
    final institutionController = TextEditingController();
    final courseController = TextEditingController();
    final startYearController = TextEditingController();
    final endYearController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Qualification'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: institutionController,
                  decoration: const InputDecoration(labelText: 'Institution Name'),
                  validator: Validators.validateInstitution,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                TextFormField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: 'Course/Degree'),
                  validator: Validators.validateCourse,
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: startYearController,
                        decoration: const InputDecoration(labelText: 'Start Year'),
                        keyboardType: TextInputType.number,
                        validator: Validators.validateYear,
                      ),
                    ),
                    const SizedBox(width: AppConstants.paddingMedium),
                    Expanded(
                      child: TextFormField(
                        controller: endYearController,
                        decoration: const InputDecoration(labelText: 'End Year'),
                        keyboardType: TextInputType.number,
                        validator: (val) => Validators.validateEndYear(val, startYearController.text),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                int start = int.parse(startYearController.text.trim());
                int end = int.parse(endYearController.text.trim());
                setState(() {
                  _educationQualifications.add(EducationQualification(
                    id: _uuid.v4(),
                    institutionName: institutionController.text.trim(),
                    course: courseController.text.trim(),
                    startYear: start,
                    endYear: end,
                    duration: end - start,
                    addedAt: DateTime.now(),
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerFaculty() async {
    // Validate CIT Experience
    if (_citExperienceController.text.isEmpty) {
      _showErrorSnackBar('Please enter years in CIT');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final facultyProvider = Provider.of<FacultyProvider>(context, listen: false);

    try {
      // 1. Create Auth User
      final success = await authProvider.signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: AppConstants.roleFaculty,
      );

      if (!success) {
        if (mounted) _showErrorSnackBar(authProvider.errorMessage ?? 'Registration failed');
        return;
      }

      // 2. Prepare Data Objects
      final personalInfo = PersonalInfo(
        name: _personalInfoData['name']!,
        designation: _personalInfoData['designation']!,
        department: _personalInfoData['department']!,
        age: int.tryParse(_personalInfoData['age'] ?? '0') ?? 0,
        dateOfBirth: _personalInfoData['dateOfBirth']!,
        dateOfJoining: _personalInfoData['dateOfJoining']!,
        panNumber: _personalInfoData['panNumber']!,
        aadharNumber: _personalInfoData['aadharNumber']!,
        contactNo: _personalInfoData['contactNo']!,
        whatsappNo: _personalInfoData['whatsappNo']!,
        mailId: _personalInfoData['mailId']!,
      );

      final researchIDs = ResearchIDs(
        vidwanId: _researchIDsData['vidwanId'],
        scopusId: _researchIDsData['scopusId'],
        orcidId: _researchIDsData['orcidId'],
        googleScholarId: _researchIDsData['googleScholarId'],
      );

      final citExperience = CITExperience(
        yearsInCIT: int.tryParse(_citExperienceController.text.trim()) ?? 0,
      );

      // 3. Save to Firestore
      final dataSaved = await facultyProvider.saveFacultyData(
        userId: authProvider.currentUserId!,
        personalInfo: personalInfo,
        researchIDs: researchIDs,
        workExperiences: _workExperiences,
        citExperience: citExperience,
        educationQualifications: _educationQualifications,
      );

      if (dataSaved && mounted) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Registration Successful!'),
               backgroundColor: AppConstants.successColor,
             ),
           );
           
           Navigator.of(context).pushAndRemoveUntil(
             MaterialPageRoute(builder: (context) => const FacultyDashboard()),
             (route) => false,
           );
        }
      } else {
         if (mounted) _showErrorSnackBar('Failed to save profile data');
      }

    } catch (e) {
      if (mounted) _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final facultyProvider = Provider.of<FacultyProvider>(context);
    final isLoading = authProvider.isLoading || facultyProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Registration'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: SpinKitFadingCircle(color: AppConstants.primaryColor))
          : Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: _nextStep,
              onStepCancel: _prevStep,
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(_currentStep == 3 ? 'Register' : 'Next'),
                        ),
                      ),
                      if (_currentStep > 0) ...[
                        const SizedBox(width: AppConstants.paddingMedium),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
              steps: [
                // Step 1: Authentication
                Step(
                  title: const Text('Login Info'),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.editing,
                  content: Form(
                    key: _authFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: Validators.validatePassword,
                        ),
                        const SizedBox(height: AppConstants.paddingMedium),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: _obscurePassword,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Confirm your password';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Step 2: Personal Info
                Step(
                  title: const Text('Personal'),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.editing,
                  content: PersonalInfoForm(
                    formKey: _personalInfoFormKey,
                    onSaved: (data) => _personalInfoData = data,
                  ),
                ),

                // Step 3: Research IDs
                Step(
                  title: const Text('Research'),
                  isActive: _currentStep >= 2,
                  state: _currentStep > 2 ? StepState.complete : StepState.editing,
                  content: ResearchIDsForm(
                    formKey: _researchIDsFormKey,
                    onSaved: (data) => _researchIDsData = data,
                  ),
                ),

                // Step 4: Experience & Education
                Step(
                  title: const Text('Experience'),
                  isActive: _currentStep >= 3,
                  content: Column(
                    children: [
                      // CIT Experience
                      TextFormField(
                        controller: _citExperienceController,
                        decoration: const InputDecoration(
                          labelText: 'Years in CIT',
                          prefixIcon: Icon(Icons.business),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const Divider(height: 30),

                      // Work Experience
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Work Experience', style: AppConstants.subheadingStyle),
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                            onPressed: _addWorkExperience,
                          ),
                        ],
                      ),
                      _workExperiences.isEmpty
                          ? const Text('No experience added', style: TextStyle(color: Colors.grey))
                          : Column(
                              children: _workExperiences.map((exp) => WorkExperienceCard(
                                experience: exp,
                                onDelete: () => setState(() => _workExperiences.remove(exp)),
                              )).toList(),
                            ),
                      const Divider(height: 30),

                      // Education
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Education', style: AppConstants.subheadingStyle),
                          TextButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                            onPressed: _addEducation,
                          ),
                        ],
                      ),
                      _educationQualifications.isEmpty
                          ? const Text('No qualifications added', style: TextStyle(color: Colors.grey))
                          : Column(
                              children: _educationQualifications.map((edu) => EducationQualificationCard(
                                education: edu,
                                onDelete: () => setState(() => _educationQualifications.remove(edu)),
                              )).toList(),
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
