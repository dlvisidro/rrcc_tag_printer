import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'src/models/person.dart';
import 'src/widgets/participant_list.dart';
import 'src/widgets/preview_dialog.dart';
import 'src/widgets/unregistered_dialog.dart';
import 'src/utils/person_controller.dart';
import 'src/utils/printing.dart';

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

  void _showPrintPreview(pw.Document doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PreviewDialog(document: doc);
      },
    );
  }

  void _showUnregisteredDialog() {
    final churchNames = _people.map((x) => x.churchName).toSet().toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UnregisteredDialog(churchNames: churchNames);
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
                    final doc = await generatePdf(context, selected);
                    if (doc != null) {
                      _showPrintPreview(doc);
                    }
                  },
                  child: const Text('Preview'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () async {
                    final selected =
                        _people.where((p) => p.isSelected).toList();
                    final doc = await generatePdf(context, selected);
                    if (doc != null && context.mounted) {
                      directPrintPdf(context, _selectedPrinter, doc);
                    }
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
