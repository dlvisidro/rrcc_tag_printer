import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/person.dart';

Future<pw.Document?> generatePdf(
  BuildContext context,
  List<Person> peopleToPrint,
) async {
  if (peopleToPrint.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No people selected to print.')),
    );
    return null;
  }

  final doc = pw.Document();
  const pageFormat = PdfPageFormat(
    70 * PdfPageFormat.mm,
    50 * PdfPageFormat.mm,
  );
  // const pageFormat = PdfPageFormat.a4;

  for (var person in peopleToPrint) {
    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(person.firstName),
                pw.Text(person.lastName),
                pw.Text(person.churchName),
              ],
            ),
          ); // Center
        },
      ),
    ); // Page
  }
  return doc;
}

void directPrintPdf(
  BuildContext context,
  Printer? printer,
  List<Person> peopleToPrint,
) async {
  if (printer == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No printer selected.')));
    return;
  }
  final doc = await generatePdf(context, peopleToPrint);
  if (doc == null) return;

  await Printing.directPrintPdf(
    printer: printer,
    onLayout: (PdfPageFormat format) async => doc.save(),
  );
}
