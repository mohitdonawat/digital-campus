import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../../core/constants/app_colors.dart';

class PdfViewerScreen extends StatefulWidget {
  final String title;
  final String? url;
  final String? base64Data;
  final String? fileName;

  const PdfViewerScreen({
    super.key,
    required this.title,
    this.url,
    this.base64Data,
    this.fileName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      if (widget.base64Data != null && widget.base64Data!.isNotEmpty) {
        String cleanB64 = widget.base64Data!;
        if (cleanB64.contains(',')) {
          cleanB64 = cleanB64.split(',').last;
        }
        _pdfBytes = base64Decode(cleanB64);
        setState(() => _isLoading = false);
        return;
      }

      if (widget.url != null && widget.url!.isNotEmpty) {
        final uri = Uri.tryParse(widget.url!);
        if (uri != null && (uri.isScheme('http') || uri.isScheme('https'))) {
          final res = await http.get(uri);
          if (res.statusCode == 200) {
            _pdfBytes = res.bodyBytes;
            setState(() => _isLoading = false);
            return;
          } else {
            setState(() {
              _errorMessage = 'Failed to download PDF (HTTP ${res.statusCode})';
              _isLoading = false;
            });
            return;
          }
        }
      }

      setState(() {
        _errorMessage = 'No valid PDF data or URL provided.';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading PDF: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadAndSave() async {
    if (_pdfBytes == null) return;
    setState(() => _isDownloading = true);

    try {
      final name = widget.fileName ?? '${widget.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}.pdf';
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final file = File('${dir!.path}/$name');
      await file.writeAsBytes(_pdfBytes!);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to ${file.path}'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'OPEN',
            textColor: Colors.white,
            onPressed: () => OpenFile.open(file.path),
          ),
        ),
      );

      // Attempt to open automatically
      await OpenFile.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_pdfBytes != null) ...[
            IconButton(
              icon: _isDownloading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                    )
                  : const Icon(Icons.download_rounded, color: AppColors.secondary),
              tooltip: 'Download to Device',
              onPressed: _isDownloading ? null : _downloadAndSave,
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: AppColors.secondary),
            SizedBox(height: 16),
            Text('Loading PDF Document...', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 56),
              const SizedBox(height: 16),
              const Text('Unable to Display PDF',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textHint, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadPdf();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return PdfPreview(
      build: (format) => _pdfBytes!,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      allowPrinting: true,
      allowSharing: true,
      maxPageWidth: 700,
      loadingWidget: const Center(
        child: CircularProgressIndicator(color: AppColors.secondary),
      ),
      pdfFileName: widget.fileName ?? '${widget.title}.pdf',
    );
  }
}
