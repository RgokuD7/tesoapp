class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final List<String> groups; // List of group IDs the user belongs to
  final String? profilePicture; // URL (optional)
  final bool notificationsEnabled; // Notifications on/off

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.groups,
    this.profilePicture,
    this.notificationsEnabled = true, // default enabled
  });

  // --- Serialization (e.g. Firestore, REST API) ---
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'groups': groups,
      'profilePicture': profilePicture,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      groups: List<String>.from(map['groups'] ?? []),
      profilePicture: map['profilePicture'],
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }
}
