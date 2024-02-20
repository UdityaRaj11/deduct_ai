class Section {
  final String tag;
  final String description;

  Section({
    required this.tag,
    required this.description,
  });

  @override
  String toString() {
    return '$tag - $description';
  }
}
