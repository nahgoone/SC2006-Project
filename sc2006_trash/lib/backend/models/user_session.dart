/* stores our user session 
  1. after login we will store our UID from fireAuth
  2. call this class whenever we require UID
  3. clear this UID after logout
*/

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() {
    return _instance;
  }

  UserSession._internal();

  String? uid; // Store UID
  String? email; // Optional: store email if needed

  void clear() {
    uid = null;
    email = null;
  }
}
