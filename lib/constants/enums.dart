import 'package:flutter/material.dart';

enum AuthKeysEnum {
  authData,
  accessToken,
  refreshToken,
  userId,
  userEmail,
  userName,
}

enum UserType {
  CUSTOMER,
  TAILOR,
  SHOPPING_CENTER,
}

enum Gender {
  MALE,
  FEMALE,
}

// Helper extension
extension UserTypeExtension on UserType {
  String get value {
    switch (this) {
      case UserType.CUSTOMER:
        return 'CUSTOMER';
      case UserType.TAILOR:
        return 'TAILOR';
      case UserType.SHOPPING_CENTER:
        return 'SHOPPING_CENTER';
    }
  }

  String get displayName {
    switch (this) {
      case UserType.CUSTOMER:
        return 'Customer';
      case UserType.TAILOR:
        return 'Tailor';
      case UserType.SHOPPING_CENTER:
        return 'Shopping Center';
    }
  }
}

// Gender Extension
extension GenderExtension on Gender {
  String get value {
    switch (this) {
      case Gender.MALE:
        return 'MALE';
      case Gender.FEMALE:
        return 'FEMALE';
    }
  }

  String get displayName {
    switch (this) {
      case Gender.MALE:
        return 'Male';
      case Gender.FEMALE:
        return 'Female';
    }
  }

  IconData get icon {
    switch (this) {
      case Gender.MALE:
        return Icons.male;
      case Gender.FEMALE:
        return Icons.female;
    }
  }
}