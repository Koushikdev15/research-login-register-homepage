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

  final PersonalInfo? personalInfo;
  final ResearchIDs? researchIDs;
  final List<WorkExperience>? workExperiences;
  final List<EducationQualification>? educationQualifications;

  const FacultyRegistrationScreen({
    super.key,
    this.personalInfo,
    this.researchIDs,
    this.workExperiences,
    this.educationQualifications,
  });

  @override
  State<FacultyRegistrationScreen> createState() =>
      _FacultyRegistrationScreenState();
}

class _FacultyRegistrationScreenState
    extends State<FacultyRegistrationScreen> {

  /// UUID generator
  final _uuid = const Uuid();

  /// Scroll controller
  final ScrollController _scrollController = ScrollController();

  /// Loading state
  bool _isRegistering = false;

  /// Profile image
  File? _selectedImage;

  final ImagePicker _picker = ImagePicker();

  /// Google Drive Service
  final DriveService _driveService = DriveService();

  /// Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;

  /// Form Keys
  final _authFormKey = GlobalKey<FormState>();
  final _personalInfoFormKey = GlobalKey<FormState>();
  final _researchIDsFormKey = GlobalKey<FormState>();

  /// Form Data
  Map<String, String> _personalInfoData = {};
  Map<String, String> _researchIDsData = {};

  /// Experience + Education lists
  final List<WorkExperience> _workExperiences = [];
  final List<EducationQualification> _educationQualifications = [];

  /// Check Edit Mode
  bool get isEditMode => widget.personalInfo != null;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    /// Prefill data when editing profile
    if (widget.personalInfo != null) {

      _emailController.text = widget.personalInfo!.mailId;

      _personalInfoData = {
        'name': widget.personalInfo!.name,
        'designation': widget.personalInfo!.designation,
        'department': widget.personalInfo!.department,
        'age': widget.personalInfo!.age.toString(),
        'dateOfBirth': widget.personalInfo!.dateOfBirth,
        'dateOfJoining': widget.personalInfo!.dateOfJoining,
        'panNumber': widget.personalInfo!.panNumber,
        'aadharNumber': widget.personalInfo!.aadharNumber,
        'contactNo': widget.personalInfo!.contactNo,
        'whatsappNo': widget.personalInfo!.whatsappNo,
      };
    }

    /// Prefill Research IDs
    if (widget.researchIDs != null) {

      _researchIDsData = {
        'googleScholarId': widget.researchIDs!.googleScholarId,
        'orcidId': widget.researchIDs!.orcidId,
        'scopusId': widget.researchIDs!.scopusId,
        'vidwanId': widget.researchIDs!.vidwanId,
        'researcherId': widget.researchIDs!.researcherId,
        'wosId': widget.researchIDs!.wosId,
      };
    }

    /// Prefill experience
    if (widget.workExperiences != null) {
      _workExperiences.addAll(widget.workExperiences!);
    }

    /// Prefill education
    if (widget.educationQualifications != null) {
      _educationQualifications
          .addAll(widget.educationQualifications!);
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {

    _scrollController.dispose();

    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK PROFILE IMAGE
  // ============================================================

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
    // ============================================================
  // ADD WORK EXPERIENCE
  // ============================================================

  void _addWorkExperience() {

    final orgController = TextEditingController();
    final startYearController = TextEditingController();
    final endYearController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const Text("Add Work Experience"),

          content: Form(
            key: formKey,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextFormField(
                  controller: orgController,
                  decoration: const InputDecoration(
                    labelText: "Organization",
                  ),
                  validator: Validators.validateInstitution,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: startYearController,
                  decoration: const InputDecoration(
                    labelText: "Start Year",
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.validateYear,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: endYearController,
                  decoration: const InputDecoration(
                    labelText: "End Year",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      Validators.validateEndYear(
                        value,
                        startYearController.text,
                      ),
                ),

              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(

              onPressed: () {

                if (formKey.currentState!.validate()) {

                  int start = int.parse(startYearController.text);
                  int end = int.parse(endYearController.text);

                  setState(() {

                    _workExperiences.add(
                      WorkExperience(
                        id: _uuid.v4(),
                        institutionName:
                            orgController.text.trim(),
                        yearsOfExperience: end - start,
                        addedAt: DateTime.now(),
                      ),
                    );

                  });

                  Navigator.pop(context);

                }

              },

              child: const Text("Add"),

            ),

          ],

        );

      },
    );
  }


  // ============================================================
  // ADD EDUCATION
  // ============================================================

  void _addEducation() {

    final orgController = TextEditingController();
    final degreeController = TextEditingController();
    final startYearController = TextEditingController();
    final endYearController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(

          title: const Text("Add Education"),

          content: Form(
            key: formKey,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                TextFormField(
                  controller: orgController,
                  decoration: const InputDecoration(
                    labelText: "Organization",
                  ),
                  validator: Validators.validateInstitution,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: degreeController,
                  decoration: const InputDecoration(
                    labelText: "Degree / Course",
                  ),
                  validator: Validators.validateCourse,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: startYearController,
                  decoration: const InputDecoration(
                    labelText: "Start Year",
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.validateYear,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: endYearController,
                  decoration: const InputDecoration(
                    labelText: "End Year",
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      Validators.validateEndYear(
                        value,
                        startYearController.text,
                      ),
                ),

              ],
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(

              onPressed: () {

                if (formKey.currentState!.validate()) {

                  int start = int.parse(startYearController.text);
                  int end = int.parse(endYearController.text);

                  setState(() {

                    _educationQualifications.add(

                      EducationQualification(
                        id: _uuid.v4(),
                        institutionName:
                            orgController.text.trim(),
                        course: degreeController.text.trim(),
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

              child: const Text("Add"),

            ),

          ],

        );

      },
    );
  }
    // ============================================================
  // REGISTER FACULTY
  // ============================================================

  Future<void> _registerFaculty() async {

    /// Validate account form
    if (!_authFormKey.currentState!.validate()) {

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      return;
    }

    /// Validate personal info
    if (!_personalInfoFormKey.currentState!.validate()) {

      _scrollController.animateTo(
        300,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );

      return;
    }

    setState(() {
      _isRegistering = true;
    });

    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    final facultyProvider =
        Provider.of<FacultyProvider>(context, listen: false);

    try {

      // ========================================================
      // CREATE AUTH USER
      // ========================================================

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
              "Registration failed");

        }

        return;
      }

      // ========================================================
      // UPLOAD PROFILE IMAGE
      // ========================================================

      if (_selectedImage != null) {

        String? fileId =
            await _driveService.uploadFile(
          file: _selectedImage!,
          folderName: "profile_pictures",
        );

        if (fileId != null) {

          String imageUrl =
              "https://drive.google.com/uc?export=view&id=$fileId";

          await authProvider.updateProfilePicture(imageUrl);
        }

      }

      // ========================================================
      // PREPARE PERSONAL INFO
      // ========================================================

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

        mailId: _emailController.text.trim(),

      );

      // ========================================================
      // PREPARE RESEARCH IDS
      // ========================================================

      final researchIDs = ResearchIDs(

        googleScholarId:
            _researchIDsData['googleScholarId'] ?? '',

        orcidId:
            _researchIDsData['orcidId'] ?? '',

        scopusId:
            _researchIDsData['scopusId'] ?? '',

        vidwanId:
            _researchIDsData['vidwanId'] ?? '',

        researcherId:
            _researchIDsData['researcherId'] ?? '',

        wosId:
            _researchIDsData['wosId'] ?? '',

      );

      // ========================================================
      // CALCULATE CIT EXPERIENCE
      // ========================================================

      final citExperience =
          CITExperience.fromDateOfJoining(
        _personalInfoData['dateOfJoining'] ?? '',
      );

      // ========================================================
      // SAVE DATA TO FIRESTORE
      // ========================================================

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
            content: Text("Registration Successful!"),
            backgroundColor: AppColors.successGreen,
          ),
        );

        Navigator.of(context)
            .pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
                const FacultyDashboard(),
          ),
          (route) => false,
        );

      } else {

        if (mounted) {

          _showErrorSnackBar(
              "Failed to save profile data");

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

  // ============================================================
  // UPDATE FACULTY PROFILE
  // ============================================================

  Future<void> _updateFaculty() async {

    setState(() {
      _isRegistering = true;
    });

    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    final facultyProvider =
        Provider.of<FacultyProvider>(context, listen: false);

    try {

      final personalInfo = PersonalInfo(

        name: _personalInfoData['name'] ?? '',

        designation:
            _personalInfoData['designation'] ?? '',

        department:
            _personalInfoData['department'] ?? '',

        age: int.tryParse(
            _personalInfoData['age'] ?? '0') ?? 0,

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

        mailId: _emailController.text.trim(),

      );

      final researchIDs = ResearchIDs(

        googleScholarId:
            _researchIDsData['googleScholarId'] ?? '',

        orcidId:
            _researchIDsData['orcidId'] ?? '',

        scopusId:
            _researchIDsData['scopusId'] ?? '',

        vidwanId:
            _researchIDsData['vidwanId'] ?? '',

        researcherId:
            _researchIDsData['researcherId'] ?? '',

        wosId:
            _researchIDsData['wosId'] ?? '',

      );

      final citExperience =
          CITExperience.fromDateOfJoining(
        _personalInfoData['dateOfJoining'] ?? '',
      );

      await facultyProvider.saveFacultyData(

        userId: authProvider.currentUserId!,

        personalInfo: personalInfo,

        researchIDs: researchIDs,

        workExperiences: _workExperiences,

        citExperience: citExperience,

        educationQualifications:
            _educationQualifications,

      );

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text("Profile Updated Successfully"),
            backgroundColor: AppColors.successGreen,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const FacultyDashboard(),
          ),
          (route) => false,
        );

      }

    } catch (e) {

      _showErrorSnackBar(e.toString());

    } finally {

      if (mounted) {

        setState(() {
          _isRegistering = false;
        });

      }

    }

  }

  // ============================================================
  // ERROR SNACKBAR
  // ============================================================

  void _showErrorSnackBar(String message) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorRed,
        behavior: SnackBarBehavior.floating,
      ),

    );

  }
    // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {

    return Card(

      elevation: 3,
      color: AppColors.pureWhite,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                const Icon(
                  Icons.circle,
                  size: 10,
                  color: AppColors.universityNavy,
                ),

                const SizedBox(width: 10),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.universityNavy,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 18),

            child,

          ],
        ),
      ),
    );

  }


  // ============================================================
  // REGISTER BUTTON
  // ============================================================

  Widget _buildRegisterButton() {

    return SizedBox(

      width: double.infinity,
      height: 55,

      child: ElevatedButton(

        style: ElevatedButton.styleFrom(

          backgroundColor: AppColors.academicBlue,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

        ),

        onPressed: _isRegistering
            ? null
            : (isEditMode ? _updateFaculty : _registerFaculty),

        child: Text(

          isEditMode
              ? "UPDATE PROFILE"
              : "REGISTER",

          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),

        ),

      ),

    );

  }


  // ============================================================
  // BUILD UI
  // ============================================================

  @override
  Widget build(BuildContext context) {

    final authProvider =
        Provider.of<AuthProvider>(context);

    final facultyProvider =
        Provider.of<FacultyProvider>(context);

    final isLoading =
        authProvider.isLoading ||
        facultyProvider.isLoading;

    return Scaffold(

      backgroundColor: AppColors.offWhite,

      appBar: AppBar(

        title: Text(
          isEditMode
              ? "Edit Profile"
              : "Faculty Registration",
        ),

        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.universityNavy,
        elevation: 1,

      ),

      body: Stack(
        children: [

          // ====================================================
          // MAIN CONTENT
          // ====================================================

          isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : SingleChildScrollView(

                  controller: _scrollController,

                  padding:
                      const EdgeInsets.all(20),

                  child: Column(
                    children: [

                      // =========================================
                      // ACCOUNT CREATION
                      // =========================================

                      if (!isEditMode)
                        _buildSectionCard(

                          title:
                              "1️⃣ Account Creation",

                          child: Form(

                            key: _authFormKey,

                            child: Column(
                              children: [

                                TextFormField(
                                  controller:
                                      _emailController,

                                  decoration:
                                      const InputDecoration(
                                    labelText:
                                        "Email Address",
                                    prefixIcon:
                                        Icon(Icons
                                            .email),
                                  ),

                                  keyboardType:
                                      TextInputType
                                          .emailAddress,

                                  validator:
                                      Validators
                                          .validateEmail,
                                ),

                                const SizedBox(
                                    height: 16),

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
                                            Icons
                                                .lock),

                                    suffixIcon:
                                        IconButton(

                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons
                                                .visibility_off
                                            : Icons
                                                .visibility,
                                      ),

                                      onPressed: () {

                                        setState(() {

                                          _obscurePassword =
                                              !_obscurePassword;

                                        });

                                      },

                                    ),

                                  ),

                                  validator:
                                      (value) {

                                    if (value ==
                                            null ||
                                        value
                                            .isEmpty) {

                                      return "Password required";

                                    }

                                    if (value
                                            .length <
                                        6) {

                                      return "Minimum 6 characters";

                                    }

                                    return null;

                                  },
                                ),

                                const SizedBox(
                                    height: 16),

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
                                        Icon(Icons
                                            .lock),

                                  ),

                                  validator:
                                      (value) {

                                    if (value ==
                                            null ||
                                        value
                                            .isEmpty) {

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

                      const SizedBox(height: 20),

                      // =========================================
                      // PERSONAL DETAILS
                      // =========================================

                      _buildSectionCard(

                        title:
                            "2️⃣ Personal Details",

                        child: Column(
                          children: [

                            GestureDetector(

                              onTap:
                                  _pickProfileImage,

                              child: CircleAvatar(

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
                                            size: 40,
                                          )
                                        : null,
                              ),
                            ),

                            const SizedBox(
                                height: 8),

                            const Text(
                                "Profile Photo"),

                            const SizedBox(
                                height: 24),

                            PersonalInfoForm(

                              formKey:
                                  _personalInfoFormKey,

                              onSaved:
                                  (data) =>
                                      _personalInfoData =
                                          data,

                              emailController:
                                  _emailController,

                              initialData:
                                  _personalInfoData,

                            ),

                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // =========================================
                      // RESEARCH IDS
                      // =========================================

                      _buildSectionCard(

                        title:
                            "3️⃣ Research IDs",

                        child: ResearchIDsForm(

                          formKey:
                              _researchIDsFormKey,

                          onSaved: (data) =>
                              _researchIDsData =
                                  data,

                          initialData:
                              _researchIDsData,

                        ),
                      ),

                      const SizedBox(height: 20),

                      // =========================================
                      // EXPERIENCE
                      // =========================================

                  

                        _buildSectionCard(

                          title:
                              "4️⃣ Experience",

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              const Text(

                                "Add your professional experience and education details",

                                style: TextStyle(
                                    color:
                                        Colors
                                            .grey),

                              ),

                              const SizedBox(
                                  height: 24),

                              SizedBox(

                                width:
                                    double.infinity,

                                height: 55,

                                child:
                                    ElevatedButton
                                        .icon(

                                  icon: const Icon(
                                      Icons
                                          .work_outline),

                                  label: const Text(

                                    "Add Work Experience",

                                    style: TextStyle(
                                        fontSize:
                                            16),

                                  ),

                                  style:
                                      ElevatedButton
                                          .styleFrom(

                                    backgroundColor:
                                        AppColors
                                            .academicBlue,

                                    shape:
                                        RoundedRectangleBorder(

                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  12),

                                    ),

                                  ),

                                  onPressed:
                                      _addWorkExperience,

                                ),

                              ),

                              const SizedBox(
                                  height: 16),

                              SizedBox(

                                width:
                                    double.infinity,

                                height: 55,

                                child:
                                    ElevatedButton
                                        .icon(

                                  icon: const Icon(
                                      Icons
                                          .school_outlined),

                                  label: const Text(

                                    "Add Education",

                                    style: TextStyle(
                                        fontSize:
                                            16),

                                  ),

                                  style:
                                      ElevatedButton
                                          .styleFrom(

                                    backgroundColor:
                                        const Color(
                                            0xFF2E7D32),

                                    shape:
                                        RoundedRectangleBorder(

                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  12),

                                    ),

                                  ),

                                  onPressed:
                                      _addEducation,

                                ),

                              ),

                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                      

                      // =========================================
                      // REGISTER BUTTON
                      // =========================================

                      _buildRegisterButton(),

                      const SizedBox(height: 40),

                    ],
                  ),
                ),

          // ================================================
          // REGISTERING OVERLAY
          // ================================================

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