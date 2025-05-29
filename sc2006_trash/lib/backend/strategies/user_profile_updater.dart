// central updater for user's attributes
import 'update_strategy.dart';

class UserProfileUpdater {
  UpdateStrategy strategy;

  UserProfileUpdater(this.strategy);

  Future<void> execute(String uid, String value) async {
    await strategy.update(uid, value);
  }
}
