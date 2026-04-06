import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/academic_ai_service.dart';
import '../../services/local_storage_service.dart';

class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> _uploadedPDFs = [];
  List<Map<String, dynamic>> _chatHistory = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String _selectedSubject = 'general';
  final List<String> _subjects = AcademicAIService.getAvailableSubjects();

  @override
  void initState() {
    super.initState();
    _initializeNotebook();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotebook() async {
    await LocalStorageService().initialize();
    await _loadUserPDFs();
    await _loadChatHistory();
  }

  Future<void> _loadUserPDFs() async {
    try {
      final pdfs = await LocalStorageService().getUploadedPDFs();
      if (!mounted) return;
      setState(() {
        _uploadedPDFs = pdfs;
      });
    } catch (e) {
      debugPrint('Error loading PDFs: $e');
    }
  }

  Future<void> _loadChatHistory() async {
    try {
      final chats = await LocalStorageService().getNotebookChatHistory();
      if (!mounted) return;
      setState(() {
        _chatHistory = chats.reversed.toList();
      });
    } catch (e) {
      debugPrint('Error loading notebook chat: $e');
    }
  }

  Future<void> _uploadPDF() async {
    FilePickerResult? result;

    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );
    } catch (e) {
      _addBotMessage('File picker failed: $e');
      return;
    }

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null || bytes.isEmpty) {
      _addBotMessage(
        'Could not read the PDF data. Please try again and allow file access.',
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final pdfData = {
        'name': file.name,
        'size': '${(bytes.length / 1024).toStringAsFixed(1)} KB',
        'uploadDate': DateTime.now().toIso8601String(),
      };

      await LocalStorageService().saveUploadedPDF(pdfData);

      if (!mounted) return;
      setState(() {
        _uploadedPDFs = [pdfData, ..._uploadedPDFs];
      });

      _addBotMessage(
        'PDF uploaded successfully: ${file.name}. Ask for a summary, important points, or an explanation of the topic.',
      );
    } catch (e) {
      _addBotMessage('Error uploading PDF: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _isLoading) return;

    _messageController.clear();
    await _submitUserPrompt(
      userText: message,
      aiPrompt: _buildNotebookPrompt(message),
    );
  }

  Future<void> _askAcademicQuestion(String question) async {
    await _submitUserPrompt(
      userText: 'Academic question: $question',
      aiPrompt: _buildNotebookPrompt(question),
    );
  }

  Future<void> _generateStudyPlan(String topic, int days) async {
    final userText = 'Create a $days-day study plan for $topic';
    await _submitUserPrompt(
      userText: userText,
      aiPrompt:
          'Create a structured $days-day study plan for $topic. Include daily goals, revision checkpoints, practice work, and time management tips.',
    );
  }

  Future<void> _explainConcept(String concept) async {
    await _submitUserPrompt(
      userText: 'Explain concept: $concept',
      aiPrompt:
          'Explain $concept clearly for a student. Include simple definition, intuition, examples, common mistakes, and 3 quick revision questions.',
    );
  }

  Future<void> _submitUserPrompt({
    required String userText,
    required String aiPrompt,
  }) async {
    final timestamp = DateTime.now().toIso8601String();

    setState(() {
      _isLoading = true;
      _chatHistory.insert(0, {
        'message': userText,
        'isBot': false,
        'timestamp': timestamp,
      });
    });

    await LocalStorageService().saveNotebookChatMessage(userText, false);

    try {
      final answer = await AcademicAIService.answerAcademicQuestion(
        aiPrompt,
        subject: _selectedSubject,
      );

      _addBotMessage(_resolveAnswer(userText, answer));
    } catch (e) {
      _addBotMessage(_fallbackAnswer(userText, e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _buildNotebookPrompt(String userMessage) {
    final pdfNames = _uploadedPDFs
        .map((pdf) => (pdf['name'] ?? 'Untitled PDF').toString())
        .take(5)
        .join(', ');

    final pdfContext = pdfNames.isEmpty
        ? 'No PDFs are uploaded yet.'
        : 'Uploaded PDFs: $pdfNames.';

    return '''
You are the notebook AI in DevBalance.

$pdfContext

Respond to the user with clear academic help. If the user asks for summary, notes, key points, or revision help, behave like a document study assistant. If actual PDF text is unavailable, be honest and still help using the topic or question asked by the user.

User message:
$userMessage
''';
  }

  String _resolveAnswer(String userMessage, String answer) {
    final trimmed = answer.trim();
    if (trimmed.isEmpty ||
        trimmed.startsWith('Error:') ||
        trimmed.startsWith('Error answering question:')) {
      return _fallbackAnswer(userMessage, trimmed);
    }

    return trimmed;
  }

  String _fallbackAnswer(String userMessage, String error) {
    final hasPDFs = _uploadedPDFs.isNotEmpty;

    return 'The notebook AI could not answer right now'
        '${error.isNotEmpty ? ' ($error)' : ''}.\n\n'
        'Your request: "$userMessage"\n\n'
        '${hasPDFs ? 'I can still help around the uploaded PDFs and the topic you asked.' : 'Upload a PDF if you want document-based help.'}\n'
        'Try asking for:\n'
        '1. Short notes\n'
        '2. Important questions\n'
        '3. Key concepts\n'
        '4. Simple explanation\n'
        '5. A day-wise study plan';
  }

  void _addBotMessage(String message) {
    final chatMessage = {
      'message': message,
      'isBot': true,
      'timestamp': DateTime.now().toIso8601String(),
    };

    setState(() {
      _chatHistory.insert(0, chatMessage);
    });

    LocalStorageService().saveNotebookChatMessage(message, true);
  }

  void _showPDFsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Uploaded PDFs',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _uploadedPDFs.isEmpty
              ? const Center(
                  child: Text(
                    'No PDFs uploaded yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: _uploadedPDFs.length,
                  itemBuilder: (context, index) {
                    final pdf = _uploadedPDFs[index];
                    final uploadDate =
                        (pdf['uploadDate'] ?? pdf['uploadedAt'] ?? '').toString();

                    return ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Color(0xFF00D9FF),
                      ),
                      title: Text(
                        (pdf['name'] ?? 'Untitled PDF').toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        uploadDate.isEmpty
                            ? 'Saved locally'
                            : 'Uploaded: ${_formatDate(uploadDate)}',
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.download,
                          color: Color(0xFF00D9FF),
                        ),
                        onPressed: () => _downloadPDF(
                          (pdf['downloadUrl'] ?? '').toString(),
                          (pdf['name'] ?? 'PDF').toString(),
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

  void _downloadPDF(String url, String fileName) {
    final message = url.isEmpty
        ? '$fileName is stored locally in this prototype.'
        : 'Download for $fileName is available.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF00D9FF),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return timestamp;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return dateString;
    }
  }

  void _showStudyPlanDialog() {
    final topicController = TextEditingController();
    final daysController = TextEditingController(text: '7');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Study Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: topicController,
              decoration: const InputDecoration(
                labelText: 'Topic/Subject',
                hintText: 'e.g. Calculus, Chemistry, Programming',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Days',
                hintText: 'e.g. 7, 14, 30',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final topic = topicController.text.trim();
              final days = int.tryParse(daysController.text.trim()) ?? 7;
              if (topic.isNotEmpty) {
                _generateStudyPlan(topic, days);
              }
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _showConceptDialog() {
    final conceptController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Explain Concept'),
        content: TextField(
          controller: conceptController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Concept to Explain',
            hintText: 'e.g. Photosynthesis, Integration, Machine Learning',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final concept = conceptController.text.trim();
              if (concept.isNotEmpty) {
                _explainConcept(concept);
              }
            },
            child: const Text('Explain'),
          ),
        ],
      ),
    );
  }

  void _showQuestionDialog() {
    final questionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask Academic Question'),
        content: TextField(
          controller: questionController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Your Question',
            hintText: 'e.g. Why is the sky blue? How do vaccines work?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final question = questionController.text.trim();
              if (question.isNotEmpty) {
                _askAcademicQuestion(question);
              }
            },
            child: const Text('Ask'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.school, color: Color(0xFF00D9FF)),
            SizedBox(width: 12),
            Text(
              'Academic Study Helper',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFB829F7).withOpacity(0.10),
                  const Color(0xFFB829F7).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFB829F7).withOpacity(0.30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Academic AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  dropdownColor: const Color(0xFF1A1A2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Select Subject',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFB829F7)),
                    ),
                  ),
                  items: _subjects
                      .map(
                        (subject) => DropdownMenuItem<String>(
                          value: subject,
                          child: Text(subject.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedSubject = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showStudyPlanDialog,
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('Study Plan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB829F7),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showConceptDialog,
                      icon: const Icon(Icons.lightbulb, size: 16),
                      label: const Text('Explain Concept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D9FF),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _showQuestionDialog,
                      icon: const Icon(Icons.help, size: 16),
                      label: const Text('Ask Question'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00D9FF).withOpacity(0.10),
                  const Color(0xFF00D9FF).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00D9FF).withOpacity(0.30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.upload_file, color: Color(0xFF00D9FF)),
                    const SizedBox(width: 12),
                    const Text(
                      'Upload PDF Documents',
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
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadPDF,
                        icon: _isUploading
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
                            : const Icon(Icons.cloud_upload),
                        label: Text(
                          _isUploading ? 'Uploading...' : 'Choose PDF',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D9FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showPDFsDialog(context),
                      icon: const Icon(Icons.list),
                      label: const Text('View PDFs'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.10),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: _chatHistory.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                'Start chatting with your documents.\nUpload PDFs and ask for summaries, explanations, or study help.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.50),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            reverse: true,
                            padding: const EdgeInsets.all(16),
                            itemCount: _chatHistory.length,
                            itemBuilder: (context, index) {
                              final message = _chatHistory[index];
                              final isBot = (message['isBot'] as bool?) ?? false;
                              final messageText =
                                  (message['message'] ?? '').toString();
                              final timestamp =
                                  (message['timestamp'] ?? '').toString();

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor:
                                          isBot ? Colors.blue : Colors.green,
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
                                              color: (isBot
                                                      ? Colors.blue
                                                      : Colors.green)
                                                  .withOpacity(0.10),
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
                                          if (timestamp.isNotEmpty)
                                            Text(
                                              _formatTimestamp(timestamp),
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(0.50),
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
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            maxLines: null,
                            style: const TextStyle(color: Colors.white),
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: 'Ask about your documents...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.50),
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
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
    );
  }
}
