import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class PreviewDialog extends StatefulWidget {
  final pw.Document document;
  const PreviewDialog({required this.document, super.key});

  @override
  PreviewDialogState createState() => PreviewDialogState();
}

class PreviewDialogState extends State<PreviewDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Print Preview'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: InteractiveViewer(
          panEnabled: false, // Set to false to prevent panning.
          boundaryMargin: const EdgeInsets.all(0),
          minScale: 0.1,
          maxScale: 2.0,
          child: PdfPreview(
            build: (format) => widget.document.save(),
            allowSharing: false,
            allowPrinting: false,
            pdfFileName: 'nametag.pdf',
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Print'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
