import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/email_service.dart';

class FdbVerificationPage extends StatelessWidget {
  const FdbVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          "FDB & Certificate Verification",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('fdb_datum')
              .where('status', isEqualTo: 'pending')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            if (!snapshot.hasData ||
                snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "No pending verifications 🎉",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            var docs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                var doc = docs[index];
                final data =
                    doc.data() as Map<String, dynamic>;

                return Card(
                  margin:
                      const EdgeInsets.only(bottom: 20),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        Text(
                          "Faculty: ${data['name'] ?? ''}",
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text("Title: ${data['title'] ?? ''}"),
                        Text("Organization: ${data['organization'] ?? ''}"),
                        Text("Duration: ${data['duration'] ?? ''}"),

                        const SizedBox(height: 12),

                        /// 🔥 FIXED CERTIFICATE IMAGE
                        if (data['photoUrl'] != null &&
                            data['photoUrl']
                                .toString()
                                .isNotEmpty)
                          Builder(
                            builder: (context) {
                              final String fileId =
                                  data['photoUrl'];

                              final String imageUrl =
                                  "https://drive.google.com/uc?export=view&id=$fileId";

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          FullImageView(
                                              imageUrl:
                                                  imageUrl),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(10),
                                  child: Image.network(
                                    imageUrl,
                                    height: 170,
                                    width:
                                        double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [

                            /// APPROVE
                            ElevatedButton.icon(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.green,
                              ),
                             onPressed: () async {

  try {

    // =====================================================
    // UPDATE STATUS
    // =====================================================

    await FirebaseFirestore.instance
        .collection('fdb_datum')
        .doc(doc.id)
        .update({

      'status': 'approved',

    });

    // =====================================================
    // SEND EMAIL
    // =====================================================

    await EmailService.sendFdpApprovalMail(

      facultyName:
          data['name'] ?? 'Unknown',

      facultyEmail:
          data['email'] ?? 'Unknown',

      title:
          data['title'] ?? 'Unknown',

      organization:
          data['organization'] ?? 'Unknown',

      duration:
          data['duration'] ?? 'Unknown',

      type:
          data['type'] ?? 'FDP',

      imagePath:
          data['photoUrl'] ?? '',
    );

    // =====================================================
    // SUCCESS
    // =====================================================

    if (context.mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content: Text(
            "FDP Approved & Email Sent",
          ),
        ),
      );
    }

  } catch (e) {

    if (context.mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content: Text(
            "Error: $e",
          ),
        ),
      );
    }
  }
},
                              icon: const Icon(Icons.check),
                              label:
                                  const Text("Approve"),
                            ),

                            const SizedBox(width: 10),

                            /// REJECT
                            ElevatedButton.icon(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.red,
                              ),
                              onPressed: () async {
                                await FirebaseFirestore
                                    .instance
                                    .collection(
                                        'fdb_datum')
                                    .doc(doc.id)
                                    .update({
                                  'status': 'rejected',
                                });
                              },
                              icon: const Icon(Icons.close),
                              label:
                                  const Text("Reject"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// 🔥 FULL SCREEN ZOOM VIEW
class FullImageView extends StatelessWidget {
  final String imageUrl;

  const FullImageView({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}