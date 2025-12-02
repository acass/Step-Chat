import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/procedure.dart';
import '../models/procedure_step.dart';
import '../services/storage_service.dart';

class ProcedureDetailScreen extends StatefulWidget {
  final Procedure procedure;

  const ProcedureDetailScreen({
    super.key,
    required this.procedure,
  });

  @override
  State<ProcedureDetailScreen> createState() => _ProcedureDetailScreenState();
}

class _ProcedureDetailScreenState extends State<ProcedureDetailScreen> {
  final StorageService _storageService = StorageService();
  final Map<String, String> _imageUrlCache = {};
  bool _isLoadingImages = false;

  @override
  void initState() {
    super.initState();
    _loadImageUrls();
  }

  Future<void> _loadImageUrls() async {
    setState(() {
      _isLoadingImages = true;
    });

    try {
      for (final step in widget.procedure.steps) {
        if (step.imagePath != null && step.imagePath!.isNotEmpty) {
          final url = await _storageService.getImageUrl(step.imagePath!);
          _imageUrlCache[step.imagePath!] = url;
        }
      }
    } catch (e) {
      print('Error loading image URLs: $e');
    }

    if (mounted) {
      setState(() {
        _isLoadingImages = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Procedure'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.procedure.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.procedure.keywords
                        .map((keyword) => _buildKeywordChip(keyword))
                        .toList(),
                  ),
                ],
              ),
            ),

            // Steps Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Steps',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Steps List
                  ...widget.procedure.steps
                      .map((step) => _buildStepCard(step))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.home, color: Colors.white),
      ),
    );
  }

  Widget _buildKeywordChip(String keyword) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        keyword,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStepCard(ProcedureStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Number
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Step',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Step Text
          Text(
            step.text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),

          // Step Image
          if (step.imagePath != null && step.imagePath!.isNotEmpty)
            Column(
              children: [
                const SizedBox(height: 16),
                _buildStepImage(step.imagePath!),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStepImage(String imagePath) {
    if (_isLoadingImages && !_imageUrlCache.containsKey(imagePath)) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final imageUrl = _imageUrlCache[imagePath];

    if (imageUrl == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 48,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
