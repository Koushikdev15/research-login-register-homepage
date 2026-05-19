import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/faculty_provider.dart';
import '../admin/admin_scopus_screen.dart';

class AdminFacultyProfileView extends StatefulWidget {

  final String facultyId;

  const AdminFacultyProfileView({
    super.key,
    required this.facultyId,
  });

  @override
  State<AdminFacultyProfileView> createState() =>
      _AdminFacultyProfileViewState();
}

class _AdminFacultyProfileViewState
    extends State<AdminFacultyProfileView> {

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFaculty();
  }

  Future<void> _loadFaculty() async {

    try {

      final facultyProvider =
          Provider.of<FacultyProvider>(context, listen: false);

      await facultyProvider.loadFacultyProfile(
        widget.facultyId,
      );

    } catch (e) {

      debugPrint(
        "Error loading faculty: $e",
      );

    }

    if (mounted) {

      setState(() {
        _loading = false;
      });

    }
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {

      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );

    }

    final facultyProvider =
        Provider.of<FacultyProvider>(context);

    final faculty =
        facultyProvider.personalInfo;

    final research =
        facultyProvider.researchIDs;

    if (faculty == null) {

      return const Scaffold(
        body: Center(
          child: Text("Faculty not found"),
        ),
      );

    }

    return Scaffold(

      appBar: AppBar(
        title: Text(
          faculty.name,
        ),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// 👤 PROFILE CARD
            Card(
              elevation: 4,

              child: ListTile(

                leading: CircleAvatar(
                  radius: 28,

                  backgroundImage:
                      faculty.photoUrl != null
                          ? NetworkImage(
                              faculty.photoUrl!,
                            )
                          : null,

                  child:
                      faculty.photoUrl == null
                          ? const Icon(
                              Icons.person,
                            )
                          : null,
                ),

                title: Text(
                  faculty.name,
                ),

                subtitle: Text(
                  faculty.mailId,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔬 RESEARCH IDS
            Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    const Text(
                      "Research IDs",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      "ORCID: ${research?.orcidId ?? 'Not linked'}",
                    ),

                    Text(
                      "Google Scholar: ${research?.googleScholarId ?? 'Not linked'}",
                    ),

                    Text(
                      "Scopus ID: ${research?.scopusId ?? 'Not linked'}",
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 📊 SCOPUS BUTTON
            SizedBox(

              width: double.infinity,

              child: ElevatedButton.icon(

                icon: const Icon(
                  Icons.science,
                ),

                label: const Text(
                  "View Scopus Works",
                ),

                onPressed: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          AdminScopusScreen(

                        facultyId:
                            widget.facultyId,

                        facultyName:
                            faculty.name,

                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}