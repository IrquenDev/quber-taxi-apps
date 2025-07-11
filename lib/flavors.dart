enum Flavor {
  client,
  driver,
  admin,
}

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.client:
        return 'Quber';
      case Flavor.driver:
        return 'Quber Chofer';
      case Flavor.admin:
        return 'Quber Admin';
    }
  }

}
