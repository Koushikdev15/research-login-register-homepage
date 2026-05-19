import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

import '../models/researchid_work.dart';

class ResearchIdService {

  /// Render proxy URL
  static const String proxyUrl =
      "https://researchid-proxy-1.onrender.com/researchid/";

  /// MAIN METHOD USED BY APP
  static Future<List<ResearchIdWork>> fetchWorks(String researcherId) async {

    final url = Uri.parse("$proxyUrl$researcherId");

    final response = await http.get(
      url,
      headers: {
        "User-Agent":
            "Mozilla/5.0 (Android 10; Mobile; rv:109.0) Gecko/109.0 Firefox/117.0",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch ResearchID page (${response.statusCode})");
    }

    final document = parser.parse(response.body);

    List<ResearchIdWork> works = [];

    /// Find the "Scopus Publications" section
    final headers = document.querySelectorAll("h2");

    Element? scopusHeader;

    for (final h in headers) {
      if (h.text.contains("Scopus Publications")) {
        scopusHeader = h;
        break;
      }
    }

    if (scopusHeader == null) {
      throw Exception("Scopus Publications section not found");
    }

    /// Find publication list
    final ul = scopusHeader.parent?.querySelector("ul");

    if (ul == null) {
      throw Exception("Scopus publication list not found");
    }

    final items = ul.querySelectorAll("li");

    for (final item in items) {

      final link = item.querySelector("a");
      if (link == null) continue;

      final title = link.text.trim();
      final doiUrl = link.attributes["href"] ?? "";

      final spans = item.querySelectorAll("span");

      String authors = "";
      String publisher = "";
      String description = "";

      /// Authors
      if (spans.length > 1) {
        authors = spans[1]
            .text
            .replaceAll("\n", " ")
            .replaceAll("  ", " ")
            .trim();
      }

      /// Publisher + description
      if (spans.length > 2) {

        final text = spans[2].text.trim();
        final lines = text.split("\n");

        if (lines.isNotEmpty) {
          publisher = lines.first.trim();
        }

        if (lines.length > 1) {
          description = lines
              .sublist(1)
              .join(" ")
              .replaceAll("\n", " ")
              .trim();
        }
      }

      works.add(
        ResearchIdWork(
          title: title,
          authors: authors,
          publisher: publisher,
          description: description,
          doiUrl: doiUrl,
        ),
      );
    }

    return works;
  }

  /// OPTIONAL: Direct fetch (for testing only)
  static Future<List<ResearchIdWork>> fetchWorksDirect(String researcherId) async {

    final url = Uri.parse("https://researchid.co/$researcherId");

    final response = await http.get(
      url,
      headers: {
        "User-Agent":
            "Mozilla/5.0 (Android 10; Mobile; rv:109.0) Gecko/109.0 Firefox/117.0",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Direct request failed (${response.statusCode})");
    }

    final document = parser.parse(response.body);

    List<ResearchIdWork> works = [];

    final headers = document.querySelectorAll("h2");

    Element? scopusHeader;

    for (final h in headers) {
      if (h.text.contains("Scopus Publications")) {
        scopusHeader = h;
        break;
      }
    }

    if (scopusHeader == null) {
      throw Exception("Scopus section not found");
    }

    final ul = scopusHeader.parent?.querySelector("ul");

    if (ul == null) {
      throw Exception("Publication list not found");
    }

    final items = ul.querySelectorAll("li");

    for (final item in items) {

      final link = item.querySelector("a");
      if (link == null) continue;

      final title = link.text.trim();
      final doiUrl = link.attributes["href"] ?? "";

      final spans = item.querySelectorAll("span");

      String authors = "";
      String publisher = "";
      String description = "";

      if (spans.length > 1) {
        authors = spans[1].text.replaceAll("\n", " ").trim();
      }

      if (spans.length > 2) {

        final text = spans[2].text.trim();
        final lines = text.split("\n");

        if (lines.isNotEmpty) {
          publisher = lines.first.trim();
        }

        if (lines.length > 1) {
          description = lines.sublist(1).join(" ").trim();
        }
      }

      works.add(
        ResearchIdWork(
          title: title,
          authors: authors,
          publisher: publisher,
          description: description,
          doiUrl: doiUrl,
        ),
      );
    }

    return works;
  }
}