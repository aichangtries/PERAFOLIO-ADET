/// The single local user. Saved in the `user_profile` Hive box.
///
/// Passwords are never stored: sign-in is simulated for this prototype.
class UserProfile {
  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.mobileNumber = '',
    this.homeAddress = '',
    this.dateOfBirth,
  });

  final String id;
  String fullName;
  String email;
  String mobileNumber;
  String homeAddress;
  DateTime? dateOfBirth;

  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;
  String get initial =>
      fullName.trim().isEmpty ? '?' : fullName.trim()[0].toUpperCase();

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'mobileNumber': mobileNumber,
        'homeAddress': homeAddress,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
      };

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) => UserProfile(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        email: map['email'] as String,
        mobileNumber: map['mobileNumber'] as String? ?? '',
        homeAddress: map['homeAddress'] as String? ?? '',
        dateOfBirth: map['dateOfBirth'] == null
            ? null
            : DateTime.parse(map['dateOfBirth'] as String),
      );
}
