import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/scopus_service.dart';
import '../../models/researchid_work.dart';
import '../../widgets/scopus_count_card.dart';
import '../../widgets/scopus_work_card.dart';

class ScopusPage extends StatefulWidget {
  final String? facultyId;

  const ScopusPage({super.key, this.facultyId});

  @override
  State<ScopusPage> createState() => _ScopusPageState();
}

class _ScopusPageState extends State<ScopusPage> {
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _error;

  List<ResearchIdWork> _works = [];

  @override
  void initState() {
    super.initState();
    _loadWorks();
  }

  Future<void> _loadWorks() async {
    try {
      final facultyId =
    widget.facultyId ?? context.read<AuthProvider>().currentUserId;

      if (facultyId == null) {
        setState(() {
          _error = "User not authenticated.";
          _isLoading = false;
        });
        return;
      }

      final works = await ScopusService.loadScopusWorks(facultyId);

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
     final facultyId =
    widget.facultyId ?? context.read<AuthProvider>().currentUserId;

      if (facultyId == null) return;

      setState(() {
        _isSyncing = true;
      });

      final inserted = await ScopusService.syncNow(facultyId);

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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_works.isEmpty) {
      return const Center(
        child: Text("No Scopus works found."),
      );
    }

    /// GROUP WORKS BY YEAR

    final Map<String, List<ResearchIdWork>> grouped = {};

    for (var work in _works) {
      final yearMatch = RegExp(r'\d{4}').firstMatch(work.description);
      final year = yearMatch?.group(0) ?? "Unknown";

      grouped.putIfAbsent(year, () => []).add(work);
    }

    final years = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        /// SCOPUS COUNTER

        Padding(
          padding: const EdgeInsets.all(16),
          child: ScopusCountCard(count: _works.length),
        ),

        /// SYNC BUTTON

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

        /// WORKS LIST GROUPED BY YEAR

        Expanded(
          child: ListView(
            children: years.map((year) {
              final works = grouped[year]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// YEAR HEADER

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text(
                      year,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  /// WORK CARDS

                  ...works.map((work) => ScopusWorkCard(work: work)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}