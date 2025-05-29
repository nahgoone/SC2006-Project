// strategy pattern interface for updating user's attributes

abstract class UpdateStrategy {
  Future<void> update(String uid, String value);
}
