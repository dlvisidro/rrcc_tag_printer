import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'src/widgets/participant_list.dart';
import 'src/models/person.dart';
import 'src/utils/person_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RRCC Name Tag Printer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'RRCC Name Tag Printer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Printer? _selectedPrinter;
  List<Printer> _printers = [];
  final List<Person> _people = [
    Person('MacArthur', 'John', 'Grace Community Church'),
    Person('Smith', 'Jane', 'Redeemer Presbyterian'),
    Person('Johnson', 'Peter', 'City on a Hill'),
    Person('Williams', 'Mary', 'Grace Fellowship'),
    Person('Brown', 'David', 'Trinity Baptist'),
    Person('Jones', 'Susan', 'Grace Community Church'),
    Person('Garcia', 'Maria', 'Redeemer Presbyterian'),
    Person('Miller', 'Robert', 'City on a Hill'),
    Person('Davis', 'Linda', 'Grace Fellowship'),
    Person('Rodriguez', 'James', 'Trinity Baptist'),
  ];
  late final PersonController controller;

  @override
  void initState() {
    super.initState();
    _fetchPrinters();
    controller = PersonController(persons: _people);
  }

  void _fetchPrinters() async {
    try {
      final printers = await Printing.listPrinters();
      if (!mounted) return;
      setState(() {
        _printers = printers;
        if (printers.isNotEmpty) {
          _selectedPrinter = printers.firstWhere(
            (p) => p.isDefault,
            orElse: () => printers.first,
          );
        }
      });
    } catch (e) {
      // Handle exceptions, e.g., show a message to the user
      print('Error fetching printers: $e');
    }
  }

  void _directPrintPdf(Printer? printer, List<Person> peopleToPrint) async {
    if (printer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No printer selected.')));
      return;
    }
    final doc = await _generatePdf(peopleToPrint);
    if (doc == null) return;

    await Printing.directPrintPdf(
      printer: printer,
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Future<pw.Document?> _generatePdf(List<Person> peopleToPrint) async {
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

  void _showPrintPreview(pw.Document doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                build: (format) => doc.save(),
                allowSharing: false,
                allowPrinting: false,
                pdfFileName: 'nametag.pdf',
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showUnregisteredDialog() {
    final lastNameController = TextEditingController();
    final firstNameController = TextEditingController();
    // final churchNameController = TextEditingController();
    String churchName = _people[0].churchName;
    // final churches = _people.map((x) => x.churchName).toSet().toList();
    // print(churches);
    final a =
        _people
            .map((x) => x.churchName)
            .toSet()
            .map((x) => DropdownMenuItem<String>(value: x, child: Text(x)))
            .toList();
    print(a);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Unregistered Participant'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              DropdownButton<String>(
                value: churchName,
                items: a,
                onChanged: (x) {
                  // print('setting churchname to $x');
                  setState(() {
                    churchName = x ?? '';
                  });
                  // print('churchname: [$churchName]');
                },
              ),
              // TextField(
              //   controller: churchNameController,
              //   decoration: const InputDecoration(labelText: 'Church Name'),
              // ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Print'),
              onPressed: () {
                final person = Person(
                  lastNameController.text,
                  firstNameController.text,
                  churchName,
                  // churchNameController.text,
                );
                _directPrintPdf(_selectedPrinter, [person]);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<Printer>(
                    value: _selectedPrinter,
                    onChanged: (Printer? newValue) {
                      setState(() {
                        _selectedPrinter = newValue;
                      });
                    },
                    items:
                        _printers.map<DropdownMenuItem<Printer>>((
                          Printer printer,
                        ) {
                          return DropdownMenuItem<Printer>(
                            value: printer,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(printer.name),
                            ),
                          );
                        }).toList(),
                    isExpanded: true,
                    hint: const Text('Select a printer'),
                  ),
                ),
                const SizedBox(width: 32),
                TextButton(
                  onPressed: () async {
                    final selected =
                        _people.where((p) => p.isSelected).toList();
                    final doc = await _generatePdf(selected);
                    if (doc != null) {
                      _showPrintPreview(doc);
                    }
                  },
                  child: const Text('Preview'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    final selected =
                        _people.where((p) => p.isSelected).toList();
                    _directPrintPdf(_selectedPrinter, selected);
                    for (final p in _people) {
                      p.isSelected = false;
                    }
                    setState(() {});
                  },
                  child: const Text('Print'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: _showUnregisteredDialog,
                  child: const Text('Unregistered'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ParticipantList(controller: controller),
    );
  }
}
