import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/faculty_provider.dart';
import '../../services/orcid_service.dart';

class ResearchPage extends StatefulWidget {
  const ResearchPage({super.key});

  @override
  State<ResearchPage> createState() => _ResearchPageState();
}

class _ResearchPageState extends State<ResearchPage> {
  bool _loading = true;
  String? _error;

  Map<String, int> _counts = {};
  Map<String, List<WorkItem>> _grouped = {};
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _loadResearch();
  }

  Future<void> _loadResearch() async {
    final faculty = context.read<FacultyProvider>();
    final orcidId = faculty.researchIDs?.orcidId;

    if (orcidId == null || orcidId.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'ORCID ID not found in your profile';
      });
      return;
    }

    try {
      final counts = await OrcidService.fetchWorkCounts(orcidId);
      final grouped = await OrcidService.fetchGroupedWorks(orcidId);

      setState(() {
        _counts = counts;
        _grouped = grouped;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load research works';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadResearch,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _CountsSection(counts: _counts),
          _FilterBar(
            selected: _selectedType,
            onChanged: (v) => setState(() => _selectedType = v),
          ),
          Expanded(
            child: _WorksList(
              grouped: _grouped,
              selectedType: _selectedType,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountsSection extends StatelessWidget {
  final Map<String, int> counts;
  const _CountsSection({required this.counts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: counts.entries.where((e) => e.key != 'total').map((e) {
          return Chip(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
            label: Text('${_label(e.key)}: ${e.value}'),
          );
        }).toList(),
      ),
    );
  }

  String _label(String k) {
    switch (k) {
      case 'journal':
        return 'Journals';
      case 'conference':
        return 'Conferences';
      case 'bookChapter':
        return 'Book Chapters';
      case 'book':
        return 'Books';
      case 'patent':
        return 'Patents';
      case 'design':
        return 'Designs';
      default:
        return k;
    }
  }
}

class _FilterBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final filters = {
      'all': 'All',
      'journal-article': 'Journals',
      'conference-paper': 'Conferences',
      'book-chapter': 'Book Chapters',
      'book': 'Books',
      'patent': 'Patents',
      'design': 'Designs',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: filters.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(e.value),
              selected: selected == e.key,
              onSelected: (_) => onChanged(e.key),
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: selected == e.key ? Colors.white : Colors.black87,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WorksList extends StatelessWidget {
  final Map<String, List<WorkItem>> grouped;
  final String selectedType;

  const _WorksList({
    required this.grouped,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    final visible = selectedType == 'all'
        ? grouped
        : {selectedType: grouped[selectedType] ?? []};

    final allWorks = <WorkItem>[];
    visible.forEach((_, works) => allWorks.addAll(works));

    if (allWorks.isEmpty) {
      return const Center(child: Text('No works found'));
    }

    final byYear = <String, List<WorkItem>>{};

    for (final w in allWorks) {
      final year = w.year ?? 'Unknown Year';
      byYear.putIfAbsent(year, () => []).add(w);
    }

    final years = byYear.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: years.map((year) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(year,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            ...byYear[year]!.map((work) => _WorkCard(work)),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }
}

class _WorkCard extends StatelessWidget {
  final WorkItem work;
  const _WorkCard(this.work);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(work.title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    work.type.replaceAll('-', ' ').toUpperCase(),
                    style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [
                      work.source,
                      work.year,
                    ].where((s) => s != null && s.isNotEmpty).join(' • '),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (work.identifiers.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: work.identifiers.entries.map(
                  (e) => Text(
                    '${e.key.toUpperCase()}: ${e.value}',
                    style: TextStyle(fontSize: 11, color: Colors.blue.shade900),
                  ),
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}