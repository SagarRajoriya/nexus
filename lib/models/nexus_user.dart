class NexusUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;

  const NexusUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  factory NexusUser.fromMap(Map<String, dynamic> m) => NexusUser(
    uid: m['uid'] as String,
    email: m['email'] as String? ?? '',
    displayName: m['displayName'] as String? ?? 'User',
    photoUrl: m['photoUrl'] as String?,
  );
}
