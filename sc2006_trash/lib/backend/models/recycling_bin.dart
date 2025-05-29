// entity class for recycling bin, used when saving a recycling bin into user's favourite list

class RecyclingBin {
  final String block;
  final String street;
  final String postalCode;
  final String buildingName;
  final String description;
  final String link;
  final double latitude;
  final double longitude;

  RecyclingBin({
    required this.block,
    required this.street,
    required this.postalCode,
    required this.buildingName,
    required this.description,
    required this.link,
    required this.latitude,
    required this.longitude,
  });
}
