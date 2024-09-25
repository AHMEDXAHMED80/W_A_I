import 'package:http/http.dart' as http;
import 'dart:convert';

class WhatsAppService {
  final String accessToken;
  final String phoneNumberId;

  WhatsAppService(this.accessToken, this.phoneNumberId);

  Future<dynamic> sendMessage(String phoneNumber, String message) async {
    final url = 'https://graph.facebook.com/v13.0/$phoneNumberId/messages';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'messaging_product': 'whatsapp',
        'to': phoneNumber,
        'text': {'body': message},
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': response.body};
    }
  }

  Future<String?> uploadMedia(String filePath) async {
    final url = 'https://graph.facebook.com/v13.0/$phoneNumberId/media'; // Media upload endpoint

    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $accessToken';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final mediaId = jsonDecode(String.fromCharCodes(responseData))['id'];
      return mediaId;  // Return the media ID
    } else {
      return null;  // Handle error appropriately in the UI
    }
  }

  Future<dynamic> sendDocumentById(String phoneNumber, String mediaId, {String? caption, String? fileName}) async {
    final url = 'https://graph.facebook.com/v13.0/$phoneNumberId/messages';

    final body = {
      'messaging_product': 'whatsapp',
      'to': phoneNumber,
      'type': 'document',
      'document': {
        'id': mediaId,
        if (caption != null) 'caption': caption,
        if (fileName != null) 'filename': fileName,
      },
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'error': response.body};
    }
  }
}
