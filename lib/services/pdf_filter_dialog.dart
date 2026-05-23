import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pdf_export_options.dart';

/// ======================================================
/// Known work types — matches ORCID + seeder values
/// ======================================================
const List<Map<String, String>> _kWorkTypes = [
  {'label': 'All Work Types', 'value': ''},
  {'label': 'Journal Articles', 'value': 'journal-article'},
  {'label': 'Conference Papers', 'value': 'conference-paper'},
  {'label': 'Books', 'value': 'book'},
  {'label': 'Book Chapters', 'value': 'book-chapter'},
  {'label': 'Utility Patents', 'value': 'patent'},
  {'label': 'Design Patents', 'value': 'design'},
];

/// ======================================================
/// 🔹 PDF FILTER DIALOG
/// ======================================================
class PdfFilterDialog extends StatefulWidget {
  /// facultyId is needed to fetch years from Firestore
  final String facultyId;

  const PdfFilterDialog({
    super.key,
    required this.facultyId,
  });

  @override
  State<PdfFilterDialog> createState() => _PdfFilterDialogState();
}

class _PdfFilterDialogState extends State<PdfFilterDialog> {
  // ─── State ───────────────────────────────────────────
  bool _loadingYears = true;
  List<String> _availableYears = [];

  YearFilterType _yearFilter = YearFilterType.all;
  String? _selectedSpecificYear;
  String? _selectedWorkType; // null = all

  // ─── Init ─────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchAvailableYears();
  }

  // ─── Fetch years from Firestore ───────────────────────
  Future<void> _fetchAvailableYears() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('research_verifications_tree')
          .doc(widget.facultyId)
          .collection('years')
          .get();

      final years = snapshot.docs.map((d) => d.id).toList();

      // Sort descending (most recent first)
      years.sort((a, b) => b.compareTo(a));

      if (mounted) {
        setState(() {
          _availableYears = years;
          _loadingYears = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingYears = false;
        });
      }
    }
  }

  // ─── Build result ─────────────────────────────────────
  PdfExportOptions _buildOptions() {
    return PdfExportOptions(
      yearFilter: _yearFilter,
      specificYear: _yearFilter == YearFilterType.specificYear
          ? int.tryParse(_selectedSpecificYear ?? '')
          : null,
      workTypeFilter: (_selectedWorkType == null || _selectedWorkType!.isEmpty)
          ? null
          : _selectedWorkType,
    );
  }

  // ─── Build ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title ──────────────────────────────────
              Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf_outlined,
                    color: Color(0xFF1565C0),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Export PDF',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                'Choose filters before generating the report.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),

              const Divider(height: 28),

              // ── Year Filter ────────────────────────────
              Text(
                'Year Filter',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              // All Years chip row
              Wrap(
                spacing: 8,
                children: [
                  _YearChip(
                    label: 'All Years',
                    selected: _yearFilter == YearFilterType.all,
                    onTap: () => setState(() {
                      _yearFilter = YearFilterType.all;
                      _selectedSpecificYear = null;
                    }),
                  ),
                  _YearChip(
                    label: 'Current Year',
                    selected: _yearFilter == YearFilterType.currentYear,
                    onTap: () => setState(() {
                      _yearFilter = YearFilterType.currentYear;
                      _selectedSpecificYear = null;
                    }),
                  ),
                  _YearChip(
                    label: 'Specific Year',
                    selected: _yearFilter == YearFilterType.specificYear,
                    onTap: () => setState(() {
                      _yearFilter = YearFilterType.specificYear;
                    }),
                  ),
                ],
              ),

              // Specific year dropdown — shown only when needed
              if (_yearFilter == YearFilterType.specificYear) ...[
                const SizedBox(height: 14),
                _loadingYears
                    ? const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _availableYears.isEmpty
                        ? const Text(
                            'No year data found in Firestore.',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            value: _selectedSpecificYear,
                            decoration: InputDecoration(
                              labelText: 'Select Year',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            items: _availableYears
                                .map(
                                  (y) => DropdownMenuItem(
                                    value: y,
                                    child: Text(y),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) => setState(() {
                              _selectedSpecificYear = val;
                            }),
                          ),
              ],

              const SizedBox(height: 20),

              // ── Work Type Filter ───────────────────────
              Text(
                'Work Type',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                value: _selectedWorkType ?? '',
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: _kWorkTypes
                    .map(
                      (wt) => DropdownMenuItem<String>(
                        value: wt['value'],
                        child: Text(wt['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() {
                  _selectedWorkType = val;
                }),
              ),

              const SizedBox(height: 28),

              // ── Actions ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    // Disable Generate if specificYear chosen
                    // but no year selected yet
                    onPressed: (_yearFilter == YearFilterType.specificYear &&
                            _selectedSpecificYear == null)
                        ? null
                        : () => Navigator.pop(
                              context,
                              _buildOptions(),
                            ),
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Generate PDF'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────
// Helper chip widget
// ──────────────────────────────────────────────────────
class _YearChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _YearChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF1565C0),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}