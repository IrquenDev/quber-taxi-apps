enum Municipalities {

  arroyoNaranjo("Arroyo Naranjo", "assets/geojson/polygon/ArroyoNaranjo.geojson"),
  boyeros("Boyeros", "assets/geojson/polygon/Boyeros.geojson"),
  centroHabana("Centro Habana", "assets/geojson/polygon/CentroHabana.geojson"),
  cotorro("Cotorro", "assets/geojson/polygon/Cotorro.geojson"),
  diezDeOctubre("Diez de Octubre", "assets/geojson/polygon/DiezDeOctubre.geojson"),
  cerro("El Cerro", "assets/geojson/polygon/ElCerro.geojson"),
  guanabacoa("Guanabacoa", "assets/geojson/polygon/Guanabacoa.geojson"),
  habanaDelEste("Habana del Este", "assets/geojson/polygon/HabanaDelEste.geojson"),
  habanaVieja("La Habana Vieja", "assets/geojson/polygon/LaHabanaVieja.geojson"),
  lisa("La Lisa", "assets/geojson/polygon/LaLisa.geojson"),
  marianao("Marianao", "assets/geojson/polygon/Marianao.geojson"),
  playa("Playa", "assets/geojson/polygon/Playa.geojson"),
  plaza("Plaza de la Revolución", "assets/geojson/polygon/Plaza.geojson"),
  regla("Regla", "assets/geojson/polygon/Regla.geojson"),
  sanMiguel("San Miguel del Padrón", "assets/geojson/polygon/SanMiguel.geojson");

  final String name;
  final String geoJsonRef;
  const Municipalities(this.name, this.geoJsonRef);

  static String resolveGeoJsonRef(String name) {
    for (final municipality in Municipalities.values) {
      if (municipality.name.toLowerCase() == name.toLowerCase()) {
        return municipality.geoJsonRef;
      }
    }
    throw Exception("Unmatched municipality name");
  }
}