enum LinkableType {
  NONE,
  EXTERNAL_URL,
  INTERNAL_ROUTE,
  ACTION
}

extension LinkableTypeExtension on LinkableType {
  String get value {
    switch (this) {
      case LinkableType.NONE:
        return 'NONE';
      case LinkableType.EXTERNAL_URL:
        return 'EXTERNAL_URL';
      case LinkableType.INTERNAL_ROUTE:
        return 'INTERNAL_ROUTE';
      case LinkableType.ACTION:
        return 'ACTION';
    }
  }

  static LinkableType fromString(String value) {
    switch (value) {
      case 'NONE':
        return LinkableType.NONE;
      case 'EXTERNAL_URL':
        return LinkableType.EXTERNAL_URL;
      case 'INTERNAL_ROUTE':
        return LinkableType.INTERNAL_ROUTE;
      case 'ACTION':
        return LinkableType.ACTION;
      default:
        return LinkableType.NONE;
    }
  }
} 