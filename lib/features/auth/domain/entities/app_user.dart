class AppUser {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final bool isAnonymous;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.isAnonymous = false,
  });

  // convert app user -> json
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'name': name, 'email': email};
  }

  // convert json -> app user
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(uid: json['uid'], name: json['name'], email: json['email']);
  }
}
