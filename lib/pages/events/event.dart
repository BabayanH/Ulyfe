class Event {
  final int id;
  final String title;
  final String date;
  final String time;  // Added time field
  final String price;
  final String location;
  final String thumbnail;
  final String description;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.time,  // Added time field
    required this.price,
    required this.location,
    required this.thumbnail,
    required this.description,
  });
}
