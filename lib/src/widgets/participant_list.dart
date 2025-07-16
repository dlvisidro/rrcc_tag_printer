import 'package:flutter/material.dart';

// import '../models/person.dart';
import '../utils/person_controller.dart';

class ParticipantList extends StatelessWidget {
  final PersonController controller;
  const ParticipantList({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: const Row(
              children: [
                SizedBox(width: 56),
                Expanded(child: Text('Last Name', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('First Name', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Church Name', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(),
          // Data Rows
          Expanded(
            child: ListView.builder(
              itemCount: controller.persons.length,
              itemBuilder: (context, index) {
                final person = controller.persons[index];
                return InkWell(
                  onTap: () {
                    // setState(() {
                    //   person.isSelected = !person.isSelected;
                    // });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Checkbox(
                          value: person.isSelected,
                          onChanged: (bool? value) {
                            // setState(() {
                            //   person.isSelected = value!;
                            // });
                          },
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(person.lastName)),
                        Expanded(child: Text(person.firstName)),
                        Expanded(child: Text(person.churchName)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
  }
}