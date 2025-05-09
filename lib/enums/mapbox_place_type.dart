enum MapboxPlaceType {
  country('country'),
  region('region'),
  postcode('postcode'),
  district('district'),
  place('place'),
  locality('locality'),
  neighborhood('neighborhood'),
  address('address'),
  poi('poi'),
  poiLandmark('poi.landmark');

  final String value;
  const MapboxPlaceType(this.value);
}