import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/researchid_work.dart';

class ScopusWorkCard extends StatelessWidget {
  final ResearchIdWork work;

  const ScopusWorkCard({super.key, required this.work});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception("Could not open $url");
    }
  }

  String _extractDate(String text) {
    final months = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];

    for (var m in months) {
      if (text.contains(m)) {
        final yearMatch = RegExp(r'\d{4}').firstMatch(text);
        if (yearMatch != null) {
          return "$m ${yearMatch.group(0)}";
        }
      }
    }

    final yearMatch = RegExp(r'\d{4}').firstMatch(text);
    if (yearMatch != null) {
      return yearMatch.group(0)!;
    }

    return "Year Unknown";
  }

  @override
  Widget build(BuildContext context) {

    final date = _extractDate(work.description);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            Text(
              work.title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            /// DATE
            Text(
              date,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            /// AUTHORS
            if (work.authors.isNotEmpty)
              Text(
                work.authors,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),

            const SizedBox(height: 6),

            /// JOURNAL / PUBLISHER
            if (work.publisher.isNotEmpty)
              Text(
                work.publisher,
                style: const TextStyle(
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),

            const SizedBox(height: 14),

            /// ACTION BUTTONS
            Row(
              children: [

                if (work.doiUrl.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () => _openUrl(work.doiUrl),
                    icon: const Icon(Icons.link, size: 18),
                    label: const Text("DOI"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),

                const SizedBox(width: 12),

                if (work.doiUrl.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () => _openUrl(work.doiUrl),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text("Source"),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}