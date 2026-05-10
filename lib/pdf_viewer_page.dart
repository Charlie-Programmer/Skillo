import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatefulWidget {
  final String filePath;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.filePath,
    required this.title,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final PdfViewerController _controller = PdfViewerController();

  int _totalPages = 0;
  int _currentPage = 1;
  bool _isCompleted = false;

  void _exitPage() {
    Navigator.pop(context, _isCompleted); // 👈 return result
  }

  @override
  Widget build(BuildContext context) {
    return PopScope( // 👈 handles system back button
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _exitPage();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: const Color.fromARGB(255, 24, 105, 172),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _exitPage, // 👈 important
          ),
        ),

        body: Stack(
          children: [
            SfPdfViewer.file(
              File(widget.filePath),
              controller: _controller,

              canShowPaginationDialog: false,
              pageLayoutMode: PdfPageLayoutMode.single,

              onDocumentLoaded: (details) {
                setState(() {
                  _totalPages = details.document.pages.count;
                });
              },

              onPageChanged: (details) {
                setState(() {
                  _currentPage = details.newPageNumber;

                  if (_totalPages > 0 &&
                      details.newPageNumber == _totalPages) {
                    _isCompleted = true;
                  }
                });
              },
            ),

            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$_currentPage / $_totalPages",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}