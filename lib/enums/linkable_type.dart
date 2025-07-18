enum LinkableType {
  NONE,
  TEXT,
  BUTTON
}

extension LinkableTypeExtension on LinkableType {
  String get value {
    switch (this) {
      case LinkableType.NONE:
        return 'NONE';
      case LinkableType.TEXT:
        return 'TEXT';
      case LinkableType.BUTTON:
        return 'BUTTON';
    }
  }

  static LinkableType fromString(String value) {
    switch (value) {
      case 'NONE':
        return LinkableType.NONE;
      case 'TEXT':
        return LinkableType.TEXT;
      case 'BUTTON':
        return LinkableType.BUTTON;
      default:
        return LinkableType.NONE;
    }
  }
} 