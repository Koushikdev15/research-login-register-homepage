import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {

  // =========================================================
  // SEND FDP DETAILS TO SIR
  // =========================================================

  static Future<void> sendFdpApprovalMail({

    required String facultyName,
    required String facultyEmail,
    required String title,
    required String organization,
    required String duration,
    required String type,
    required String imagePath,

  }) async {

    try {

      // =====================================================
      // GMAIL CONFIGURATION
      // =====================================================

      String username =
          "fdpstorecit@gmail.com";

      // 🔥 GOOGLE APP PASSWORD
      String password =
          "isys maxv sptd yypc";

      final smtpServer =
          gmail(username, password);

      // =====================================================
      // EMAIL BODY
      // =====================================================

      final message = Message()

        ..from = Address(
          username,
          "Research CSE",
        )

        ..recipients.add(
          "fdpstorecit@gmail.com",
        )

        ..subject =
            "Verified FDP - $facultyName"

        ..text = '''

Faculty FDP Verified Successfully

Faculty Name:
$facultyName

Faculty Email:
$facultyEmail

FDP Title:
$title

Organization:
$organization

Duration:
$duration

Type:
$type

Status:
Approved

Certificate attached below.

''';

      // =====================================================
      // DOWNLOAD IMAGE FROM URL
      // =====================================================

      if (imagePath.isNotEmpty) {

        try {

         final response =
    await http.get(

  Uri.parse(
    "https://drive.google.com/uc?export=download&id=$imagePath",
  ),
);

          final tempDir =
              Directory.systemTemp;

          final tempFile = File(
            '${tempDir.path}/certificate.jpg',
          );

          await tempFile.writeAsBytes(
            response.bodyBytes,
          );

          // =================================================
          // ATTACH IMAGE
          // =================================================

          message.attachments.add(
            FileAttachment(tempFile),
          );

        } catch (e) {

          print(
            "Attachment Error: $e",
          );
        }
      }

      // =====================================================
      // SEND EMAIL
      // =====================================================

      await send(
        message,
        smtpServer,
      );

      print(
        "FDP Email Sent Successfully",
      );

    } catch (e) {

      print(
        "Email Send Error: $e",
      );
    }
  }
}