import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class DriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/drive.file',
  ],
  serverClientId:
      '419326217425-35gsfdn73qvkeskid96mi6rmkht8etn1.apps.googleusercontent.com',
);



  Future<drive.DriveApi?> _getDriveApi() async {
    final GoogleSignInAccount? account =
        await _googleSignIn.signIn();

    if (account == null) return null;

    final authHeaders = await account.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders);

    return drive.DriveApi(authenticateClient);
  }

 Future<String?> uploadFile({
  required File file,
  String? folderName,
}) async {
  final api = await _getDriveApi();
  if (api == null) return null;

  var media = drive.Media(file.openRead(), file.lengthSync());

  var driveFile = drive.File();
  driveFile.name = file.path.split("/").last;

  if (folderName != null) {
    final folderId = await _createFolderIfNotExists(api, folderName);
    driveFile.parents = [folderId];
  }

  final result = await api.files.create(
    driveFile,
    uploadMedia: media,
  );

  final fileId = result.id;

  if (fileId == null) return null;

  // 🔥 THIS IS THE MOST IMPORTANT PART
  await api.permissions.create(
    drive.Permission()
      ..type = 'anyone'
      ..role = 'reader',
    fileId,
  );

  return fileId;
}


  Future<String> _createFolderIfNotExists(
      drive.DriveApi api, String folderName) async {
    final fileList = await api.files.list(
      q: "mimeType='application/vnd.google-apps.folder' and name='$folderName'",
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      return fileList.files!.first.id!;
    }

    final folder = drive.File()
      ..name = folderName
      ..mimeType = "application/vnd.google-apps.folder";

    final createdFolder = await api.files.create(folder);
    return createdFolder.id!;
  }
}

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}