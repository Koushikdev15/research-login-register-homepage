import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'fdb_add_page.dart';
import 'fdb_view_page.dart';

class FdbSelectionPage extends StatelessWidget {
  final String? overrideEmail;

  const FdbSelectionPage({
    super.key,
    this.overrideEmail,
  });
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

   final email = overrideEmail ?? authProvider.currentUser?.email;
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [

              const SizedBox(height: 20),

              /// HEADER
              Row(
                children: [
                  Icon(Icons.workspace_premium,
                      color: Colors.indigo[900], size: 28),
                  const SizedBox(width: 10),
                  Text(
                    "Certification Portal",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// BUTTON ROW
              Row(
                children: [

                  /// ADD CERTIFICATE
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Certificate"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                           builder: (_) => FdbAddPage(
                           overrideEmail: overrideEmail,
                          ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[700],
                        foregroundColor: Colors.white,
                        elevation: 3,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  /// VIEW CERTIFICATES
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.list_alt),
                      label: const Text("View Certificates"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FdbViewPage(
  overrideEmail: overrideEmail,
),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700],
                        foregroundColor: Colors.white,
                        elevation: 3,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              /// CERTIFICATE COUNTS
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("fdb_datum")
                     .where("email", isEqualTo: email)
                      .snapshots(),
                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    /// TOTAL
                    int total = 0;

                    /// STATUS COUNTS
                    int verified = 0;
                    int pending = 0;
                    int rejected = 0;

                    /// TYPE COUNTS
                    int nptel = 0;
                    int onlineCourse = 0;
                    int atalFdp = 0;
                    int fdp = 0;
                    int seminar = 0;
                    int webinar = 0;
                    int seminarConducted = 0;
                    int webinarConducted = 0;
                    int fdpConducted = 0;
                    int awards = 0;
                    int otherCertificate = 0;

                    for (var doc in snapshot.data!.docs) {

                      total++;

                      final data =
                          doc.data() as Map<String, dynamic>;

                      final status = (data["status"] ?? "pending")
                          .toString()
                          .toLowerCase();

                      final type = (data["type"] ?? "")
                          .toString();

                      /// STATUS COUNT
                      if (status == "approved") {
                        verified++;
                      } else if (status == "rejected") {
                        rejected++;
                      } else {
                        pending++;
                      }

                      /// TYPE COUNT
                      if (type == "NPTEL") nptel++;
                      else if (type == "Online Course") onlineCourse++;
                      else if (type == "ATAL - FDP") atalFdp++;
                      else if (type == "FDP") fdp++;
                      else if (type == "Seminar") seminar++;
                      else if (type == "Webinar") webinar++;
                      else if (type == "Seminar Conducted") seminarConducted++;
                      else if (type == "Webinar Conducted") webinarConducted++;
                      else if (type == "FDP Conducted") fdpConducted++;
                      else if (type == "Awards") awards++;
                      else if (type == "Other Certificate") otherCertificate++;
                    }

                    return ListView(
                      children: [

                        /// TOTAL
                        _statCard(
                          "Total Certificates",
                          total,
                          Icons.storage,
                          Colors.blue,
                        ),

                        const SizedBox(height: 10),

                        /// STATUS
                        _statCard(
                          "Verified",
                          verified,
                          Icons.verified,
                          Colors.green,
                        ),

                        _statCard(
                          "Pending",
                          pending,
                          Icons.pending_actions,
                          Colors.orange,
                        ),

                        _statCard(
                          "Rejected",
                          rejected,
                          Icons.cancel,
                          Colors.red,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Type Summary",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        _statCard(
                            "NPTEL", nptel, Icons.school, Colors.indigo),

                        _statCard(
                            "Online Course",
                            onlineCourse,
                            Icons.computer,
                            Colors.blue),

                        _statCard(
                            "ATAL - FDP",
                            atalFdp,
                            Icons.menu_book,
                            Colors.deepPurple),

                        _statCard(
                            "FDP", fdp, Icons.school_outlined, Colors.teal),

                        _statCard(
                            "Seminar", seminar, Icons.mic, Colors.orange),

                        _statCard(
                            "Webinar", webinar, Icons.video_call, Colors.pink),

                        _statCard(
                            "Seminar Conducted",
                            seminarConducted,
                            Icons.record_voice_over,
                            Colors.brown),

                        _statCard(
                            "Webinar Conducted",
                            webinarConducted,
                            Icons.live_tv,
                            Colors.green),

                        _statCard(
                            "FDP Conducted",
                            fdpConducted,
                            Icons.school,
                            Colors.red),

                        _statCard(
                            "Awards",
                            awards,
                            Icons.emoji_events,
                            Colors.amber),

                        _statCard(
                            "Other Certificate",
                            otherCertificate,
                            Icons.description,
                            Colors.grey),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// CARD UI
  Widget _statCard(
      String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}