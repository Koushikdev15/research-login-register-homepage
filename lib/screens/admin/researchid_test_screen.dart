import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/researchid_service.dart';
import '../../models/researchid_work.dart';

class ResearchIdTestScreen extends StatefulWidget {
  const ResearchIdTestScreen({Key? key}) : super(key: key);

  @override
  State<ResearchIdTestScreen> createState() => _ResearchIdTestScreenState();
}

class _ResearchIdTestScreenState extends State<ResearchIdTestScreen> {

  final TextEditingController controller = TextEditingController();

  /// Proxy results
  List<ResearchIdWork> proxyWorks = [];
  bool proxyLoading = false;
  String proxyError = "";

  /// Direct results
  List<ResearchIdWork> directWorks = [];
  bool directLoading = false;
  String directError = "";

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  /// FETCH VIA PROXY
  Future<void> fetchProxy() async {

    final id = controller.text.trim();

    if (id.isEmpty) {
      setState(() => proxyError = "Enter Researcher ID");
      return;
    }

    setState(() {
      proxyLoading = true;
      proxyError = "";
      proxyWorks.clear();
    });

    try {

      final result = await ResearchIdService.fetchWorks(id);

      setState(() {
        proxyWorks = result;
      });

      if (result.isEmpty) {
        proxyError = "No Scopus publications found.";
      }

    } catch (e) {

      setState(() {
        proxyError = "Proxy fetch failed: $e";
      });

    } finally {

      setState(() {
        proxyLoading = false;
      });
    }
  }

  /// FETCH DIRECTLY
  Future<void> fetchDirect() async {

    final id = controller.text.trim();

    if (id.isEmpty) {
      setState(() => directError = "Enter Researcher ID");
      return;
    }

    setState(() {
      directLoading = true;
      directError = "";
      directWorks.clear();
    });

    try {

      final result = await ResearchIdService.fetchWorksDirect(id);

      setState(() {
        directWorks = result;
      });

      if (result.isEmpty) {
        directError = "No Scopus publications found.";
      }

    } catch (e) {

      setState(() {
        directError = "Direct fetch failed: $e";
      });

    } finally {

      setState(() {
        directLoading = false;
      });
    }
  }

  /// OPEN DOI LINK
  Future<void> openUrl(String url) async {

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      launchUrl(uri);
    }
  }

  /// WORK CARD
  Widget buildWorkCard(ResearchIdWork work) {

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// TITLE
            Text(
              work.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            /// AUTHORS
            if (work.authors.isNotEmpty)
              Text(
                work.authors,
                style: const TextStyle(fontSize: 14),
              ),

            const SizedBox(height: 8),

            /// PUBLISHER
            if (work.publisher.isNotEmpty)
              Text(
                "Journal / Publisher: ${work.publisher}",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.blueGrey,
                ),
              ),

            const SizedBox(height: 6),

            /// DOI LINK
            if (work.doiUrl.isNotEmpty)
              InkWell(
                onTap: () => openUrl(work.doiUrl),
                child: const Text(
                  "View Source",
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// HEADER INPUT
  Widget buildHeader() {

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [

          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: "Researcher ID",
              hintText: "Example: muthu1990",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.search),
            ),
          ),

          const SizedBox(height: 20),

          /// PROXY BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: proxyLoading ? null : fetchProxy,
              icon: const Icon(Icons.cloud_download),
              label: const Text("Fetch via Proxy Server"),
            ),
          ),

          const SizedBox(height: 10),

          /// DIRECT BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: directLoading ? null : fetchDirect,
              icon: const Icon(Icons.public),
              label: const Text("Fetch Directly"),
            ),
          ),
        ],
      ),
    );
  }

  /// WORK LIST SECTION
  Widget buildResultSection(
      String title,
      List<ResearchIdWork> works,
      bool loading,
      String error,
      ) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        if (loading)
          const Center(child: CircularProgressIndicator()),

        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        if (works.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              "${works.length} Scopus publications found",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

        if (works.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: works.length,
            itemBuilder: (context, index) {
              return buildWorkCard(works[index]);
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("ResearchID Scopus Test"),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            buildHeader(),

            const Divider(thickness: 2),

            /// PROXY RESULTS
            buildResultSection(
              "Proxy Server Results",
              proxyWorks,
              proxyLoading,
              proxyError,
            ),

            const Divider(thickness: 2),

            /// DIRECT RESULTS
            buildResultSection(
              "Direct Request Results",
              directWorks,
              directLoading,
              directError,
            ),
          ],
        ),
      ),
    );
  }
}