import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class FdbViewPage extends StatefulWidget {
  const FdbViewPage({super.key});

  @override
  State<FdbViewPage> createState() => _FdbViewPageState();
}

class _FdbViewPageState extends State<FdbViewPage> {

  Set<String> selectedTypes = {};

  Map<int, Map<String, List<Map<String, dynamic>>>>? _latestGroupedData;
  int _latestOverallTotal = 0;

  final Set<String> allTypes = {
    "NPTEL",
    "Online Course",
    "ATAL - FDP",
    "FDP",
    "Seminar",
    "Webinar",
    "Seminar Conducted",
    "Webinar Conducted",
    "FDP Conducted",
    "Awards",
    "Other Certificate",
  };

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Select Types",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: allTypes.map((type) {
                        return CheckboxListTile(
                          title: Text(type),
                          value: selectedTypes.contains(type),
                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                selectedTypes.add(type);
                              } else {
                                selectedTypes.remove(type);
                              }
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("OK"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _printReport(
  Map<int, Map<String, List<Map<String, dynamic>>>> groupedData,
  int overallTotal,
) async {

  final user = FirebaseAuth.instance.currentUser;

  // 🔥 Fetch Personal Info (NAME)
  final personalSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user!.uid)
      .collection('personalInfo')
      .doc('info')
      .get();

  final personalData = personalSnapshot.data();

  final String name = personalData?['name'] ?? 'N/A';
  final String email = personalData?['email'] ?? user.email ?? 'N/A';

  // 🔥 Fetch Research IDs
  final researchSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('researchIDs')
      .doc('ids')
      .get();

  final researchData = researchSnapshot.data();

  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [

        pw.Text(
          "Faculty Research Activity Report",
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 20),

        pw.Text("Name : $name"),
        pw.Text("Email : $email"),
        pw.Text("Google Scholar ID : ${researchData?['googleScholarId'] ?? 'N/A'}"),
        pw.Text("ORCID ID : ${researchData?['orcidId'] ?? 'N/A'}"),
        pw.Text("Scopus ID : ${researchData?['scopusId'] ?? 'N/A'}"),
        pw.Text("Vidwan ID : ${researchData?['vidwanId'] ?? 'N/A'}"),

        pw.SizedBox(height: 10),
        pw.Divider(),

        pw.Text(
          "Total Works : $overallTotal",
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),

        pw.SizedBox(height: 15),

        ...groupedData.entries.map((yearEntry) {

          final year = yearEntry.key;
          final typeMap = yearEntry.value;

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [

              pw.Text(
                "Year : $year",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 8),

              ...typeMap.entries.map((typeEntry) {

                final type = typeEntry.key;
                final records = typeEntry.value;

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [

                    pw.Text(
                      "Type : $type (${records.length})",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),

                    pw.SizedBox(height: 5),

                    ...records.map((data) {

                      final startDate =
                          (data['startDate'] as Timestamp?)?.toDate();
                      final endDate =
                          (data['endDate'] as Timestamp?)?.toDate();

                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 15, bottom: 8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [

                            pw.Text("Title : ${data['title'] ?? ''}"),
                            pw.Text("Organization : ${data['organization'] ?? ''}"),
                            pw.Text("Duration : ${data['duration'] ?? ''}"),

                            if (startDate != null && endDate != null)
                              pw.Text(
                                "Period : ${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}",
                              ),
                          ],
                        ),
                      );

                    }).toList(),

                    pw.SizedBox(height: 10),
                  ],
                );

              }).toList(),

              pw.SizedBox(height: 15),
            ],
          );

        }).toList(),
      ],
    ),
  );

  // 🔥 THIS OPENS FULL PREVIEW WITH ZOOM + SHARE + DOWNLOAD + PRINT
  final today = DateFormat('dd-MM-yyyy').format(DateTime.now());

// If you already fetched name from Firestore use that variable
final safeName = name.replaceAll(" ", "_");

