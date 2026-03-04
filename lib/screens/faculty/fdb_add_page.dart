import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/fdb_service.dart';
import '../../services/drive_service.dart';
import 'dart:io';

class FdbAddPage extends StatefulWidget {
  final bool isEdit;
  final String? docId;
  final Map<String, dynamic>? existingData;

  const FdbAddPage({
    super.key,
    this.isEdit = false,
    this.docId,
    this.existingData,
  });

  @override
  State<FdbAddPage> createState() => _FdbAddPageState();
}

class _FdbAddPageState extends State<FdbAddPage> {
  final _formKey = GlobalKey<FormState>();
  final FdbService _fdbService = FdbService();
  final DriveService _driveService = DriveService();

  late TextEditingController _titleController;
  late TextEditingController _organizationController;
  late TextEditingController _durationController;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedType;

  String _facultyName = '';
  String _facultyEmail = '';

  bool _loadingProfile = true;
  bool _isSaving = false;
  bool _isUploading = false;

  String? _certificateUrl;

  final List<String> _types = [
    "NPTEL",
    "Online Course",
    "ATAL - FDP",
    "FDP",
    "Seminar",
    "Webinar",
    "Seminar Conducted",
    "Webinar Conducted",
    "FDP Conducted",
    "Awards",
    "Other Certificate"
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _organizationController = TextEditingController();
    _durationController = TextEditingController();

    _loadFacultyInfo();

    // 🔥 PREFILL IF EDIT MODE
    if (widget.isEdit && widget.existingData != null) {
      final data = widget.existingData!;

      _titleController.text = data['title'] ?? '';
      _organizationController.text = data['organization'] ?? '';
      _durationController.text = data['duration'] ?? '';
      _selectedType = data['type'];
      _certificateUrl = data['photoUrl'];

      _startDate =
          (data['startDate'] as Timestamp?)?.toDate();
      _endDate =
          (data['endDate'] as Timestamp?)?.toDate();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizationController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _loadFacultyInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _facultyEmail = user.email ?? "";

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('personalInfo')
        .doc('info')
        .get();

    if (doc.exists) {
      _facultyName = doc.data()?['name'] ?? "";
    }

    setState(() => _loadingProfile = false);
  }

  void _calculateDuration() {
    if (_startDate != null && _endDate != null) {
      final days = _endDate!.difference(_startDate!).inDays + 1;
      _durationController.text = "$days Days";
    }
  }

  Future<void> _uploadCertificate() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result == null) return;

      setState(() => _isUploading = true);

      final path = result.files.single.path;
      if (path == null) {
        _showMsg("Invalid file");
        setState(() => _isUploading = false);
        return;
      }

      final file = File(path);

      final fileId = await _driveService.uploadFile(
        file: file,
        folderName: "fdb_certificates",
      );

      if (fileId == null) {
        _showMsg("Upload failed");
        setState(() => _isUploading = false);
        return;
      }

      setState(() {
        _certificateUrl = fileId;
        _isUploading = false;
      });

      _showMsg("Uploaded to Faculty Drive Successfully");
    } catch (e) {
      setState(() => _isUploading = false);
      _showMsg("Upload error: $e");
    }
  }

  Future<void> _saveFdb() async {
  if (!_formKey.currentState!.validate()) return;

  if (_startDate == null || _endDate == null) {
    _showMsg("Select start and end dates");
    return;
  }

  if (_selectedType == null) {
    _showMsg("Select type");
    return;
  }

  setState(() => _isSaving = true);

  try {
    if (widget.isEdit) {
      // 🔥 UPDATE EXISTING DOCUMENT
      await FirebaseFirestore.instance
          .collection('fdb_datum')
          .doc(widget.docId)
          .update({
        'title': _titleController.text.trim(),
        'organization': _organizationController.text.trim(),
        'duration': _durationController.text.trim(),
        'startDate': _startDate,
        'endDate': _endDate,
        'type': _selectedType,
        'photoUrl': _certificateUrl,
        'status': 'pending', // 🔥 RESET TO PENDING AFTER EDIT
      });
    } else {
      // 🔥 ADD NEW DOCUMENT
      await _fdbService.addFdb(
        title: _titleController.text.trim(),
        organization: _organizationController.text.trim(),
        duration: _durationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        type: _selectedType!,
        name: _facultyName,
        photoUrl: _certificateUrl,
      );
    }

    if (!mounted) return;
    Navigator.pop(context);

  } catch (e) {
    _showMsg("Error: $e");
  } finally {
    if (mounted) setState(() => _isSaving = false);
  }
}
  void _showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          widget.isEdit ? "Edit Certificate" : "Add Certificate",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [

                  _sectionTitle("Program Details"),
                  const SizedBox(height: 15),

                  _card(Column(
                    children: [
                      _field(_titleController, "Title", Icons.title),
                      _field(_organizationController, "Organization", Icons.business),

                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: "Type",
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: _types
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _selectedType = value),
                        validator: (value) =>
                            value == null ? "Select Type" : null,
                      ),

                      const SizedBox(height: 12),

                      _field(_durationController, "Duration (Auto)",
                          Icons.timelapse,
                          readOnly: true),

                      const SizedBox(height: 12),

                      _isUploading
                          ? const CircularProgressIndicator()
                          : OutlinedButton.icon(
                              onPressed: _uploadCertificate,
                              icon: const Icon(Icons.upload_file),
                              label: Text(
                                _certificateUrl == null
                                    ? "Upload Certificate Image"
                                    : "Image Uploaded ✓",
                              ),
                            ),
                    ],
                  )),

                  const SizedBox(height: 20),

                  _sectionTitle("Duration"),
                  const SizedBox(height: 10),

                  _card(Column(
                    children: [
                      _dateTile("Start Date", _startDate, (d) {
                        setState(() => _startDate = d);
                        _calculateDuration();
                      }),
                      const Divider(),
                      _dateTile("End Date", _endDate, (d) {
                        setState(() => _endDate = d);
                        _calculateDuration();
                      }),
                    ],
                  )),

                  const SizedBox(height: 20),

                  _sectionTitle("Faculty Info"),
                  const SizedBox(height: 10),

                  _readOnly(_facultyEmail, "Email", Icons.email),
                  const SizedBox(height: 12),
                  _readOnly(_facultyName, "Name", Icons.person),

                  const SizedBox(height: 30),

                  _isSaving
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _saveFdb,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                            ),
                            child: Text(
                              widget.isEdit
                                  ? "UPDATE RECORD"
                                  : "SAVE RECORD",
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.indigo));
  }

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _field(TextEditingController controller, String label,
      IconData icon,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (v) =>
            v == null || v.trim().isEmpty ? "Required" : null,
      ),
    );
  }

  Widget _readOnly(String value, String label, IconData icon) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey[200],
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dateTile(
      String label, DateTime? date, Function(DateTime) onPick) {
    return ListTile(
      leading: const Icon(Icons.calendar_month, color: Colors.indigo),
      title: Text(date == null
          ? label
          : DateFormat("dd MMM yyyy").format(date)),
      trailing: const Icon(Icons.edit),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
    );
  }
}