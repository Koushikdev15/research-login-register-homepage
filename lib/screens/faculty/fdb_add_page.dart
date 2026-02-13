import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/fdb_service.dart';

class FdbAddPage extends StatefulWidget {
  const FdbAddPage({super.key});

  @override
  State<FdbAddPage> createState() => _FdbAddPageState();
}

class _FdbAddPageState extends State<FdbAddPage> {
  final _formKey = GlobalKey<FormState>();
  final FdbService _fdbService = FdbService();

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
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizationController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  /// ===============================
  /// LOAD FACULTY NAME + EMAIL
  /// ===============================
 Future<void> _loadFacultyInfo() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  _facultyEmail = user.email ?? "";

  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('personalInfo')
        .doc('info')
        .get();

    if (doc.exists) {
      _facultyName = doc.data()?['name'] ?? "";
    }
  } catch (e) {
    print("Error fetching name: $e");
  }

  setState(() => _loadingProfile = false);
}

  /// ===============================
  /// AUTO CALCULATE DURATION
  /// ===============================
  void _calculateDuration() {
    if (_startDate != null && _endDate != null) {
      final days = _endDate!.difference(_startDate!).inDays + 1;
      _durationController.text = "$days Days";
    }
  }

  /// ===============================
  /// SAVE RECORD
  /// ===============================
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
      await _fdbService.addFdb(
        title: _titleController.text.trim(),
        organization: _organizationController.text.trim(),
        duration: _durationController.text.trim(),
        startDate: _startDate!,
        endDate: _endDate!,
        type: _selectedType!,
        name: _facultyName,
      );

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
        title: const Text("Add Certificate",
            style: TextStyle(fontWeight: FontWeight.bold)),
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

                  _card(
                    Column(
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Duration"),
                  const SizedBox(height: 10),

                  _card(
                    Column(
                      children: [
                        _dateTile("Start Date", _startDate, (d) {
                          setState(() => _startDate = d);
                          _calculateDuration();
                        }),
                        const Divider(height: 1),
                        _dateTile("End Date", _endDate, (d) {
                          setState(() => _endDate = d);
                          _calculateDuration();
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _sectionTitle("Faculty Info"),
                  const SizedBox(height: 10),

                  _readOnly(_facultyEmail, "Email", Icons.email),
                  const SizedBox(height: 12),
                  _readOnly(_facultyName, "Name", Icons.person),

                  const SizedBox(height: 30),

                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _saveFdb,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("SAVE RECORD",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
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
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
    );
  }
}
