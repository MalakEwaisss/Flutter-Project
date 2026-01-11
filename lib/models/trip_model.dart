class TripModel {
  final String id;
  final String title;
  final String location;
  final double rating;
  final int reviews;
  final int price;
  final String date;
  final String? image;
  final String? airline;
  final String? aircraft;
  final String? tripClass;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TripModel({
    required this.id,
    required this.title,
    required this.location,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.date,
    this.image,
    this.airline,
    this.aircraft,
    this.tripClass,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Create from JSON (Supabase response)
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviews: json['reviews'] ?? 0,
      price: json['price'] ?? 0,
      date: json['date'] ?? '',
      image: json['image'],
      airline: json['airline'],
      aircraft: json['aircraft'],
      tripClass: json['class'],
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Convert to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    final json = {
      'title': title,
      'location': location,
      'rating': rating,
      'reviews': reviews,
      'price': price,
      'date': date,
      'image': image,
      'airline': airline,
      'aircraft': aircraft,
      'class': tripClass,
      'description': description,
    };

    // Only include id if it's not empty (for updates)
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    return json;
  }

  // Convert to Map format compatible with existing trip_data.dart format
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'rating': rating,
      'reviews': reviews,
      'price': price,
      'date': date,
      'image': image,
      'airline': airline,
      'aircraft': aircraft,
      'class': tripClass,
      'description': description,
    };
  }

  // Create a copy with updated fields
  TripModel copyWith({
    String? id,
    String? title,
    String? location,
    double? rating,
    int? reviews,
    int? price,
    String? date,
    String? image,
    String? airline,
    String? aircraft,
    String? tripClass,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      price: price ?? this.price,
      date: date ?? this.date,
      image: image ?? this.image,
      airline: airline ?? this.airline,
      aircraft: aircraft ?? this.aircraft,
      tripClass: tripClass ?? this.tripClass,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Validation
  bool isValid() {
    return title.isNotEmpty &&
        location.isNotEmpty &&
        price > 0 &&
        date.isNotEmpty &&
        rating >= 0 &&
        rating <= 5 &&
        reviews >= 0;
  }

  String? validate() {
    if (title.isEmpty) return 'Title is required';
    if (location.isEmpty) return 'Location is required';
    if (price <= 0) return 'Price must be greater than 0';
    if (date.isEmpty) return 'Date is required';
    if (rating < 0 || rating > 5) return 'Rating must be between 0 and 5';
    if (reviews < 0) return 'Reviews cannot be negative';
    return null;
  }
}
