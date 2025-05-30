enum Municipalities {

  arroyoNaranjo("Arroyo Naranjo", "assets/geojson/ArroyoNaranjo.geojson"),
  boyeros("Boyeros", "assets/geojson/Boyeros.geojson"),
  centroHabana("Centro Habana", "assets/geojson/CentroHabana.geojson"),
  cotorro("Cotorro", "assets/geojson/Cotorro.geojson"),
  diezDeOctubre("Diez de Octubre", "assets/geojson/DiezDeOctubre.geojson"),
  cerro("El Cerro", "assets/geojson/ElCerro.geojson"),
  guanabacoa("Guanabacoa", "assets/geojson/Guanabacoa.geojson"),
  habanaDelEste("Habana del Este", "assets/geojson/HabanaDelEste.geojson"),
  habanaVieja("La Habana Vieja", "assets/geojson/LaHabanaVieja.geojson"),
  lisa("La Lisa", "assets/geojson/LaLisa.geojson"),
  marianao("Marianao", "assets/geojson/Marianao.geojson"),
  playa("Playa", "assets/geojson/Playa.geojson"),
  plaza("Plaza de la Revolución", "assets/geojson/Plaza.geojson"),
  regla("Regla", "assets/geojson/Regla.geojson"),
  sanMiguel("San Miguel del Padrón", "assets/geojson/SanMiguel.geojson");

  final String name;
  final String geoJsonRef;
  const Municipalities(this.name, this.geoJsonRef);

  static String? resolveGeoJsonRef(String name) {
    for (final municipality in Municipalities.values) {
      if (municipality.name.toLowerCase() == name.toLowerCase()) {
        return municipality.geoJsonRef;
      }
    }
    return null;
  }
}