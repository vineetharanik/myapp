import 'dart:convert';
import 'package:http/http.dart' as http;

class AcademicAIService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  // Replace with your actual Gemini API key
  // Get your key from: https://makersuite.google.com/app/apikey
  static const String _apiKey =
      'AIzaSyB5p6WJ7Q8R9X2T3Y4V5U6W7X8Y9Z0A1B2C3'; // Replace with your real API key

  // Academic-specific prompts for different subjects
  static const Map<String, String> _academicPrompts = {
    'mathematics': '''
    You are an expert mathematics tutor. Provide clear, step-by-step solutions to math problems.
    Explain concepts in simple terms and show all work. Focus on understanding, not just answers.
    ''',

    'science': '''
    You are an expert science educator. Explain scientific concepts with real-world examples.
    Use analogies and visual descriptions to help students understand complex topics.
    ''',

    'programming': '''
    You are an expert programming instructor. Help with code debugging, algorithm design,
    and best practices. Provide clean, well-commented code examples.
    ''',

    'general': '''
    You are an academic study assistant. Help students understand concepts, solve problems,
    and develop effective study strategies. Provide clear explanations and practical examples.
    ''',
  };

  // Analyze PDF content for academic purposes
  static Future<String> analyzePDFContent(
    String pdfText, {
    String subject = 'general',
  }) async {
    try {
      final prompt = _academicPrompts[subject] ?? _academicPrompts['general']!;

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''
$prompt

Please analyze the following academic content and provide:
1. Key concepts and main ideas
2. Important definitions and terms
3. Study questions for self-assessment
4. Connections to real-world applications
5. Suggested further reading or practice

Content to analyze:
$pdfText
              ''',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'Analysis failed';
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error analyzing PDF: $e';
    }
  }

  // Answer academic questions
  static Future<String> answerAcademicQuestion(
    String question, {
    String subject = 'general',
  }) async {
    try {
      final prompt = _academicPrompts[subject] ?? _academicPrompts['general']!;

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''
$prompt

Please provide a comprehensive answer to this academic question:
$question

Include:
1. Clear explanation of the concept
2. Step-by-step reasoning
3. Examples or illustrations
4. Common misconceptions to avoid
5. Practice problems or exercises
              ''',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'Answer failed';
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error answering question: $e';
    }
  }

  // Generate study plan
  static Future<String> generateStudyPlan(
    String topic,
    int days, {
    String subject = 'general',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''
Create a comprehensive $days-day study plan for: $topic

Include:
1. Daily learning objectives
2. Specific topics to cover each day
3. Recommended study methods
4. Practice exercises
5. Review sessions
6. Progress tracking methods

Make it realistic, structured, and effective for academic success.
              ''',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.8,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'Plan failed';
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error generating study plan: $e';
    }
  }

  // Explain academic concept
  static Future<String> explainConcept(
    String concept, {
    String subject = 'general',
  }) async {
    try {
      final prompt = _academicPrompts[subject] ?? _academicPrompts['general']!;

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''
$prompt

Please explain this academic concept in detail: $concept

Provide:
1. Simple definition
2. Detailed explanation with examples
3. Visual analogies or metaphors
4. Common applications
5. Related concepts to know
6. Practice questions
              ''',
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.6,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'] ??
            'Explanation failed';
      } else {
        return 'Error: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error explaining concept: $e';
    }
  }

  // Get list of available subjects
  static List<String> getAvailableSubjects() {
    return _academicPrompts.keys.toList();
  }
}
