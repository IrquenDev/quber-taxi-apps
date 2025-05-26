enum TravelState {

  canceled("Cancelado", "CANCELED"),
  waiting("En espera", "WAITING"),
  accepted("Aceptado", "ACCEPTED"),
  inProgress("En progreso", "IN_PROGRESS"),
  completed("Completado", "COMPLETED");

  final String displayText;
  final String apiValue;
  const TravelState(this.displayText, this.apiValue);
}