import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
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

  Map<String, List<WorkItem>> _grouped = {};
  String _selectedType = 'all';
  final Map<String, bool> _expandedYears = {};

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
        _error = 'ORCID ID not found in your profile';
        _loading = false;
      });
      return;
    }

    try {
      final grouped = await OrcidService.fetchGroupedWorks(orcidId);

      if (!mounted) return;

      setState(() {
        _grouped = grouped;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load research data';
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
      return Center(child: Text(_error!));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _ResearchHeader()),
          SliverToBoxAdapter(
            child: _FilterBar(
              selected: _selectedType,
              onChanged: (v) => setState(() => _selectedType = v),
            ),
          ),
          _WorksSliver(
            grouped: _grouped,
            selectedType: _selectedType,
            expandedYears: _expandedYears,
            onToggleYear: (y) {
              _expandedYears[y] = !(_expandedYears[y] ?? true);
            },
          ),
        ],
      ),
    );
  }
}

/* =======================================================
   HEADER
   ======================================================= */

class _ResearchHeader extends StatelessWidget {
  const _ResearchHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Research Portfolio',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Verification status shown for current year works',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/* =======================================================
   FILTER BAR
   ======================================================= */

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
      'book-chapter': 'Chapters',
      'book': 'Books',
      'patent': 'Patents',
      'design': 'Designs',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filters.entries.map((e) {
          final active = selected == e.key;

          return ChoiceChip(
            label: Text(
              e.value,
              style: TextStyle(
                color: active ? Colors.white : Colors.black87,
              ),
            ),
            selected: active,
            selectedColor: Colors.blue,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onSelected: (_) => onChanged(e.key),
          );
        }).toList(),
      ),
    );
  }
}

/* =======================================================
   WORK LIST
   ======================================================= */

class _WorksSliver extends StatelessWidget {
  final Map<String, List<WorkItem>> grouped;
  final String selectedType;
  final Map<String, bool> expandedYears;
  final ValueChanged<String> onToggleYear;

  const _WorksSliver({
    required this.grouped,
    required this.selectedType,
    required this.expandedYears,
    required this.onToggleYear,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<WorkItem>> byYear = {};

    final visible = selectedType == 'all'
        ? grouped
        : {selectedType: grouped[selectedType] ?? []};

    visible.forEach((_, works) {
      for (final w in works) {
        final year = w.year ?? 'Unknown';
        byYear.putIfAbsent(year, () => []).add(w);
      }
    });

    final years = byYear.keys.toList()
      ..sort((a, b) {
        if (a == 'Unknown') return 1;
        if (b == 'Unknown') return -1;
        return b.compareTo(a);
      });

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final year = years[index];
          final works = byYear[year]!;
          final expanded = expandedYears[year] ?? true;

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => onToggleYear(year),
                  child: Row(
                    children: [
                      Text(
                        year,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey.shade300),

                if (expanded)
                  ...works.map((w) => _WorkCardWithBadges(work: w)),
              ],
            ),
          );
        },
        childCount: years.length,
      ),
    );
  }
}

/* =======================================================
   WORK CARD
   ======================================================= */

class _WorkCardWithBadges extends StatelessWidget {
  final WorkItem work;
  const _WorkCardWithBadges({required this.work});

  bool get _isCurrentYear =>
      work.year == DateTime.now().year.toString();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final String? uid = authProvider.currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            work.title,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(
                child: Text(
                  work.source ?? '',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              if (work.year != null)
                Text(
                  work.year!,
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),

          const SizedBox(height: 10),

          if (_isCurrentYear && uid != null)
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('research_verifications_tree')
                  .doc(uid)
                  .collection('years')
                  .doc(work.year ?? '')
                  .collection('workTypes')
                  .doc(work.type)
                  .collection('works')
                  .doc(work.putCode)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const _Badge(text: 'PENDING');
                }

                final data =
                    snapshot.data!.data() as Map<String, dynamic>;

                final String status =
                    data['verificationStatus'] ?? 'PENDING';
                final String? type =
                    data['verificationType'];

                return Wrap(
                  spacing: 8,
                  children: [
                    if (type != null)
                      _Badge(
                        text: type,
                        highlight: true,
                      ),
                    _Badge(
                      text: status,
                      highlight: status == 'VERIFIED',
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/* =======================================================
   BADGE
   ======================================================= */

class _Badge extends StatelessWidget {
  final String text;
  final bool highlight;

  const _Badge({required this.text, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      backgroundColor:
          highlight ? Colors.green.shade600 : Colors.orange.shade400,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}