class GlobalValue {
  static var global;
  static GlobalValue getInstance() {
    global ??= GlobalValue();
    return global;
  }

  String _token = "";
  String _fcmToken = "";
  int _uuid = 0;
  String _phone = "";
  String _fullname = "";
  String _avaPath = "";
  String _mail = "";
  String _permission = "";
  String _countryCode = 'vi';

  // UserInfo _userInfo = UserInfo();

  // UserInfo getUserInfo() {
  //   return _userInfo;
  // }

  void setToken(String token) {
    _token = token;
  }

  String getToken() {
    return _token;
  }

  void setFCMToken(String token) {
    _fcmToken = token;
  }

  String getFCMToken() {
    return _fcmToken;
  }

  void setUuid(int uuid) {
    _uuid = uuid;
  }

  int getUuid() {
    return _uuid;
  }

  void setFullname(String name) {
    _fullname = name;
  }

  String getFullname() {
    return _fullname;
  }

  void setAvatar(String path) {
    _avaPath = path;
  }

  String getPath() {
    return _avaPath;
  }

  void setMail(String mail) {
    _mail = mail;
  }

  String getMail() {
    return _mail;
  }

  void setPhone(String phone) {
    _phone = phone;
  }

  String getPhone() {
    return _phone;
  }

  void setPermission(String permission) {
    _permission = permission;
  }

  String getPermission() {
    return _permission;
  }

  void setCountryCode(String code) {
    _countryCode = code;
  }

  String getCountryCode() {
    return _countryCode;
  }
}
