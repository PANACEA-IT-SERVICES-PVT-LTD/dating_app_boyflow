class User {
  final String id;
  final String name;
  final bool isOnline;

  const User({required this.id, required this.name, this.isOnline = true});
}
