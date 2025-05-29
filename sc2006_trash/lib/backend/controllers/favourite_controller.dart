// controller class to handle methods for user's favourite recycling bins
import '../models/recycling_bin.dart';
import '../services/firestore_service.dart';
import '../models/user_session.dart';

class FavouriteController {
  // request cloud data from firestoreService
  Future<List<RecyclingBin>> loadFavoritesFromFirestore(String uid) async {
    return await FirestoreService().getFavouriteBins(uid);
  }

  // helper method
  bool isBinFavorited(RecyclingBin bin, List<RecyclingBin> favorites) {
    return favorites.any(
      (fav) => fav.block == bin.block && fav.street == bin.street,
    );
  }

  // toggling the addition/removing of favourited bins
  Future<void> toggleFavorite({
    required bool isCurrentlyFavorited,
    required RecyclingBin bin,
    required Function(bool) onResult,
  }) async {
    final uid = UserSession().uid;
    if (uid == null) return;

    final docId = "${bin.block}_${bin.street}".replaceAll(' ', '_');

    if (isCurrentlyFavorited) {
      await FirestoreService().removeFavouriteBin(uid, docId);
    } else {
      await FirestoreService().addFavouriteBin(uid, bin);
    }

    onResult(!isCurrentlyFavorited);
  }
}
