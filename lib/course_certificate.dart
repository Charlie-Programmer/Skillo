import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class CertificatePage extends StatefulWidget {
  final String studentName;
  final String courseTitle;
  final String category;

  const CertificatePage({
    super.key,
    required this.studentName,
    required this.courseTitle,
    required this.category,
  });

  @override
  State<CertificatePage> createState() => _CertificatePageState();
}

class _CertificatePageState extends State<CertificatePage>
    with SingleTickerProviderStateMixin {
  bool _isDownloading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _scaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _month(int month) {
    const months = [
      "January", "February", "March", "April",
      "May", "June", "July", "August",
      "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

  Future<void> _downloadPdf() async {
    setState(() => _isDownloading = true);

    try {
      if (Platform.isAndroid) {
        final storage = await Permission.storage.request();
        if (!storage.isGranted) {
          final photos = await Permission.photos.request();
          if (!photos.isGranted) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Storage permission denied")),
              );
            }
            setState(() => _isDownloading = false);
            return;
          }
        }
      }

      final now = DateTime.now();
      final date = "${now.day} ${_month(now.month)} ${now.year}";

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // BACKGROUND
                pw.Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: const PdfColor.fromInt(0xFFF0F6FF),
                ),

                // TOP BANNER
                pw.Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: pw.Container(
                    height: 12,
                    color: const PdfColor.fromInt(0xFF1869AC),
                  ),
                ),

                // BOTTOM BANNER
                pw.Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: pw.Container(
                    height: 12,
                    color: const PdfColor.fromInt(0xFF1869AC),
                  ),
                ),

                // LEFT ACCENT
                pw.Positioned(
                  top: 12,
                  bottom: 12,
                  left: 0,
                  child: pw.Container(
                    width: 8,
                    color: const PdfColor.fromInt(0xFFD6E4F0),
                  ),
                ),

                // RIGHT ACCENT
                pw.Positioned(
                  top: 12,
                  bottom: 12,
                  right: 0,
                  child: pw.Container(
                    width: 8,
                    color: const PdfColor.fromInt(0xFFD6E4F0),
                  ),
                ),

                // CONTENT
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 60, vertical: 40),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.SizedBox(height: 20),

                      // TITLE
                      pw.Text(
                        "CERTIFICATE",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 36,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF1869AC),
                          letterSpacing: 6,
                        ),
                      ),

                      pw.SizedBox(height: 4),

                      pw.Text(
                        "OF COMPLETION",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF1869AC),
                          letterSpacing: 4,
                        ),
                      ),

                      pw.SizedBox(height: 20),

                      // DECORATIVE LINE
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 60,
                            height: 2,
                            color: const PdfColor.fromInt(0xFF1869AC),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Container(
                            width: 8,
                            height: 8,
                            decoration: const pw.BoxDecoration(
                              color: PdfColor.fromInt(0xFF1869AC),
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Container(
                            width: 60,
                            height: 2,
                            color: const PdfColor.fromInt(0xFF1869AC),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 30),

                      pw.Text(
                        "This is to proudly certify that",
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.grey700,
                        ),
                      ),

                      pw.SizedBox(height: 16),

                      // STUDENT NAME BOX
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 30, vertical: 14),
                        decoration: pw.BoxDecoration(
                          color: const PdfColor.fromInt(0xFF1869AC),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Text(
                          widget.studentName,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 26,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),

                      pw.SizedBox(height: 24),

                      pw.Text(
                        "has successfully completed the course",
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 13,
                          color: PdfColors.grey700,
                        ),
                      ),

                      pw.SizedBox(height: 16),

                      // COURSE TITLE
                      pw.Container(
                        padding: const pw.EdgeInsets.all(16),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.white,
                          borderRadius: pw.BorderRadius.circular(8),
                          border: pw.Border.all(
                            color: const PdfColor.fromInt(0xFF1869AC),
                            width: 1.5,
                          ),
                        ),
                        child: pw.Text(
                          widget.courseTitle,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF1869AC),
                          ),
                        ),
                      ),

                      pw.SizedBox(height: 12),

                      // CATEGORY
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: pw.BoxDecoration(
                          color: const PdfColor.fromInt(0xFFD6E4F0),
                          borderRadius: pw.BorderRadius.circular(20),
                        ),
                        child: pw.Text(
                          widget.category,
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: const PdfColor.fromInt(0xFF1869AC),
                          ),
                        ),
                      ),

                      pw.SizedBox(height: 40),

                      // DECORATIVE LINE
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 60,
                            height: 2,
                            color: const PdfColor.fromInt(0xFF1869AC),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Container(
                            width: 8,
                            height: 8,
                            decoration: const pw.BoxDecoration(
                              color: PdfColor.fromInt(0xFF1869AC),
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Container(
                            width: 60,
                            height: 2,
                            color: const PdfColor.fromInt(0xFF1869AC),
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 20),

                      pw.Text(
                        "Issued on $date",
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // SAVE FILE
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final fileName =
          "certificate_${widget.courseTitle.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final filePath = "${directory!.path}/$fileName";
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Certificate saved to Downloads!"),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: "Open",
              textColor: Colors.white,
              onPressed: () => OpenFile.open(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }

    setState(() => _isDownloading = false);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = "${now.day} ${_month(now.month)} ${now.year}";

    return Scaffold(
      backgroundColor: const Color(0xFF0D3B6E),
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      "Certificate",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // CERTIFICATE PREVIEW
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F6FF),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // TOP BLUE BANNER
                          Container(
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 24, 105, 172),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 24),
                            child: Column(
                              children: [
                                // ICON + TITLE
                                const Icon(
                                  Icons.workspace_premium,
                                  size: 60,
                                  color: Color.fromARGB(255, 24, 105, 172),
                                ),

                                const SizedBox(height: 8),

                                const Text(
                                  "CERTIFICATE",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 24, 105, 172),
                                    letterSpacing: 5,
                                  ),
                                ),

                                const Text(
                                  "OF COMPLETION",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromARGB(255, 24, 105, 172),
                                    letterSpacing: 3,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // DECORATIVE DIVIDER
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 40,
                                        height: 2,
                                        color: const Color.fromARGB(
                                            255, 24, 105, 172)),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 24, 105, 172),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                        width: 40,
                                        height: 2,
                                        color: const Color.fromARGB(
                                            255, 24, 105, 172)),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                const Text(
                                  "This is to proudly certify that",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // STUDENT NAME
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(255, 24, 105, 172),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    widget.studentName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                const Text(
                                  "has successfully completed the course",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // COURSE TITLE BOX
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 24, 105, 172),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    widget.courseTitle,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 24, 105, 172),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // CATEGORY CHIP
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD6E4F0),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.category,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromARGB(255, 24, 105, 172),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // DECORATIVE DIVIDER
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 40,
                                        height: 2,
                                        color: const Color.fromARGB(
                                            255, 24, 105, 172)),
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color:
                                            Color.fromARGB(255, 24, 105, 172),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                        width: 40,
                                        height: 2,
                                        color: const Color.fromARGB(
                                            255, 24, 105, 172)),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  "Issued on $date",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // BOTTOM BLUE BANNER
                          Container(
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 24, 105, 172),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // DOWNLOAD BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isDownloading ? null : _downloadPdf,
                  icon: _isDownloading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.picture_as_pdf, color: Colors.white),
                  label: Text(
                    _isDownloading ? "Saving..." : "Download as PDF",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.15),
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}