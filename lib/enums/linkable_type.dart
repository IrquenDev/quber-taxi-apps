enum LinkableType {

  none, text, button;

  String get apiValue => name.toUpperCase();

  static LinkableType resolve(String value) {
    return LinkableType.values.firstWhere((e) => e.apiValue == value);
  }
}