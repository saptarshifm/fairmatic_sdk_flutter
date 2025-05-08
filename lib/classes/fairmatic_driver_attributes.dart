class FairmaticDriverAttributes {
  String firstName;
  String lastName;
  String? email;
  String? phoneNumber;

  FairmaticDriverAttributes({
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
