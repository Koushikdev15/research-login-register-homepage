/// ======================================================
/// 🔹 PDF EXPORT OPTIONS MODEL
/// ======================================================

enum YearFilterType {
  all,
  currentYear,
  specificYear,
}

class PdfExportOptions {
  final YearFilterType yearFilter;

  /// Only used when yearFilter == specificYear
  final int? specificYear;

  /// null = all work types
  final String? workTypeFilter;

  const PdfExportOptions({
    this.yearFilter = YearFilterType.all,
    this.specificYear,
    this.workTypeFilter,
  });

  /// Resolved list of year strings to fetch from Firestore.
  /// Returns null if all years should be fetched.
  String? resolvedYearString() {
    switch (yearFilter) {
      case YearFilterType.all:
        return null;
      case YearFilterType.currentYear:
        return DateTime.now().year.toString();
      case YearFilterType.specificYear:
        return specificYear?.toString();
    }
  }

  bool matchesYear(String yearDocId) {
    final resolved = resolvedYearString();
    if (resolved == null) return true;
    return yearDocId == resolved;
  }

  bool matchesWorkType(String workType) {
    if (workTypeFilter == null) return true;
    return workType == workTypeFilter;
  }
}