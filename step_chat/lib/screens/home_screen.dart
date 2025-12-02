import 'package:flutter/material.dart';
import '../services/speech_service.dart';
import '../services/pinecone_rag_service.dart';
import '../services/firestore_service.dart';
import '../models/procedure.dart';
import 'loading_screen.dart';
import 'procedure_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechService _speechService = SpeechService();
  final PineconeRAGService _ragService = PineconeRAGService();
  final FirestoreService _firestoreService = FirestoreService();

  bool _isListening = false;
  String _transcribedText = '';
  String _partialText = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    try {
      await _speechService.initialize();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize speech recognition: $e';
      });
    }
  }

  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
      _transcribedText = '';
      _partialText = '';
      _errorMessage = null;
    });

    try {
      await _speechService.startListening(
        onResult: (result) async {
          setState(() {
            _transcribedText = result;
            _isListening = false;
          });

          // Process the transcribed text
          await _processSpeechInput(result);
        },
        onPartialResult: (partial) {
          setState(() {
            _partialText = partial;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isListening = false;
        _errorMessage = 'Speech recognition failed: $e';
      });
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _processSpeechInput(String input) async {
    // Navigate to loading screen
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(
          query: input,
          onComplete: _handleQueryComplete,
        ),
      ),
    );
  }

  Future<Procedure?> _handleQueryComplete(String query) async {
    try {
      // Step 1: Interpret the query using AI
      final aiResponse = await _ragService.interpretQuery(query);

      Procedure? procedure;

      // Step 2: Try to get procedure by document ID if provided
      if (aiResponse.documentId != null) {
        procedure = await _firestoreService.getProcedureById(aiResponse.documentId!);
      }

      // Step 3: If no direct document ID or not found, search by keywords
      if (procedure == null && aiResponse.searchTerms.isNotEmpty) {
        final searchTerms = aiResponse.searchTerms.split(' ');
        final procedures = await _firestoreService.searchProceduresByKeywords(searchTerms);

        if (procedures.isNotEmpty) {
          procedure = procedures.first;
        }
      }

      // Step 4: If still no results, try Pinecone semantic search
      if (procedure == null) {
        final documentIds = await _ragService.querySimilarProcedures(query);
        if (documentIds.isNotEmpty) {
          procedure = await _firestoreService.getProcedureById(documentIds.first);
        }
      }

      return procedure;
    } catch (e) {
      print('Error processing query: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // App Title
              const Text(
                'Step Chat',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'Ask about any procedure',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 48),

              // Microphone Button
              GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening ? Colors.red : Colors.blue,
                    boxShadow: [
                      BoxShadow(
                        color: (_isListening ? Colors.red : Colors.blue)
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Status Text
              Text(
                _isListening
                    ? 'Listening...'
                    : _transcribedText.isNotEmpty
                        ? 'Processing...'
                        : 'Tap to speak',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 16),

              // Transcribed/Partial Text
              if (_partialText.isNotEmpty || _transcribedText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _isListening ? _partialText : _transcribedText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Error Message
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 48),

              // Example Questions
              const Text(
                'Example questions:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 12),

              _buildExampleQuestion('How do I lubricate the main gear?'),
              _buildExampleQuestion('What is the hydraulic system check procedure?'),
              _buildExampleQuestion('How do I inspect the landing gear?'),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleQuestion(String question) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '• $question',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black38,
        ),
      ),
    );
  }
}
