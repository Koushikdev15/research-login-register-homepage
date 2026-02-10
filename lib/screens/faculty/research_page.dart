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
      final counts = await OrcidService.fetchWorkCounts(orcidId);
      final grouped = await OrcidService.fetchGroupedWorks(orcidId);

      setState(() {
        _counts = counts;
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
          SliverToBoxAdapter(child: _CountsGrid(counts: _counts)),
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
              setState(() {
                _expandedYears[y] = !(_expandedYears[y] ?? true);
              });
            },
          ),
        ],
      ),
    );
  }
}

/* =======================================================
   🔹 HEADER (DARK / GLASS)
   ======================================================= */

class _ResearchHeader extends StatelessWidget {
  const _ResearchHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 36),
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
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Authoritative academic works synced from ORCID',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/* =======================================================
   🔹 COUNTS GRID (GLASS METRICS)
   ======================================================= */

class _CountsGrid extends StatelessWidget {
  final Map<String, int> counts;
  const _CountsGrid({required this.counts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 1100 ? 7 : 3;

          return GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            children: _items().map((e) {
              return _MetricCard(
                label: e.label,
                value: counts[e.key] ?? 0,
                icon: e.icon,
                color: e.color,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  List<_CountItem> _items() => [
        _CountItem('total', 'Total', Icons.library_books, Color(0xFF6366F1)),
        _CountItem('journal', 'Journals', Icons.article, Color(0xFF22D3EE)),
        _CountItem('conference', 'Conferences', Icons.groups, Color(0xFF2DD4BF)),
        _CountItem('bookChapter', 'Chapters', Icons.menu_book, Color(0xFFFBBF24)),
        _CountItem('book', 'Books', Icons.book, Color(0xFFA78BFA)),
        _CountItem('patent', 'Patents', Icons.gavel, Color(0xFF4ADE80)),
        _CountItem('design', 'Designs', Icons.architecture, Color(0xFF38BDF8)),
      ];
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.25),
            color.withOpacity(0.10),
          ],
        ),
        border: Border.all(color: color.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountItem {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  _CountItem(this.key, this.label, this.icon, this.color);
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 10,
        children: filters.entries.map((e) {
          final active = selected == e.key;
          return ChoiceChip(
            label: Text(e.value),
            selected: active,
            selectedColor: const Color(0xFF6366F1),
            backgroundColor: const Color(0xFF1F2937),
            labelStyle: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            onSelected: (_) => onChanged(e.key),
          );
        }).toList(),
      ),
    );
  }
}

/* =======================================================
   🔹 WORKS SLIVER (ANIMATED YEARS)
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
        final year = (w.year != null && w.year!.trim().isNotEmpty)
            ? w.year!
            : 'Unknown Year';
        byYear.putIfAbsent(year, () => []).add(w);
      }
    });

    final years = byYear.keys.toList()
      ..sort((a, b) {
        if (a == 'Unknown Year') return 1;
        if (b == 'Unknown Year') return -1;
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      AnimatedRotation(
                        turns: expanded ? 0.0 : 0.5,
                        duration: const Duration(milliseconds: 250),
                        child: const Icon(
                          Icons.expand_more,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: expanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    children: works.map((w) => _WorkCard(w)).toList(),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
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
   🔹 WORK CARD (GLASS / HIGH TECH)
   ======================================================= */

class _WorkCard extends StatelessWidget {
  final WorkItem work;
  const _WorkCard(this.work);

  Color _typeColor(String type) {
    switch (type) {
      case 'journal-article':
        return const Color(0xFF6366F1);
      case 'conference-paper':
        return const Color(0xFF22D3EE);
      case 'patent':
        return const Color(0xFF4ADE80);
      case 'book':
        return const Color(0xFFA78BFA);
      case 'book-chapter':
        return const Color(0xFFFBBF24);
      case 'design':
        return const Color(0xFF38BDF8);
      default:
        return Colors.grey;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'journal-article':
        return 'JOURNAL';
      case 'conference-paper':
        return 'CONFERENCE';
      case 'patent':
        return 'PATENT';
      case 'book':
        return 'BOOK';
      case 'book-chapter':
        return 'BOOK CHAPTER';
      case 'design':
        return 'DESIGN';
      default:
        return type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _typeColor(work.type);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF020617)],
        ),
        border: Border.all(color: accent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  work.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _typeLabel(work.type),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: accent,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            [
              work.source,
              work.year,
            ].whereType<String>().join(' • '),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 14),
          ...work.identifiers.entries.map(
            (e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      e.key.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SelectableText(
                      e.value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
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
