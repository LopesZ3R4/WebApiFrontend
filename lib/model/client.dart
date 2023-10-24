// lib/models/client.dart
class Client {
  int id;
  String name;
  String address;
  String contactNumber;
  String email;

  Client(
      {required this.id,
      required this.name,
      required this.address,
      required this.contactNumber,
      required this.email});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['Id'],
      name: json['Name'],
      address: json['Address'],
      contactNumber: json['ContactNumber'],
      email: json['Email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Address': address,
      'ContactNumber': contactNumber,
      'Email': email,
    };
  }
}
