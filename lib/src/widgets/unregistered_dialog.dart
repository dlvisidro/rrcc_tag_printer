import 'package:flutter/material.dart';

import '../models/person.dart';
import '../utils/printing.dart';
import '../widgets/preview_dialog.dart';

class UnregisteredDialog extends StatefulWidget {
  final List<String> churchNames;
  const UnregisteredDialog({required this.churchNames, super.key});

  @override
  UnregisteredDialogState createState() => UnregisteredDialogState();
}

class UnregisteredDialogState extends State<UnregisteredDialog> {
  final lastNameController = TextEditingController();
  final firstNameController = TextEditingController();
  final churchNameManual = TextEditingController();
  final List<String?> churchNames = [null];
  String? churchName;

  @override
  void initState() {
    super.initState();
    churchNames.addAll(widget.churchNames);
    churchName = churchNames[0];
  }

  @override
  Widget build(BuildContext context) {
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
          DropdownButton<String?>(
            value: churchName,
            items:
                churchNames
                    .map(
                      (x) => DropdownMenuItem<String?>(
                        value: x,
                        child: Text(x ?? 'input manually'),
                      ),
                    )
                    .toList(),
            onChanged: (x) {
              // print('setting churchname to $x');
              setState(() {
                churchName = x;
              });
              // print('churchname: [$churchName]');
            },
          ),
          if (churchName == null)
            TextField(
              controller: churchNameManual,
              decoration: const InputDecoration(labelText: 'Church Name'),
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
          child: const Text('Preview'),
          onPressed: () async {
            final person = Person(
              lastNameController.text,
              firstNameController.text,
              churchName ?? churchNameManual.text,
            );
            final doc = await generatePdf(context, [person]);
            if (doc != null) {
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return PreviewDialog(document: doc);
                  },
                );
              }
            }
          },
        ),
      ],
    );
  }
}
