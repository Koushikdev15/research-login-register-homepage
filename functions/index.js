const functions = require("firebase-functions");
const { google } = require("googleapis");

// Load service account
const serviceAccount = require("./serviceAccountKey.json");

// 🔴 VERY IMPORTANT: Replace with your REAL folder ID
const FOLDER_ID = "1OcyLh4sw2z11ljNHeVk2Mi-irZmnG3Xe";


exports.uploadCertificate = functions.https.onCall(async (data, context) => {
  try {
    // ✅ Check user authentication
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be logged in"
      );
    }

    const { base64File, fileName, mimeType } = data;

    if (!base64File || !fileName || !mimeType) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing required file data"
      );
    }

    // ✅ Create Google Auth client
    const auth = new google.auth.GoogleAuth({
      credentials: serviceAccount,
      scopes: ["https://www.googleapis.com/auth/drive"],
    });

    const drive = google.drive({
      version: "v3",
      auth,
    });

    // ✅ Convert base64 to buffer
    const buffer = Buffer.from(base64File, "base64");

    // ✅ Upload directly to Drive (no temp file)
    const response = await drive.files.create({
      requestBody: {
        name: fileName,
        parents: [FOLDER_ID],
      },
      media: {
        mimeType: mimeType,
        body: buffer,
      },
    });

    // ✅ Make file public (optional – remove if private needed)
    await drive.permissions.create({
      fileId: response.data.id,
      requestBody: {
        role: "reader",
        type: "anyone",
      },
    });

    const publicUrl = `https://drive.google.com/uc?id=${response.data.id}`;

    return {
      success: true,
      url: publicUrl,
      fileId: response.data.id,
    };
  } catch (error) {
    console.error("Upload Error:", error);

    throw new functions.https.HttpsError(
      "internal",
      "Certificate upload failed"
    );
  }
});
