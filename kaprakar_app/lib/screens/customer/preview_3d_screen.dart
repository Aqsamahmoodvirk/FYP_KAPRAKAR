import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../services/tripo_service.dart';

class Preview3DScreen extends StatefulWidget {
  final String? imageUrl;
  final String? modelUrl;

  const Preview3DScreen({Key? key, this.imageUrl, this.modelUrl}) : super(key: key);

  @override
  State<Preview3DScreen> createState() => _Preview3DScreenState();
}

class _Preview3DScreenState extends State<Preview3DScreen> {
  final TripoService _tripoService = TripoService();
  String _status = 'initiating';
  int _progress = 0;
  String? _modelUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.modelUrl != null) {
      _modelUrl = widget.modelUrl;
      _status = 'success';
    } else if (widget.imageUrl != null) {
      _startGeneration();
    } else {
      _status = 'error';
      _errorMessage = 'No image or model provided.';
    }
  }

  Future<void> _startGeneration() async {
    setState(() {
      _status = 'starting';
    });
    
    final taskId = await _tripoService.generate3DModel(widget.imageUrl!);
    
    if (taskId == null) {
      if (mounted) {
        setState(() {
          _status = 'failed';
          _errorMessage = 'Failed to start generation. Please try again.';
        });
      }
      return;
    }

    _tripoService.pollTaskStatus(taskId).listen((data) {
      if (mounted) {
        setState(() {
          _status = data['status'] ?? 'unknown';
          if (data['progress'] != null) {
            _progress = data['progress'];
          }
          if (_status == 'success' && data['modelUrl'] != null) {
            _modelUrl = data['modelUrl'];
          } else if (_status == 'error' || _status == 'failed') {
            _errorMessage = data['message'] ?? 'Generation failed.';
          }
        });
      }
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
          const SizedBox(height: 24),
          const Text(
            "Weaving your 3D model...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Status: ${_status.toUpperCase()}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          if (_progress > 0 && _status == 'running')
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                "$_progress%",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An unexpected error occurred.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startGeneration,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return ModelViewer(
      src: _modelUrl!,
      alt: "A 3D model of the user's uploaded dress",
      ar: true,
      autoRotate: true,
      cameraControls: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Preview'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (_status == 'success' && _modelUrl != null) {
              return _buildSuccessState();
            } else if (_status == 'failed' || _status == 'error') {
              return _buildErrorState();
            } else {
              return _buildLoadingState();
            }
          },
        ),
      ),
    );
  }
}
