import 'package:flutter/material.dart';
import '../models/procedure.dart';
import 'procedure_detail_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String query;
  final Future<Procedure?> Function(String) onComplete;

  const LoadingScreen({
    super.key,
    required this.query,
    required this.onComplete,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String _statusMessage = 'Processing your request...';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _processQuery();
  }

  Future<void> _processQuery() async {
    try {
      // Update status messages
      setState(() {
        _statusMessage = 'Analyzing your question...';
      });

      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _statusMessage = 'Searching for procedures...';
      });

      // Call the onComplete callback to get the procedure
      final procedure = await widget.onComplete(widget.query);

      if (!mounted) return;

      if (procedure != null) {
        // Navigate to procedure detail screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProcedureDetailScreen(procedure: procedure),
          ),
        );
      } else {
        // No procedure found - show error and go back
        _showNoProcedureFoundDialog();
      }
    } catch (e) {
      if (!mounted) return;

      // Show error and go back
      _showErrorDialog(e.toString());
    }
  }

  void _showNoProcedureFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Procedure Found'),
        content: const Text(
          'We couldn\'t find a procedure matching your request. Please try again with different words.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('An error occurred: $error'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Loading Indicator
              RotationTransition(
                turns: _animationController,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 4,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.blue.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Status Message
              Text(
                _statusMessage,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              // Query Text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  '"${widget.query}"',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
