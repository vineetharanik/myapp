import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/journal_analysis.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000'; // Fallback for iOS/Desktop
    }
  }

  // Token shouldn't be strictly required for testing visually but passed as a placeholder
  static Future<JournalAnalysis> analyzeJournal(String text) async {
    final response = await http.post(
      Uri.parse('$baseUrl/journal/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      return JournalAnalysis.fromJson(decoded);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please ensure authentication is passed.');
    } else {
      final decoded = jsonDecode(response.body);
      final errMsg = decoded['detail'] ?? 'Failed to analyze journal';
      throw Exception(errMsg);
    }
  }

  static Future<List<JournalAnalysis>> getJournalHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/journal/history'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> decoded = jsonDecode(response.body);
      return decoded.map((item) => JournalAnalysis.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch journal history');
    }
  }

  static Future<JournalAnalysis?> getLatestAnalysis() async {
    final response = await http.get(
      Uri.parse('$baseUrl/journal/latest'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      if (response.body.isEmpty) return null;
      final decoded = jsonDecode(response.body);
      return JournalAnalysis.fromJson(decoded);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to fetch latest analysis');
    }
  }

  static Future<Map<String, dynamic>> assessStress(List<int> answers) async {
    final response = await http.post(
      Uri.parse('$baseUrl/stress/assess'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'answers': answers}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to assess stress');
    }
  }
}
