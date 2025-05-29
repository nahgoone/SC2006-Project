/* entity class for reward
  1. ensures consistent formatting of rewards
  2. accessed when saving a reward entry into firebase
  3. accessed when retrieving a reward entry from firebase  
*/

class Reward {
  final String id;
  final String title;
  final String description;
  final int points;
  final String image; // asset image path like "assets/images/paynow.png"

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.image,
  });

  factory Reward.fromFirestore(String id, Map<String, dynamic> data) {
    return Reward(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      points: data['points'] ?? 0,
      image: data['image'] ?? '',
    );
  }
}
