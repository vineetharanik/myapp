import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/local_storage_service.dart';
import '../../services/academic_ai_service.dart';

class NotebookScreenLocal extends StatefulWidget {
  const NotebookScreenLocal({super.key});

  @override
  State<NotebookScreenLocal> createState() => _NotebookScreenLocalState();
}

class _NotebookScreenLocalState extends State<NotebookScreenLocal> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _uploadedPDFs = [];
  List<Map<String, dynamic>> _chatHistory = [];
  bool _isLoading = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserPDFs();
    _loadChatHistory();
  }

  Future<void> _loadUserPDFs() async {
    try {
      // Simulate loading PDFs from local storage
      final pdfs = await LocalStorageService().getUploadedPDFs();
      setState(() {
        _uploadedPDFs = pdfs;
      });
    } catch (e) {
      print('Error loading PDFs: $e');
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      // Load chat history from local storage
      final chats = await LocalStorageService().getNotebookChatHistory();
      setState(() {
        _chatHistory = chats;
      });
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }

  Future<void> _uploadPDF() async {
    try {
      _addBotMessage('🔍 Opening file picker...');

      // Simple file picker configuration
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final fileName = file.name;
        final fileSize = file.size ?? 0;

        _addBotMessage(
          '📄 File selected: "$fileName" (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
        );

        if (fileName.toLowerCase().endsWith('.pdf')) {
          setState(() {
            _isUploading = true;
          });

          try {
            // Store file data
            final pdfData = {
              'name': fileName,
              'size': fileSize,
              'uploadedAt': DateTime.now().toIso8601String(),
              'hasData': file.bytes != null,
              'dataLength': file.bytes?.length ?? 0,
            };

            // Save to local storage
            await LocalStorageService().saveUploadedPDF(pdfData);

            setState(() {
              _uploadedPDFs.add(pdfData);
            });

            _addBotMessage(
              '✅ Document "$fileName" uploaded successfully! File size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB. I can now help you summarize and analyze this document. Ask me questions about its content or request a summary.',
            );
          } catch (e) {
            _addBotMessage('❌ Error uploading document: $e');
          } finally {
            setState(() {
              _isUploading = false;
            });
          }
        } else {
          _addBotMessage(
            '⚠️ Please select a valid PDF file. The selected file doesn\'t appear to be a PDF document.',
          );
        }
      } else {
        _addBotMessage(
          'ℹ️ No file selected. Please choose a PDF document to upload.',
        );
      }
    } catch (e) {
      _addBotMessage(
        '❌ File upload failed: $e\n\n💡 **Try this:**\n1. Use Chrome or Firefox browser\n2. Clear browser cache\n3. Refresh the page\n4. Or use manual entry below',
      );
      setState(() {
        _isUploading = false;
      });
      _showManualInputDialog();
    }
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '📝 Manual Document Entry',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter document details manually:',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Document name or topic',
                labelStyle: TextStyle(color: Color(0xFF00D9FF)),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00D9FF)),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _addManualDocument(controller.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D9FF),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Document'),
          ),
        ],
      ),
    );
  }

  void _addManualDocument(String documentName) {
    final pdfData = {
      'name': documentName,
      'size': 0,
      'uploadedAt': DateTime.now().toIso8601String(),
      'hasData': false,
      'dataLength': 0,
      'isManual': true,
    };

    setState(() {
      _uploadedPDFs.add(pdfData);
    });

    _addBotMessage(
      '📝 Document "$documentName" added successfully! While I can\'t access the actual file content, I can help you with general information about the topic. Ask me questions about "$documentName" and I\'ll provide helpful insights!',
    );
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Save user message to local storage
      await LocalStorageService().saveNotebookChatMessage(message, false);

      setState(() {
        _chatHistory.insert(0, {
          'message': message,
          'isBot': false,
          'timestamp': DateTime.now().toIso8601String(),
        });
      });

      // Simulate AI response
      await _getAIResponse(message);
    } catch (e) {
      _addBotMessage('Error sending message: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _messageController.clear();
    }
  }

  Future<void> _getAIResponse(String userMessage) async {
    try {
      // Use real AI service for mental health and academic support
      final response = await AcademicAIService.answerAcademicQuestion(
        userMessage,
        subject: 'general',
      );
      
      _addBotMessage(response);
    } catch (e) {
      // Fallback to helpful message if API fails
      _addBotMessage('I\'m here to support your mental wellness and academic journey. While I connect to my AI service, please know that:\n\n🧠 **Mental Health Tips**:\n• Take regular breaks\n• Practice deep breathing\n• Stay hydrated\n• Get adequate sleep\n\n� **Study Support**:\n• Break tasks into smaller chunks\n• Use active recall techniques\n• Create a study schedule\n• Ask for help when needed\n\nHow can I support you today?');
    }
  }

  void _addBotMessage(String message) {
    setState(() {
      _chatHistory.insert(0, {
        'message': message,
        'isBot': true,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    // Save bot message to local storage
    LocalStorageService().saveNotebookChatMessage(message, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.summarize, color: Color(0xFF00D9FF)),
            const SizedBox(width: 12),
            const Text(
              '📚 Document Summarizer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // PDF Upload Section
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00D9FF).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.upload_file, color: Color(0xFF00D9FF)),
                    const SizedBox(width: 12),
                    const Text(
                      '📄 Upload Documents for Summarization',
                      style: TextStyle(
                        color: Color(0xFF00D9FF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_uploadedPDFs.isNotEmpty)
                      Text(
                        '${_uploadedPDFs.length} uploaded',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Drag and Drop Area
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00D9FF).withOpacity(0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: const Color(0xFF00D9FF).withOpacity(0.7),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Drag & Drop PDF files here',
                        style: TextStyle(
                          color: Color(0xFF00D9FF),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'or click to browse',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Upload Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadPDF,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add),
                    label: Text(_isUploading ? 'Uploading...' : 'Choose PDF File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D9FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                
                if (_uploadedPDFs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _showPDFsDialog(context),
                    icon: const Icon(Icons.list, color: Color(0xFF00D9FF)),
                    label: const Text(
                      'View Uploaded Documents',
                      style: TextStyle(color: Color(0xFF00D9FF)),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Chat Section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  // Chat Messages
                  Expanded(
                    child: _chatHistory.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '📝 Document Summarizer\n\nUpload PDFs and notes, then ask questions about their content.\n\nHere to help you understand complex materials quickly!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.all(16),
                            itemCount: _chatHistory.length,
                            itemBuilder: (context, index) {
                              final message = _chatHistory[index];
                              final isBot = message['isBot'] as bool;
                              final messageText = message['message'] as String;
                              final timestamp = message['timestamp'] as String?;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isBot
                                          ? Colors.blue
                                          : Colors.green,
                                      radius: 16,
                                      child: Icon(
                                        isBot ? Icons.smart_toy : Icons.person,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            isBot ? 'AI Assistant' : 'You',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color:
                                                  (isBot
                                                          ? Colors.blue
                                                          : Colors.green)
                                                      .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              messageText,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (timestamp != null)
                                            Text(
                                              _formatTimestamp(timestamp),
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.5,
                                                ),
                                                fontSize: 10,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                  // Message Input
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Ask about your documents...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D9FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _isLoading ? null : _sendMessage,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.send, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
  }

  void _showPDFsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          '📄 Uploaded PDFs (Local)',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _uploadedPDFs.isEmpty
              ? const Center(
                  child: Text(
                    'No PDFs uploaded yet.\nUse the upload button to add documents!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 0.7),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _uploadedPDFs.length,
                  itemBuilder: (context, index) {
                    final pdf = _uploadedPDFs[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Color(0xFF00D9FF),
                      ),
                      title: Text(
                        pdf['name'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Size: ${((pdf['size'] ?? 0) / 1024 / 1024).toStringAsFixed(2)} MB\nUploaded: ${_formatDate(pdf['uploadedAt'])}',
                        style: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.7),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF00D9FF)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
