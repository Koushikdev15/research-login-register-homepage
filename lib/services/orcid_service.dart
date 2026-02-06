import 'dart:convert';
import 'package:http/http.dart' as http;

/// ======================================================
/// 🔹 WORK MODEL (PURE ORCID CLAIM)
/// ======================================================
class WorkItem {
  final String title;
  final String type;
  final String putCode;

  final String? year;
  final String? month;
  final String? day;

  final String? source;
  final Map<String, String> identifiers;
  final String? url;

  WorkItem({
    required this.title,
    required this.type,
    required this.putCode,
    this.year,
    this.month,
    this.day,
    this.source,
    required this.identifiers,
    this.url,
  });
}

/// ======================================================
/// 🔹 ORCID SERVICE (CLAIMS ONLY)
/// ======================================================
class OrcidService {
  static const String _baseUrl = 'https://pub.orcid.org/v3.0';
  static const Map<String, String> _headers = {
    'Accept': 'application/vnd.orcid+json',
  };

  // -------------------------------
  // SAFE HELPERS
  // -------------------------------
  static String? _s(dynamic v) =>
      (v is String && v.trim().isNotEmpty) ? v : null;

  static List _l(dynamic v) => v is List ? v : [];

  // -------------------------------
  // PARSE SINGLE WORK
  // -------------------------------
  static WorkItem? _parseWork(List summaries) {
    if (summaries.isEmpty) return null;
    final primary = summaries.first;

    final String title =
        primary['title']?['title']?['value'] ?? 'Untitled';

    final String type = primary['type'] ?? 'unknown';

    final String putCode =
        primary['put-code']?.toString() ?? 'UNKNOWN';

    final String? year =
        _s(primary['publication-date']?['year']?['value']);
    final String? month =
        _s(primary['publication-date']?['month']?['value']);
    final String? day =
        _s(primary['publication-date']?['day']?['value']);

    final String? source =
        _s(primary['journal-title']?['value']) ??
        _s(primary['source']?['source-name']?['value']);

    final String? url = _s(primary['url']?['value']);

    final Map<String, String> identifiers = {};

    for (final summary in summaries) {
      if (summary['external-ids'] != null && summary['external-ids']['external-id'] != null) {
        for (final id in _l(summary['external-ids']['external-id'])) {
          final type = _s(id['external-id-type']);
          final value = _s(id['external-id-value']);
          if (type != null && value != null) {
            identifiers[type] = value;
          }
        }
      }
    }

    return WorkItem(
      title: title,
      type: type,
      putCode: putCode,
      year: year,
      month: month,
      day: day,
      source: source,
      identifiers: identifiers,
      url: url,
    );
  }

  // ======================================================
  // 🔹 FETCH + GROUP WORKS (TYPE → LIST)
  // ======================================================
  static Future<Map<String, List<WorkItem>>> fetchGroupedWorks(
    String orcidId,
  ) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/$orcidId/works'),
        headers: _headers,
      );

      if (res.statusCode != 200) return {};

      final data = json.decode(res.body);
      final Map<String, List<WorkItem>> grouped = {};

      if (data['group'] != null) {
        for (final group in _l(data['group'])) {
          final summaries = _l(group['work-summary']);
          final item = _parseWork(summaries);
          if (item == null) continue;

          grouped.putIfAbsent(item.type, () => []).add(item);
        }
      }

      return grouped;
    } catch (_) {
      return {};
    }
  }

  // ======================================================
  // 🔹 FETCH COUNTS
  // ======================================================
  static Future<Map<String, int>> fetchWorkCounts(
    String orcidId,
  ) async {
    final grouped = await fetchGroupedWorks(orcidId);

    int journal = 0,
        conference = 0,
        bookChapter = 0,
        book = 0,
        patent = 0,
        design = 0;

    grouped.forEach((type, works) {
      switch (type) {
        case 'journal-article':
          journal += works.length;
          break;
        case 'conference-paper':
          conference += works.length;
          break;
        case 'book-chapter':
          bookChapter += works.length;
          break;
        case 'book':
          book += works.length;
          break;
        case 'patent':
          patent += works.length;
          break;
        case 'design':
          design += works.length;
          break;
      }
    });

    return {
      'total': grouped.values.fold(0, (a, b) => a + b.length),
      'journal': journal,
      'conference': conference,
      'bookChapter': bookChapter,
      'book': book,
      'patent': patent,
      'design': design,
    };
  }
}