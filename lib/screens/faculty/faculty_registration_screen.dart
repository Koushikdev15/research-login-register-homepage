import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/faculty_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/faculty_provider.dart';
import '../../services/drive_service.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/personal_info_form.dart';
import '../../widgets/research_ids_form.dart';
import 'faculty_dashboard.dart';

class FacultyRegistrationScreen extends StatefulWidget {
  const FacultyRegistrationScreen({super.key});

  @override
  State<FacultyRegistrationScreen> createState() =>
      _FacultyRegistrationScreenState();
}

class _FacultyRegistrationScreenState
    extends State<FacultyRegistrationScreen> {
  final _uuid = const Uuid();
  int _currentStep = 0;
  bool _isRegistering = false;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final DriveService _driveService = DriveService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  final _authFormKey = GlobalKey<FormState>();
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _researchIDsFormKey = GlobalKey<FormState>();

  Map<String, String> _personalInfoData = {};
  Map<String, String> _researchIDsData = {};

  final List<WorkExperience> _workExperiences = [];
  final List<EducationQualification> _educationQualifications = [];

  final TextEditingController _citExperienceController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _citExperienceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    bool isValid = false;

    switch (_currentStep) {
      case 0:
        isValid = _authFormKey.currentState!.validate();
        break;
      case 1:
        isValid = _personalInfoFormKey.currentState!.validate();
        _personalInfoFormKey.currentState!.save();
        break;
      case 2:
        isValid = _researchIDsFormKey.currentState!.validate();
        _researchIDsFormKey.currentState!.save();
        break;
      case 3:
        isValid = true;
        break;
    }

    if (isValid) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _registerFaculty();
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }
    // ==============================
  // IMAGE PICK
  // ==============================

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // ==============================
  // WORK EXPERIENCE DIALOG
  // ==============================

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
                decoration:
                    const InputDecoration(labelText: 'Institution Name'),
                validator: Validators.validateInstitution,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: yearsController,
                decoration:
                    const InputDecoration(labelText: 'Years of Experience'),
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
                  _workExperiences.add(
                    WorkExperience(
                      id: _uuid.v4(),
                      institutionName:
                          institutionController.text.trim(),
                      yearsOfExperience:
                          int.parse(yearsController.text.trim()),
                      addedAt: DateTime.now(),
                    ),
                  );
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

  // ==============================
  // EDUCATION DIALOG
  // ==============================

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
                  decoration:
                      const InputDecoration(labelText: 'Institution Name'),
                  validator: Validators.validateInstitution,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: courseController,
                  decoration:
                      const InputDecoration(labelText: 'Course/Degree'),
                  validator: Validators.validateCourse,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: startYearController,
                        decoration:
                            const InputDecoration(labelText: 'Start Year'),
                        keyboardType: TextInputType.number,
                        validator: Validators.validateYear,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: endYearController,
                        decoration:
                            const InputDecoration(labelText: 'End Year'),
                        keyboardType: TextInputType.number,
                        validator: (val) =>
                            Validators.validateEndYear(
                                val, startYearController.text),
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
                int start =
                    int.parse(startYearController.text.trim());
                int end =
                    int.parse(endYearController.text.trim());

                setState(() {
                  _educationQualifications.add(
                    EducationQualification(
                      id: _uuid.v4(),
                      institutionName:
                          institutionController.text.trim(),
                      course: courseController.text.trim(),
                      startYear: start,
                      endYear: end,
                      duration: end - start,
                      addedAt: DateTime.now(),
                    ),
                  );
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
    // ==============================
  // REGISTER FACULTY
  // ==============================

  Future<void> _registerFaculty() async {
    setState(() {
      _isRegistering = true;
    });

    if (_citExperienceController.text.isEmpty) {
      setState(() {
        _isRegistering = false;
      });
      _showErrorSnackBar('Please enter years in CIT');
      return;
    }

    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    final facultyProvider =
        Provider.of<FacultyProvider>(context, listen: false);

    try {
      // 1️⃣ Create Auth User
      final success =
          await authProvider.signUpWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: AppConstants.roleFaculty,
      );

      if (!success) {
        if (mounted) {
          _showErrorSnackBar(
              authProvider.errorMessage ??
                  'Registration failed');
        }
        return;
      }

      // 2️⃣ Upload Profile Photo (Optional)
      if (_selectedImage != null) {
        String? fileId =
            await _driveService.uploadFile(
          file: _selectedImage!,
          folderName: "profile_pictures",
        );

        if (fileId != null) {
          String imageUrl =
              "https://drive.google.com/uc?export=view&id=$fileId";

          await authProvider
              .updateProfilePicture(imageUrl);
        }
      }

      // 3️⃣ Prepare Data
      final personalInfo = PersonalInfo(
        name: _personalInfoData['name'] ?? '',
        designation:
            _personalInfoData['designation'] ?? '',
        department:
            _personalInfoData['department'] ?? '',
        age: int.tryParse(
                _personalInfoData['age'] ?? '0') ??
            0,
        dateOfBirth:
            _personalInfoData['dateOfBirth'] ?? '',
        dateOfJoining:
            _personalInfoData['dateOfJoining'] ?? '',
        panNumber:
            _personalInfoData['panNumber'] ?? '',
        aadharNumber:
            _personalInfoData['aadharNumber'] ?? '',
        contactNo:
            _personalInfoData['contactNo'] ?? '',
        whatsappNo:
            _personalInfoData['whatsappNo'] ?? '',
        mailId:
            _personalInfoData['mailId'] ?? '',
      );

      final researchIDs = ResearchIDs(
        vidwanId:
            _researchIDsData['vidwanId'],
        scopusId:
            _researchIDsData['scopusId'],
        orcidId:
            _researchIDsData['orcidId'],
        googleScholarId:
            _researchIDsData['googleScholarId'],
      );

      final citExperience =
          CITExperience.fromDateOfJoining(
        _personalInfoData['dateOfJoining'] ?? '',
      );

      // 4️⃣ Save to Firestore
      final dataSaved =
          await facultyProvider.saveFacultyData(
        userId: authProvider.currentUserId!,
        personalInfo: personalInfo,
        researchIDs: researchIDs,
        workExperiences: _workExperiences,
        citExperience: citExperience,
        educationQualifications:
            _educationQualifications,
      );

      if (dataSaved && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text('Registration Successful!'),
            backgroundColor:
                AppColors.successGreen,
          ),
        );

        Navigator.of(context)
            .pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) =>
                  const FacultyDashboard()),
          (route) => false,
        );
      } else {
        if (mounted) {
          _showErrorSnackBar(
              'Failed to save profile data');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }

  // ==============================
  // ERROR SNACKBAR
  // ==============================

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            AppColors.errorRed,
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
    // ==============================
  // BUILD UI
  // ==============================

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final facultyProvider = Provider.of<FacultyProvider>(context);

    final isLoading =
        authProvider.isLoading || facultyProvider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Faculty Registration'),
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.universityNavy,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [

          // ======================
          // MAIN CONTENT
          // ======================

          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Stepper(
                  type: StepperType.vertical, // 🔥 FIXED OVERFLOW
                  currentStep: _currentStep,
                  onStepContinue:
                      _isRegistering ? null : _nextStep,
                  onStepCancel:
                      _isRegistering ? null : _prevStep,
                  controlsBuilder:
                      (context, details) {
                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 24),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          if (_currentStep > 0)
                            TextButton(
                              onPressed:
                                  details.onStepCancel,
                              child:
                                  const Text("Back"),
                            ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed:
                                details.onStepContinue,
                            child: Text(
                              _currentStep == 3
                                  ? "Register"
                                  : "Next",
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  steps: [

                    // ======================
                    // STEP 1: ACCOUNT
                    // ======================

                    Step(
                      title: const Text("Account"),
                      isActive: _currentStep >= 0,
                      content: SingleChildScrollView(
                        child: Form(
                          key: _authFormKey,
                          child: Column(
                            children: [

                              // EMAIL
                              TextFormField(
                                controller:
                                    _emailController,
                                decoration:
                                    const InputDecoration(
                                  labelText:
                                      "Email Address",
                                  prefixIcon: Icon(
                                      Icons.email),
                                ),
                                keyboardType:
                                    TextInputType
                                        .emailAddress,
                                validator: Validators
                                    .validateEmail,
                              ),
                              const SizedBox(
                                  height: 16),

                              // PASSWORD (6 CHAR ONLY)
                              TextFormField(
                                controller:
                                    _passwordController,
                                obscureText:
                                    _obscurePassword,
                                decoration:
                                    InputDecoration(
                                  labelText:
                                      "Password",
                                  prefixIcon:
                                      const Icon(
                                          Icons.lock),
                                  suffixIcon:
                                      IconButton(
                                    icon: Icon(
                                        _obscurePassword
                                            ? Icons
                                                .visibility_off
                                            : Icons
                                                .visibility),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword =
                                            !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty) {
                                    return "Password required";
                                  }
                                  if (value.length <
                                      6) {
                                    return "Minimum 6 characters";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(
                                  height: 16),

                              // CONFIRM PASSWORD
                              TextFormField(
                                controller:
                                    _confirmPasswordController,
                                obscureText:
                                    _obscurePassword,
                                decoration:
                                    const InputDecoration(
                                  labelText:
                                      "Confirm Password",
                                  prefixIcon:
                                      Icon(Icons.lock),
                                ),
                                validator:
                                    (value) {
                                  if (value == null ||
                                      value.isEmpty) {
                                    return "Confirm your password";
                                  }
                                  if (value !=
                                      _passwordController
                                          .text) {
                                    return "Passwords do not match";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ======================
                    // STEP 2: PERSONAL
                    // ======================

                    Step(
                      title:
                          const Text("Personal"),
                      isActive: _currentStep >= 1,
                      content:
                          SingleChildScrollView(
                        child: Column(
                          children: [

                            GestureDetector(
                              onTap:
                                  _pickProfileImage,
                              child:
                                  CircleAvatar(
                                radius: 50,
                                backgroundColor:
                                    Colors.grey[300],
                                backgroundImage:
                                    _selectedImage !=
                                            null
                                        ? FileImage(
                                            _selectedImage!)
                                        : null,
                                child:
                                    _selectedImage ==
                                            null
                                        ? const Icon(
                                            Icons
                                                .camera_alt,
                                            size: 40)
                                        : null,
                              ),
                            ),
                            const SizedBox(
                                height: 8),
                            const Text(
                                "Profile Photo (Optional)"),
                            const SizedBox(
                                height: 24),

                            PersonalInfoForm(
                              formKey:
                                  _personalInfoFormKey,
                              onSaved:
                                  (data) =>
                                      _personalInfoData =
                                          data,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ======================
                    // STEP 3: RESEARCH
                    // ======================

                    Step(
                      title:
                          const Text("Research"),
                      isActive: _currentStep >= 2,
                      content:
                          SingleChildScrollView(
                        child: ResearchIDsForm(
                          formKey:
                              _researchIDsFormKey,
                          onSaved:
                              (data) =>
                                  _researchIDsData =
                                      data,
                        ),
                      ),
                    ),

                    // ======================
                    // STEP 4: EXPERIENCE
                    // ======================

                    Step(
                      title:
                          const Text("Experience"),
                      isActive: _currentStep >= 3,
                      content:
                          SingleChildScrollView(
                        child: Column(
                          children: [

                            TextFormField(
                              controller:
                                  _citExperienceController,
                              decoration:
                                  const InputDecoration(
                                labelText:
                                    "Years in CIT",
                              ),
                              keyboardType:
                                  TextInputType.number,
                            ),

                            const SizedBox(
                                height: 24),

                            const Divider(),

                            const SizedBox(
                                height: 16),

                            ElevatedButton(
                              onPressed:
                                  _addWorkExperience,
                              child: const Text(
                                  "Add Work Experience"),
                            ),

                            const SizedBox(
                                height: 16),

                            ElevatedButton(
                              onPressed:
                                  _addEducation,
                              child: const Text(
                                  "Add Education"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

          // ======================
          // REGISTERING OVERLAY
          // ======================

          if (_isRegistering)
            Container(
              color:
                  Colors.black.withOpacity(0.4),
              child: const Center(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Registering... Please wait",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}