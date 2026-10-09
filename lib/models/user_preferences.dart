/// Notification and security toggles. Saved in the `user_preferences` Hive box.
class UserPreferences {
  UserPreferences({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.smsAlerts = false,
    this.promotions = false,
    this.biometricLogin = true,
    this.twoFactorAuthentication = false,
  });

  bool pushNotifications;
  bool emailNotifications;
  bool smsAlerts;
  bool promotions;
  bool biometricLogin;
  bool twoFactorAuthentication;

  Map<String, dynamic> toMap() => {
        'pushNotifications': pushNotifications,
        'emailNotifications': emailNotifications,
        'smsAlerts': smsAlerts,
        'promotions': promotions,
        'biometricLogin': biometricLogin,
        'twoFactorAuthentication': twoFactorAuthentication,
      };

  factory UserPreferences.fromMap(Map<dynamic, dynamic> map) => UserPreferences(
        pushNotifications: map['pushNotifications'] as bool? ?? true,
        emailNotifications: map['emailNotifications'] as bool? ?? true,
        smsAlerts: map['smsAlerts'] as bool? ?? false,
        promotions: map['promotions'] as bool? ?? false,
        biometricLogin: map['biometricLogin'] as bool? ?? true,
        twoFactorAuthentication:
            map['twoFactorAuthentication'] as bool? ?? false,
      );
}
