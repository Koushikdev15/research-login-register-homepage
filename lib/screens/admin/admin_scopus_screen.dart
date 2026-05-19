import 'package:flutter/material.dart';
import '../../models/researchid_work.dart';
import '../../services/scopus_service.dart';
import '../../widgets/scopus_count_card.dart'; // make sure path correct

class AdminScopusScreen extends StatefulWidget {

  final String facultyId;
  final String facultyName;

  const AdminScopusScreen({
    super.key,
    required this.facultyId,
    required this.facultyName,
  });

  @override
  State<AdminScopusScreen> createState() => _AdminScopusScreenState();
}

class _AdminScopusScreenState extends State<AdminScopusScreen> {

  bool _isLoading = true;
  bool _isSyncing = false;
  String? _error;

  List<ResearchIdWork> _works = [];

  @override
  void initState() {
    super.initState();
    _loadWorks();
  }

  // ✅ FIXED METHOD
  Future<void> _loadWorks() async {
    try {

      final works =
          await ScopusService.loadScopusWorks(widget.facultyId);

      setState(() {
        _works = works;
        _isLoading = false;
      });

    } catch (e) {

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

    }
  }

  Future<void> _syncNow() async {

    try {

      setState(() {
        _isSyncing = true;
      });

      final inserted =
          await ScopusService.syncNow(widget.facultyId);

      await _loadWorks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$inserted new works synced"),
          ),
        );
      }

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {

      setState(() {
        _isSyncing = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.facultyName} - Scopus"),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _works.isEmpty
                  ? const Center(child: Text("No Scopus works found"))
                  : Column(
                      children: [

                        // 🔥 COUNT CARD (NEW)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ScopusCountCard(
                            count: _works.length,
                          ),
                        ),

                        // 🔥 SYNC BUTTON
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _isSyncing ? null : _syncNow,
                              icon: const Icon(Icons.sync),
                              label: const Text("Sync Now"),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 🔥 LIST
                        Expanded(
                          child: ListView.builder(
                            itemCount: _works.length,
                            itemBuilder: (context, index) {

                              final work = _works[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8),
                                child: ListTile(
                                  title: Text(work.title),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (work.authors.isNotEmpty)
                                        Text(work.authors),
                                      if (work.publisher.isNotEmpty)
                                        Text(work.publisher),
                                    ],
                                  ),
                                ),
                              );

                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}