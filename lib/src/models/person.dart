class Person {
  Person(
    this.lastName,
    this.firstName,
    this.churchName, {
    this.isSelected = false,
  });

  final String lastName;
  final String firstName;
  final String churchName;
  bool isSelected;

  @override
  String toString() {
    return 'Person(lastName: $lastName, firstName: $firstName, churchName: $churchName, isSelected: $isSelected)';
  }
}
