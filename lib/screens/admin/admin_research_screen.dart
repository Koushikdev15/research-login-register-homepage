import 'package:flutter/material.dart';
import '../../models/faculty_profile.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/info_display_card.dart';
import '../../services/orcid_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminResearchScreen extends StatefulWidget {
  final FacultyProfile faculty;

  const AdminResearchScreen({super.key, required this.faculty});

  @override
  State<AdminResearchScreen> createState() => _AdminResearchScreenState();
}

class _AdminResearchScreenState extends State<AdminResearchScreen> {
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
    final orcidId = widget.faculty.researchIDs?.orcidId;

    if (orcidId == null || orcidId.isEmpty) {
      setState(() {
        _error = 'ORCID ID not found in faculty profile';
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
    } catch (e) {
      setState(() {
        _error = 'Failed to load research data from ORCID';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Research Portfolio',
              style: AppTextStyles.h4.copyWith(color: AppColors.universityNavy),
            ),
            Text(
              widget.faculty.personalInfo.name,
              style: AppTextStyles.caption.copyWith(color: AppColors.mediumGray),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Faculty Header Card
            _buildFacultyHeader(),
            const SizedBox(height: 24),

            // Research IDs Section
            _buildResearchIDsSection(),
            const SizedBox(height: 24),

            // Research Statistics
            if (!_loading && _error == null && _grouped.isNotEmpty)
              _buildResearchStatistics(),
            
            if (!_loading && _error == null && _grouped.isNotEmpty)
              const SizedBox(height: 24),

            // Research Works Section
            _buildResearchWorksSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyHeader() {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      color: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.lightGray,
              backgroundImage: widget.faculty.userModel.profilePictureURL != null
                  ? NetworkImage(widget.faculty.userModel.profilePictureURL!)
                  : null,
              child: widget.faculty.userModel.profilePictureURL == null
                  ? Text(
                      widget.faculty.personalInfo.name.isNotEmpty
                          ? widget.faculty.personalInfo.name[0]
                          : '?',
                      style: const TextStyle(fontSize: 32, color: AppColors.mediumGray),
                    )
                  : null,
            ),
            const SizedBox(width: 24),

            // Faculty Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.faculty.personalInfo.name,
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.faculty.personalInfo.designation,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.academicBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.faculty.personalInfo.department,
                    style: AppTextStyles.bodyRegular.copyWith(color: AppColors.mediumGray),
                  ),
                  const SizedBox(height: 8),
                  if (widget.faculty.calculatedCITYears > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.academicBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${widget.faculty.calculatedCITYears} years in CIT',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.academicBlue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResearchIDsSection() {
    final researchIDs = widget.faculty.researchIDs;

    return InfoDisplayCard(
      title: 'Research Identifiers',
      icon: Icons.badge_outlined,
      initiallyExpanded: true,
      child: researchIDs == null
          ? _buildEmptyState('No research IDs available')
          : Column(
              children: [
                if (researchIDs.vidwanId != null && researchIDs.vidwanId!.isNotEmpty)
                  _buildInfoRow('Vidwan ID', researchIDs.vidwanId!, Icons.account_circle),
                if (researchIDs.scopusId != null && researchIDs.scopusId!.isNotEmpty)
                  _buildInfoRow('Scopus ID', researchIDs.scopusId!, Icons.science),
                if (researchIDs.orcidId != null && researchIDs.orcidId!.isNotEmpty)
                  _buildInfoRow('ORCID', researchIDs.orcidId!, Icons.fingerprint),
                if (researchIDs.googleScholarId != null && researchIDs.googleScholarId!.isNotEmpty)
                  _buildInfoRow('Google Scholar ID', researchIDs.googleScholarId!, Icons.school),
                
                // If all are empty
                if ((researchIDs.vidwanId == null || researchIDs.vidwanId!.isEmpty) &&
                    (researchIDs.scopusId == null || researchIDs.scopusId!.isEmpty) &&
                    (researchIDs.orcidId == null || researchIDs.orcidId!.isEmpty) &&
                    (researchIDs.googleScholarId == null || researchIDs.googleScholarId!.isEmpty))
                  _buildEmptyState('No research IDs registered'),
              ],
            ),
    );
  }

  Widget _buildResearchStatistics() {
    final counts = OrcidService.calculateCounts(_grouped);

    return InfoDisplayCard(
      title: 'Research Statistics',
      icon: Icons.analytics_outlined,
      initiallyExpanded: true,
      child: Column(
        children: [
          _buildStatRow('Total Publications', counts['total'].toString(), Icons.library_books),
          _buildStatRow('Journal Articles', counts['journal'].toString(), Icons.article),
          _buildStatRow('Conference Papers', counts['conference'].toString(), Icons.groups),
          _buildStatRow('Book Chapters', counts['bookChapter'].toString(), Icons.menu_book),
          _buildStatRow('Books', counts['book'].toString(), Icons.auto_stories),
          if (counts['patent']! > 0)
            _buildStatRow('Patents', counts['patent'].toString(), Icons.lightbulb),
          if (counts['design']! > 0)
            _buildStatRow('Designs', counts['design'].toString(), Icons.design_services),
        ],
      ),
    );
  }

  Widget _buildResearchWorksSection() {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return InfoDisplayCard(
        title: 'Research Publications',
        icon: Icons.article_outlined,
        initiallyExpanded: true,
        child: _buildEmptyState(_error!),
      );
    }

    if (_grouped.isEmpty) {
      return InfoDisplayCard(
        title: 'Research Publications',
        icon: Icons.article_outlined,
        initiallyExpanded: true,
        child: _buildEmptyState('No research publications found in ORCID'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter chips
        _buildFilterChips(),
        const SizedBox(height: 16),

        // Works by year
        _buildWorksByYear(),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = {
      'all': 'All',
      'journal-article': 'Journals',
      'conference-paper': 'Conferences',
      'book-chapter': 'Chapters',
      'book': 'Books',
      'patent': 'Patents',
      'design': 'Designs',
    };

    return Card(
      elevation: 1,
      color: AppColors.pureWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters.entries.map((e) {
            final active = _selectedType == e.key;
            final count = e.key == 'all' 
                ? _grouped.values.fold(0, (sum, list) => sum + list.length)
                : (_grouped[e.key]?.length ?? 0);
            
            if (count == 0 && e.key != 'all') return const SizedBox.shrink();
            
            return FilterChip(
              label: Text('${e.value} ($count)'),
              selected: active,
              onSelected: (_) => setState(() => _selectedType = e.key),
              selectedColor: AppColors.academicBlue.withOpacity(0.2),
              checkmarkColor: AppColors.academicBlue,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildWorksByYear() {
    final Map<String, List<WorkItem>> byYear = {};
    final visible = _selectedType == 'all'
        ? _grouped
        : {_selectedType: _grouped[_selectedType] ?? []};

    visible.forEach((_, works) {
      for (final w in works) {
        final year = w.year ?? 'Unknown';
        byYear.putIfAbsent(year, () => []).add(w);
      }
    });

    final years = byYear.keys.toList()..sort((a, b) => b.compareTo(a));

    if (years.isEmpty) {
      return _buildEmptyState('No publications found for selected filter');
    }

    return Column(
      children: years.map((year) {
        final works = byYear[year]!;
        final expanded = _expandedYears[year] ?? true;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          color: AppColors.pureWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() {
                  _expandedYears[year] = !expanded;
                }),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.academicBlue,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        year,
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.universityNavy,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.academicBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${works.length} publication${works.length > 1 ? 's' : ''}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.academicBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (expanded)
                ...works.map((work) => _buildWorkCard(work)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWorkCard(WorkItem work) {
    final isCurrentYear = work.year == DateTime.now().year.toString();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            work.title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 8),

          // Source and Year
          Row(
            children: [
              Expanded(
                child: Text(
                  work.source ?? 'Source not specified',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mediumGray,
                  ),
                ),
              ),
              if (work.year != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.academicBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    work.year!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.academicBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Type Badge
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(_getTypeLabel(work.type), AppColors.universityNavy),
              
              // Identifiers
              if (work.identifiers.containsKey('doi'))
                _buildBadge('DOI: ${work.identifiers['doi']}', AppColors.academicBlue),
              if (work.identifiers.containsKey('isbn'))
                _buildBadge('ISBN: ${work.identifiers['isbn']}', AppColors.goldAccent),
            ],
          ),

          // Verification badges for current year
          if (isCurrentYear) ...[
            const SizedBox(height: 12),
            _buildVerificationBadges(work),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationBadges(WorkItem work) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('research_verifications')
          .where('facultyId', isEqualTo: widget.faculty.userModel.uid)
          .where('putCode', isEqualTo: work.putCode)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildBadge('PENDING VERIFICATION', AppColors.mediumGray);
        }

        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final String? decision = data['verificationDecision'];

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (data['isScopus'] == true)
              _buildBadge('SCOPUS', const Color(0xFF3B82F6)),
            if (data['isSci'] == true)
              _buildBadge('SCI', const Color(0xFF6366F1)),
            if (data['isIsbnVerified'] == true)
              _buildBadge('ISBN VERIFIED', const Color(0xFF14B8A6)),
            _buildBadge(
              decision ?? data['verificationStatus'] ?? 'PENDING',
              decision == 'VERIFIED' ? AppColors.successGreen : AppColors.mediumGray,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'journal-article':
        return 'Journal Article';
      case 'conference-paper':
        return 'Conference Paper';
      case 'book-chapter':
        return 'Book Chapter';
      case 'book':
        return 'Book';
      case 'patent':
        return 'Patent';
      case 'design':
        return 'Design';
      default:
        return type.toUpperCase();
    }
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.academicBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mediumGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.charcoal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.academicBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.charcoal,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.academicBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.academicBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.offWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.mediumGray, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyRegular.copyWith(color: AppColors.mediumGray),
            ),
          ),
        ],
      ),
    );
  }
}
