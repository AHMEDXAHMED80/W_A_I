import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:file_picker/file_picker.dart'; // Add this import for file picking
import 'whatsapp_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp API Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _mediaIdController = TextEditingController();
  final _whatsappService = WhatsAppService(
    'EAAmF6udwNqQBO56tzhwUpZA1BZBiT0LILZAbBRXqtHIOFDoi8cuVRwNHdfQ60k7mJBy8QVIE2cfXwOo2D5TlM0EZAMaZCKSVZCgQIfqKGb5mlhUTrWxVhnaJ1dlsbT1FpDSzKMJuW1GserxDAaBjn77ihZBVQQhBjaZA6rI6z7aBZAWu4QZAKnnHYNiHXHqPfZANNnrZCItkX3ZAMZB9pQuWQkqzquCL72FofKnZA8IAUoZD',
    '454799404376171',
  );

  // Add a method to pick the file
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      String filePath = result.files.single.path!;
      String? mediaId = await _whatsappService.uploadMedia(filePath);
      if (mediaId != null) {
        _mediaIdController.text = mediaId; // Store the media ID
        _showSnackBar('File uploaded successfully, media ID: $mediaId');
      } else {
        _showSnackBar('File upload failed');
      }
    }
  }

  void _sendMessage() async {
    final phoneNumber = _phoneController.text.trim();
    final message = _messageController.text.trim();

    if (phoneNumber.isNotEmpty && message.isNotEmpty) {
      try {
        var res = await _whatsappService.sendMessage(phoneNumber, message);
        _handleResponse(res);
      } catch (e) {
        _showSnackBar('Exception: $e');
      }
    } else {
      _showSnackBar('Please enter both phone number and message');
    }
  }

  void _sendDocument() async {
    final phoneNumber = _phoneController.text.trim();
    final mediaId = _mediaIdController.text.trim();

    if (phoneNumber.isNotEmpty && mediaId.isNotEmpty) {
      try {
        var res = await _whatsappService.sendDocumentById(
          phoneNumber,
          mediaId,
          caption: 'Document sent from Flutter app',
          fileName: 'document.pdf',
        );
        _handleResponse(res);
      } catch (e) {
        _showSnackBar('Exception: $e');
      }
    } else {
      _showSnackBar('Please enter both phone number and media ID');
    }
  }

  void _handleResponse(dynamic res) {
    if (res != null && !res.containsKey('error')) {
      _showSnackBar('Message sent successfully');
    } else {
      _showSnackBar('Error: ${res['error']}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String whatsappLink = "https://wa.me/15556265312?text=I+would+like+to+receive+my+receipt";

    return Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp API with QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number (with country code)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendMessage,
              child: Text('Send Message'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickFile, // Call the file picker
              child: Text('Pick File and Upload'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _mediaIdController,
              decoration: InputDecoration(
                labelText: 'Media ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _sendDocument,
              child: Text('Send Document'),
            ),
            SizedBox(height: 24.0),
            Text(
              'Scan the QR code below to send a message on WhatsApp:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Center(
              child: QrImageView(
                data: whatsappLink,
                version: QrVersions.auto,
                size: 200.0,
                gapless: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
