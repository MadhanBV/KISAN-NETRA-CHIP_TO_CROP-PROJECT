import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../crop_disease/services/crop_disease_service.dart';

/// In-app developer & server diagnostics screen.
/// Displays real-time operational status of all backend AI services,
/// port mappings, and exact terminal commands to launch the entire stack.
class SystemStatusScreen extends StatefulWidget {
  const SystemStatusScreen({super.key});

  @override
  State<SystemStatusScreen> createState() => _SystemStatusScreenState();
}

class _SystemStatusScreenState extends State<SystemStatusScreen> {
  final CropDiseaseService _cropService = CropDiseaseService();

  bool _isLoading = true;
  bool _backendOnline = false;
  bool _ragEngineOnline = false;
  bool _yoloModelOnline = false;
  bool _qualityModelOnline = false;
  bool _diseaseModelOnline = false;
  String _backendError = '';

  @override
  void initState() {
    super.initState();
    _checkSystemHealth();
  }

  Future<void> _checkSystemHealth() async {
    setState(() {
      _isLoading = true;
      _backendError = '';
    });

    try {
      final modelStatus = await _cropService.checkModelsStatus();
      final qualityStatus = await _cropService.checkQualityStatus();
      final diseaseStatus = await _cropService.checkDiseaseDetectionStatus();

      if (mounted) {
        setState(() {
          _backendOnline = true;
          _yoloModelOnline = modelStatus['yolo_model_available'] == true;
          _ragEngineOnline = modelStatus['rag_engine_available'] == true;
          _qualityModelOnline = qualityStatus['quality_model_available'] == true;
          _diseaseModelOnline = diseaseStatus['disease_model_available'] == true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _backendOnline = false;
          _yoloModelOnline = false;
          _ragEngineOnline = false;
          _qualityModelOnline = false;
          _diseaseModelOnline = false;
          _backendError = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0F4D33),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F6),
      appBar: AppBar(
        title: const Text(
          'System Status & Server Commands',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        backgroundColor: const Color(0xFF0F4D33),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh Status',
            onPressed: _checkSystemHealth,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Live Health Check Card
            _buildLiveStatusCard(),

            const SizedBox(height: 20),

            // 2. All-in-One Launcher Card
            _buildOneClickLauncherCard(),

            const SizedBox(height: 20),

            // 3. Step-by-Step Terminal Commands
            const Text(
              'Individual Terminal Commands',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Run each service in its own terminal or command prompt tab:',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 14),

            _buildCommandCard(
              stepNumber: '1',
              title: 'Ollama AI (LLM & Embeddings)',
              port: '11434',
              command: 'ollama serve',
              description: 'Hosts local Qwen3:1.7b and nomic-embed-text models.',
            ),

            const SizedBox(height: 14),

            _buildCommandCard(
              stepNumber: '2',
              title: 'Agricultural RAG Engine',
              port: '8001',
              command:
                  'cd rag_engine\n.\\venv\\Scripts\\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8001',
              description: 'ChromaDB vector store & agricultural document grounding.',
            ),

            const SizedBox(height: 14),

            _buildCommandCard(
              stepNumber: '3',
              title: 'Main FastAPI Application Backend',
              port: '8000',
              command:
                  'cd backend\n.\\venv\\Scripts\\python.exe -m uvicorn app.main:app --host 0.0.0.0 --port 8000',
              description: 'YOLO26s inference, Supabase, Sarvam AI, and Mandi APIs.',
            ),

            const SizedBox(height: 14),

            _buildCommandCard(
              stepNumber: '4',
              title: 'ADB Reverse Port Forwarding (For Phone)',
              port: 'USB',
              command:
                  'adb reverse tcp:8000 tcp:8000\nadb reverse tcp:8001 tcp:8001',
              description: 'Allows your connected physical Android phone to access port 8000 & 8001.',
            ),

            const SizedBox(height: 14),

            _buildCommandCard(
              stepNumber: '5',
              title: 'Flutter Mobile App',
              port: 'Device',
              command:
                  'flutter run',
              description: 'Builds and installs the mobile app onto your device.',
            ),

            const SizedBox(height: 24),

            // 4. Port Reference Card
            _buildPortReferenceCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatusCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Service Health',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0F4D33),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _backendOnline
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _backendOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _backendOnline
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          _serviceRow('FastAPI Backend (Port 8000)', _backendOnline),
          _serviceRow('RAG ChromaDB Engine (Port 8001)', _ragEngineOnline),
          _serviceRow('Leaf Disease Model (YOLO26s)', _yoloModelOnline),
          _serviceRow('Quality Model (Fresh vs Rotten)', _qualityModelOnline),
          _serviceRow('Crop Disease Model (Model 3)', _diseaseModelOnline),

          if (_backendError.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Notice: $_backendError',
              style: const TextStyle(fontSize: 11.5, color: Colors.orange),
            ),
          ],
        ],
      ),
    );
  }

  Widget _serviceRow(String name, bool isOnline) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18,
            color: isOnline ? const Color(0xFF2E7D32) : Colors.red.shade400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            isOnline ? 'Active' : 'Not Connected',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isOnline ? const Color(0xFF2E7D32) : Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOneClickLauncherCard() {
    const batCommand = '.\\run_all_services.bat';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4D33), Color(0xFF1B6A47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F4D33).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.flash_on_rounded, color: Color(0xFFFFD54F), size: 22),
              SizedBox(width: 8),
              Text(
                'One-Click Startup Script',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Double-click this batch file or run it in your terminal to start Ollama, RAG Engine, Backend, and ADB forwarding all at once:',
            style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    batCommand,
                    style: TextStyle(
                      color: Color(0xFF81C784),
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                  tooltip: 'Copy',
                  onPressed: () => _copyToClipboard(batCommand, 'Script command'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandCard({
    required String stepNumber,
    required String title,
    required String port,
    required String command,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F4D33),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  stepNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'Port $port',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2822),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    command,
                    style: const TextStyle(
                      color: Color(0xFF81C784),
                      fontFamily: 'monospace',
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: Colors.white70, size: 18),
                  tooltip: 'Copy Command',
                  onPressed: () => _copyToClipboard(command, title),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortReferenceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Endpoints & Port Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B5E20),
            ),
          ),
          SizedBox(height: 8),
          Text('• Main Backend: http://127.0.0.1:8000', style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
          Text('• Swagger Docs: http://127.0.0.1:8000/docs', style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
          Text('• RAG Service: http://127.0.0.1:8001', style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
          Text('• Ollama Engine: http://127.0.0.1:11434', style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32))),
        ],
      ),
    );
  }
}

