import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:archive/archive.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Processor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChatProcessorScreen(),
    );
  }
}

class ChatProcessorScreen extends StatefulWidget {
  const ChatProcessorScreen({super.key});

  @override
  State<ChatProcessorScreen> createState() => _ChatProcessorScreenState();
}

class _ChatProcessorScreenState extends State<ChatProcessorScreen> {
  late StreamSubscription _intentSub;
  String? _sharedFilePath;
  List<String> _processedChats = [];
  bool _isProcessing = false;
  final TextEditingController _delimiterController = TextEditingController();
  final TextEditingController _deleteTextController = TextEditingController();
  final TextEditingController _deleteText2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _delimiterController.text = '1'; // Default delimiter

    // Listen to media sharing while app is in memory
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen(
        (List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        setState(() {
          _sharedFilePath = value.first.path;
        });
        _processSharedFile();
        print("Shared file path: ${value.first.path}");
      }
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    // Get media sharing that launched the app
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        setState(() {
          _sharedFilePath = value.first.path;
        });
        _processSharedFile();
        print("Initial shared file path: ${value.first.path}");
        ReceiveSharingIntent.instance.reset();
      }
    });
  }

  @override
  void dispose() {
    _intentSub.cancel();
    _delimiterController.dispose();
    _deleteTextController.dispose();
    _deleteText2Controller.dispose();
    super.dispose();
  }

  Future<void> _processSharedFile() async {
    if (_sharedFilePath == null) return;

    setState(() {
      _isProcessing = true;
      _processedChats = [];
    });

    try {
      final bytes = File(_sharedFilePath!).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);

      final txtFile = archive.findFile('_chat.txt');
      if (txtFile == null) {
        throw Exception('No chat.txt file found in the archive');
      }

      final content = String.fromCharCodes(txtFile.content);
      final segments = _splitChat(content);

      setState(() {
        _processedChats = segments;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing file: ${e.toString()}')),
        );
      }
    }
  }

  List<String> _splitChat(String content) {
    final delimiter = _delimiterController.text;
    if (delimiter.isEmpty) return [content];

    final segments = content.split(delimiter);
    return segments.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  void _deleteMessagesContaining(String text) {
    if (text.isEmpty) return;

    setState(() {
      _processedChats = _processedChats
          .where(
              (message) => !message.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  void _deleteFirstMessage() {
    if (_processedChats.isNotEmpty) {
      setState(() {
        _processedChats.removeAt(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Processor'),
      ),
      body: Column(
        children: [
          // Control Panel
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Column(
              children: [
                // Delimiter Input
                TextField(
                  controller: _delimiterController,
                  decoration: InputDecoration(
                    labelText: 'Delimiter',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed:
                          _sharedFilePath != null ? _processSharedFile : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // First Delete Control
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _deleteTextController,
                        decoration: const InputDecoration(
                          labelText: 'Delete messages containing',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          _deleteMessagesContaining(_deleteTextController.text),
                    ),
                  ],
                ),

                // Second Delete Control
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _deleteText2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Delete messages containing (2)',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteMessagesContaining(
                          _deleteText2Controller.text),
                    ),
                  ],
                ),

                // Delete First Message Button
                ElevatedButton.icon(
                  onPressed: _deleteFirstMessage,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Delete First Message'),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: _isProcessing
                ? const Center(child: CircularProgressIndicator())
                : _processedChats.isEmpty
                    ? const Center(
                        child: Text(
                            'Share a zip file containing WhatsApp chat export'),
                      )
                    : ListView.builder(
                        itemCount: _processedChats.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(_processedChats[index]),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
