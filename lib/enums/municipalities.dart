enum Municipalities {

  arroyoNaranjo("Arroyo Naranjo", "assets/mapbox/geojson/ArroyoNaranjo.geojson"),
  boyeros("Boyeros", "assets/mapbox/geojson/Boyeros.geojson"),
  centroHabana("Centro Habana", "assets/mapbox/geojson/CentroHabana.geojson"),
  cotorro("Cotorro", "assets/mapbox/geojson/Cotorro.geojson"),
  diezDeOctubre("Diez de Octubre", "assets/mapbox/geojson/DiezDeOctubre.geojson"),
  cerro("El Cerro", "assets/mapbox/geojson/ElCerro.geojson"),
  guanabacoa("Guanabacoa", "assets/mapbox/geojson/Guanabacoa.geojson"),
  habanaDelEste("Habana del Este", "assets/mapbox/geojson/HabanaDelEste.geojson"),
  habanaVieja("La Habana Vieja", "assets/mapbox/geojson/LaHabanaVieja.geojson"),
  lisa("La Lisa", "assets/mapbox/geojson/LaLisa.geojson"),
  marianao("Marianao", "assets/mapbox/geojson/Marianao.geojson"),
  playa("Playa", "assets/mapbox/geojson/Playa.geojson"),
  plaza("Plaza de la Revolución", "assets/mapbox/geojson/Plaza.geojson"),
  regla("Regla", "assets/mapbox/geojson/Regla.geojson"),
  sanMiguel("San Miguel del Padrón", "assets/mapbox/geojson/SanMiguel.geojson");

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