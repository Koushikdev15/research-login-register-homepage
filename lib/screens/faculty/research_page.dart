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
      setState(() {
        _grouped = grouped;
        _loading = false;
      });
    } catch (_) {
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
      backgroundColor: const Color(0xFF0E1117),
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
   🔹 HEADER
   ======================================================= */

class _ResearchHeader extends StatelessWidget {
  const _ResearchHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 64, 28, 42),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF1F2937)],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Research Portfolio',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Verification status shown for current year works',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/* =======================================================
   🔹 FILTER BAR
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 10,
        children: filters.entries.map((e) {
          final active = selected == e.key;
          return ChoiceChip(
            label: Text(e.value),
            selected: active,
            onSelected: (_) => onChanged(e.key),
          );
        }).toList(),
      ),
    );
  }
}

/* =======================================================
   🔹 WORKS SLIVER
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

    final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final year = years[index];
          final works = byYear[year]!;
          final expanded = expandedYears[year] ?? true;

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => onToggleYear(year),
                  child: Row(
                    children: [
                      Text(
                        year,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
                const Padding(
  padding: EdgeInsets.symmetric(vertical: 8),
  child: Divider(color: Colors.white24),
),

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
   🔹 WORK CARD WITH BADGES (FACULTY VIEW)
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
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF020617)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 TITLE
          Text(
            work.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 10),

          /// 🔹 META LINE
          Row(
            children: [
              Expanded(
                child: Text(
                  '${work.source ?? ''}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
              if (work.year != null)
                Text(
                  work.year!,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

          /// 🔹 BADGES
          if (_isCurrentYear && uid != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('research_verifications')
                  .where('facultyId', isEqualTo: uid)
                  .where('putCode', isEqualTo: work.putCode)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const _Badge(text: 'PENDING');
                }

                final data = snapshot.data!.docs.first.data()
                    as Map<String, dynamic>;

                final String? decision =
                    data['verificationDecision'];

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (data['isScopus'] == true)
                      const _Badge(text: 'SCOPUS'),
                    if (data['isSci'] == true)
                      const _Badge(text: 'SCI'),
                    if (data['isIsbnVerified'] == true)
                      const _Badge(text: 'ISBN'),
                    _Badge(
                      text: decision ??
                          data['verificationStatus'] ??
                          'PENDING',
                      highlight:
                          decision == 'VERIFIED',
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



class _Badge extends StatelessWidget {
  final String text;
  final bool highlight;

  const _Badge({required this.text, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;

    switch (text) {
      case 'VERIFIED':
        bgColor = const Color(0xFF14532D);
        borderColor = const Color(0xFF22C55E);
        break;
      case 'SCOPUS':
        bgColor = const Color(0xFF1E3A8A);
        borderColor = const Color(0xFF3B82F6);
        break;
      case 'SCI':
        bgColor = const Color(0xFF312E81);
        borderColor = const Color(0xFF6366F1);
        break;
      case 'ISBN':
        bgColor = const Color(0xFF064E3B);
        borderColor = const Color(0xFF14B8A6);
        break;
      case 'NOT_VERIFIED':
        bgColor = const Color(0xFF7F1D1D);
        borderColor = const Color(0xFFEF4444);
        break;
      default: // PENDING
        bgColor = const Color(0xFF374151);
        borderColor = const Color(0xFF6B7280);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: highlight
            ? [
                BoxShadow(
                  color: borderColor.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : [],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
