import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_pro/core/utils/app_logger.dart';
import 'package:expense_pro/l10n/app_localizations.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/data/transaction_model.dart';
import '../../receipts/services/receipt_service.dart';
import '../../transactions/presentation/add_transaction_page.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/providers/country_config_provider.dart';

class CameraPage extends ConsumerStatefulWidget {
  const CameraPage({super.key});

  @override
  ConsumerState<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends ConsumerState<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  final TransactionRepository _repository = TransactionRepository();
  
  XFile? _pickedFile;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source, imageQuality: 50);
      if (photo != null) {
        setState(() {
          _pickedFile = photo;
        });
      }
    } catch (e) {
      appLogger.e("카메라 에러: $e", error: e);
    }
  }

  Future<void> _processReceipt() async {
    if (_pickedFile == null) return;
    
    setState(() { _isUploading = true; });

    try {
      
      final List<dynamic> results;
      try {
        results = await Future.wait(
          [
            _repository.uploadReceiptImage(_pickedFile!),
            ReceiptService.analyzeReceipt(
              _pickedFile!,
              config: ref.read(countryConfigProvider),
            ),
          ],
          eagerError: false,
        );
      } catch (uploadOrOcrError) {
        throw Exception("Image upload or AI analysis failed: $uploadOrOcrError");
      }

      final String? uploadedUrl = results[0] as String?;
      final TransactionModel? analyzedData = results[1] as TransactionModel?;

      setState(() { _isUploading = false; });

      if (analyzedData != null && uploadedUrl != null) {
        final finalData = TransactionModel(
          id: analyzedData.id,
          userId: analyzedData.userId,
          date: analyzedData.date,
          amount: analyzedData.amount,
          storeName: analyzedData.storeName,
          category: analyzedData.category,
          memo: analyzedData.memo,
          method: analyzedData.method,
          receiptUrl: uploadedUrl,
          
          cashReceiptType: analyzedData.cashReceiptType, 
          accountId: 'OCR_Receipt',
          transactionType: analyzedData.transactionType, 
          isPaid: analyzedData.isPaid,                  
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AddTransactionPage(
                initialData: finalData,
                isExistingRecord: false,
                initialTransactionType: finalData.transactionType,
              ),
            ),
          );
        }
      } else {
        throw Exception("Analysis or upload failed");
      }

    } catch (e) {
      appLogger.e("에러 발생: $e", error: e);
      setState(() { _isUploading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.cameraAnalyzeFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.cameraTitle)),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: _pickedFile == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                            const SizedBox(height: 10),
                            Text(l10n.cameraPrompt),
                          ],
                        )
                      : _buildImage(),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(Icons.camera, l10n.cameraCapture, () => _pickImage(ImageSource.camera)),
                    _buildButton(Icons.photo, l10n.cameraAlbum, () => _pickImage(ImageSource.gallery)),
                  ],
                ),
              ),
              if (_pickedFile != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: PrimaryButton(
                    label: _isUploading ? l10n.cameraAnalyzing : l10n.cameraAnalyze,
                    isLoading: _isUploading,
                    onPressed: _processReceipt,
                  ),
                ),
            ],
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (kIsWeb) {
      
      return Image.network(_pickedFile!.path, fit: BoxFit.contain);
    } else {
      return Image.file(File(_pickedFile!.path), fit: BoxFit.contain);
    }
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blueGrey[50],
            child: Icon(icon, color: Colors.blueGrey[800], size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
