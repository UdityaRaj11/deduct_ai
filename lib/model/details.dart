class Details {
  final String name;
  final String precaution;
  final String procedure;
  const Details({
    required this.name,
    required this.precaution,
    required this.procedure,
  });
  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      name: json['name'],
      precaution: json['precautions'],
      procedure: json['procedures'],
    );
  }
}
