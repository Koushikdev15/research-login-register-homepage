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
  final _fdbService = FdbService();

  // FIXED: Corrected the typo and initialization
  late TextEditingController _titleController;
  late TextEditingController _organizationController;
  late TextEditingController _durationController;
  late TextEditingController _typeController;

  DateTime? _startDate;
  DateTime? _endDate;

  String _facultyName = '';
  String _facultyEmail = '';

  bool _loadingProfile = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers here to avoid 'this' access errors
    _titleController = TextEditingController();
    _organizationController = TextEditingController();
    _durationController = TextEditingController();
    _typeController = TextEditingController();
    _loadFacultyInfo();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _organizationController.dispose();
    _durationController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _loadFacultyInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _facultyEmail = user.email ?? '';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('personalInfo')
          .doc('info')
          .get();
      if (doc.exists) {
        _facultyName = doc.data()?['name'] ?? '';
      }
    } catch (_) {}
    setState(() => _loadingProfile = false);
  }

  Future<void> _saveFdb() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      _showMsg('Please select start and end dates');
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
        type: _typeController.text.trim(),
        name: _facultyName,
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _showMsg('Error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Add FDP', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loadingProfile
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSectionTitle("Program Details"),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecoration(),
                    child: Column(
                      children: [
                        _field(_titleController, 'Title', Icons.title),
                        _field(_organizationController, 'Organization', Icons.business),
                        _field(_durationController, 'Duration', Icons.timelapse),
                        _field(_typeController, 'Type (FDP / Seminar / Webinar)', Icons.category),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Duration"),
                  const SizedBox(height: 10),
                  Container(
                    decoration: _cardDecoration(),
                    child: Column(
                      children: [
                        _dateTile('Start Date', _startDate, (d) => setState(() => _startDate = d)),
                        const Divider(height: 1),
                        _dateTile('End Date', _endDate, (d) => setState(() => _endDate = d)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Faculty Info"),
                  const SizedBox(height: 10),
                  _readOnlyField(_facultyEmail, 'Email', Icons.email),
                  const SizedBox(height: 12),
                  _readOnlyField(_facultyName, 'Name', Icons.person),
                  const SizedBox(height: 30),
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _saveFdb,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('SAVE RECORD', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo));
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: const OutlineInputBorder(),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _readOnlyField(String value, String label, IconData icon) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.grey[200],
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _dateTile(String label, DateTime? date, Function(DateTime) onPick) {
    return ListTile(
      leading: const Icon(Icons.calendar_month, color: Colors.indigo),
      title: Text(date == null ? label : DateFormat('dd MMM yyyy').format(date!)),
      trailing: const Icon(Icons.edit, size: 18),
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