await Printing.layoutPdf(
  name: "${safeName}_$today.pdf",
  onLayout: (format) async => pdf.save(),
);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text(
          'My FDP Records',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              if (_latestGroupedData != null) {
                _printReport(_latestGroupedData!, _latestOverallTotal);
              }
            },
          )
        ],
      ),

      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {

          if (!authSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authSnapshot.data;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('fdb_datum')
                .where('email', isEqualTo: user!.email)
                .snapshots(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              Map<int, Map<String, List<Map<String, dynamic>>>> groupedData = {};

              for (var doc in docs) {
                final data = doc.data();
                final startDate =
                    (data['startDate'] as Timestamp?)?.toDate();
                if (startDate == null) continue;

                int year = startDate.year;
                String type = data['type'] ?? "Unknown";

                if (selectedTypes.isNotEmpty &&
                    !selectedTypes.contains(type)) {
                  continue;
                }

                groupedData.putIfAbsent(year, () => {});
                groupedData[year]!.putIfAbsent(type, () => []);
                groupedData[year]![type]!.add(data);
              }

              int overallTotal = groupedData.values
                  .fold(0, (sum, typeMap) =>
                      sum + typeMap.values
                          .fold(0, (s, list) => s + list.length));

              _latestGroupedData = groupedData;
              _latestOverallTotal = overallTotal;

              final sortedYears = groupedData.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return Column(
                children: [

                  // TOTAL COUNT CARD
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("📊 Total Works",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("$overallTotal",
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo)),
                        ],
                      ),
                    ),
                  ),

                  // FILTER BAR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: GestureDetector(
                      onTap: _showFilterBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.filter_list,
                                    color: Colors.indigo),
                                const SizedBox(width: 8),
                                Text(
                                  selectedTypes.isEmpty
                                      ? "Filter"
                                      : "Filter (${selectedTypes.length} selected)",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: sortedYears.map((year) {

                        var typeMap = groupedData[year]!;

                        int totalCount = typeMap.values
                            .fold(0, (sum, list) => sum + list.length);

                        return ExpansionTile(
                          title: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text("📅 $year",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo)),
                              Text("$totalCount Works",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          children: typeMap.entries.map((entry) {

                            String type = entry.key;
                            List<Map<String, dynamic>> records =
                                entry.value;

                            return ExpansionTile(
                              title: Text(
                                "📂 $type (${records.length})",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              children: records.map((data) {

                                final startDate =
                                    (data['startDate'] as Timestamp?)
                                        ?.toDate();
                                final endDate =
                                    (data['endDate'] as Timestamp?)
                                        ?.toDate();

                                return Container(
                                  margin:
                                      const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withOpacity(0.05),
                                        blurRadius: 10,
                                        offset:
                                            const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    child: IntrinsicHeight(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Container(
                                              width: 6,
                                              color:
                                                  Colors.indigo),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets
                                                      .all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            Text(
                                                          data['title'] ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                            fontSize:
                                                                18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            color:
                                                                Color(
                                                                    0xFF2D3142),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    8,
                                                                vertical:
                                                                    4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .indigo
                                                              .withOpacity(
                                                                  0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  8),
                                                        ),
                                                        child: Text(
                                                          data['type'] ??
                                                              'N/A',
                                                          style:
                                                              const TextStyle(
                                                            fontSize:
                                                                12,
                                                            color:
                                                                Colors.indigo,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Divider(
                                                      height: 24),
                                                  _buildInfoRow(
                                                      Icons.business,
                                                      'Organization',
                                                      data['organization'] ??
                                                          'N/A'),
                                                  const SizedBox(
                                                      height: 8),
                                                  _buildInfoRow(
                                                      Icons.timer_outlined,
                                                      'Duration',
                                                      data['duration'] ??
                                                          'N/A'),
                                                  const SizedBox(
                                                      height: 8),
                                                  if (startDate != null &&
                                                      endDate != null)
                                                    _buildInfoRow(
                                                      Icons
                                                          .calendar_month_outlined,
                                                      'Period',
                                                      '${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}',
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey)),
        Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.black87))),
      ],
    );
  }
}  