import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FdbViewPage extends StatelessWidget {
  const FdbViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Soft background color for better readability
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
      ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authSnapshot.data;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('User not logged in', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('fdb_datum')
                .where('email', isEqualTo: user.email)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Error loading data',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 80, color: Colors.indigo.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      const Text('No FDP records found', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();

                  final startDate = (data['startDate'] as Timestamp?)?.toDate();
                  final endDate = (data['endDate'] as Timestamp?)?.toDate();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Left Color Accent Bar
                            Container(width: 6, color: Colors.indigo),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['title'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D3142),
                                            ),
                                          ),
                                        ),
                                        // Type Tag
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            data['type'] ?? 'N/A',
                                            style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 24),
                                    _buildInfoRow(Icons.business, 'Org', data['organization'] ?? 'N/A'),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(Icons.timer_outlined, 'Duration', data['duration'] ?? 'N/A'),
                                    const SizedBox(height: 8),
                                    if (startDate != null && endDate != null)
                                      _buildInfoRow(
                                        Icons.calendar_month_outlined, 
                                        'Period', 
                                        '${DateFormat('dd MMM yyyy').format(startDate)} - ${DateFormat('dd MMM yyyy').format(endDate)}'
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
                },
              );
            },
          );
        },
      ),
    );
  }

  // Modern Info Row Helper
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blueGrey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey)),
        Expanded(child: Text(value, style: const TextStyle(color: Colors.black87))),
      ],
    );
  }
}
