// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get unknown => 'Municipio no reconocido:';

  @override
  String get originName => 'Seleccione la ubicación de origen';

  @override
  String get destinationName => 'Seleccione la ubicación de destino';

  @override
  String get carPrefer => '¿Qué tipo de vehículo prefiere?';

  @override
  String get howTravels => '¿Cuántas personas viajan?';

  @override
  String get pets => '¿Lleva mascota?';

  @override
  String get distance => 'Distancia:';

  @override
  String get minDistance => 'Distancia mínima:';

  @override
  String get maxDistance => 'Distancia máxima:';

  @override
  String get price => 'Precio:';

  @override
  String get minPrice => 'Precio mínimo:';

  @override
  String get maxPrice => 'Precio máximo:';

  @override
  String get askTaxi => 'Pedir taxi';

  @override
  String get vehicle => 'Vehículo';

  @override
  String get tooltipAboutEstimations =>
      'Las estimaciones que se presentan a continuación, a pesar de ser muy prescisas, siguen siendo valores aproximados. Refiérase a ellas como una guía. La distancia y precio reales se calcularán durante la travesía.';

  @override
  String get settingsHome => 'Ajustes';

  @override
  String get map => 'Mapa';

  @override
  String get select => 'Seleccionar';

  @override
  String get origin => 'Origen';

  @override
  String get destination => 'Destino';

  @override
  String get marker => 'Marcador';

  @override
  String get mapBottomItem => 'Mapa';

  @override
  String get requestTaxiBottomItem => 'Pedir Taxi';

  @override
  String get settingsBottomItem => 'Ajustes';

  @override
  String get quberPointsBottomItem => 'P. Quber';

  @override
  String get quberPoints => 'Puntos Quber';

  @override
  String get accumulatedPoints => 'Puntos acumulados';

  @override
  String get quberPointsEarned => 'Puntos Quber Ganados';

  @override
  String get inviteFriendsDescription =>
      'Invita amigos con tu código de referido para ganar más puntos. Úsalos para comprar descuentos en tus viajes.';

  @override
  String get driverCredit => 'Crédito del Conductor';

  @override
  String get driverCreditDescription =>
      'Saldo disponible en tu cuenta. Este crédito se actualiza después de cada viaje completado.';

  @override
  String get ubicationFailed =>
      'Su ubicación actual está fuera de los límites de La Habana';

  @override
  String get permissionsDenied => 'Permiso de ubicación denegado';

  @override
  String get permissionDeniedPermanently =>
      'Permiso de ubicación denegado permanentemente';

  @override
  String get locationError => 'Error al obtener la ubicación';

  @override
  String get destinationsLimitedToHavana =>
      'Los destinos están limitados a La Habana';

  @override
  String get selectLocation => 'Seleccionar ubicación';

  @override
  String get tapMapToSelectLocation =>
      'Toque el mapa para seleccionar una ubicación';

  @override
  String get writeUbication => 'Escriba una ubicación...';

  @override
  String get selectUbication => 'Seleccione ubicación desde el mapa';

  @override
  String get actualUbication => 'Usar mi ubicación actual';

  @override
  String get outLimits =>
      'Su ubicación actual está fuera de los límites de La Habana';

  @override
  String get noResultsTitle => '¡Upps!';

  @override
  String get noResultsMessage =>
      'Nuestro proveedor no fue capaz de encontrar resultados similares.';

  @override
  String get noResultsHint =>
      'Intenta con una búsqueda más genérica y luego afínala desde el mapa.';

  @override
  String get searchDrivers => 'Buscando conductores...';

  @override
  String get selectTravel => 'Seleccione un viaje';

  @override
  String get updateTravel => 'Actualizar viajes';

  @override
  String get noTravel => 'Sin viajes disponibles';

  @override
  String get noAssignedTrip => 'No se pudo asignar el viaje';

  @override
  String get countPeople => 'Cantidad de personas que viajan:';

  @override
  String get pet => 'Mascota:';

  @override
  String get typeVehicle => 'Tipo de vehículo:';

  @override
  String get startTrip => 'Iniciar Viaje (Cliente Recogido)';

  @override
  String get people => 'Personas';

  @override
  String get profileUpdatedSuccessfully => 'Perfil actualizado exitosamente';

  @override
  String get from => 'Desde: ';

  @override
  String get until => 'Hasta: ';

  @override
  String get welcomeTitle => 'Bienvenido\na Quber';

  @override
  String get enterPhoneNumber => 'Introduzca su número de teléfono';

  @override
  String get enterPassword => 'Introduzca su contraseña';

  @override
  String get invalidEmail => 'Ingrese un correo válido';

  @override
  String get requiredField => 'Campo requerido';

  @override
  String get requiredEmail => 'Por favor ingrese su correo';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get forgotPassword => 'Olvidé mi contraseña';

  @override
  String get createAccountLogin => 'Crear cuenta';

  @override
  String get recoverPassword => 'Recuperar Contraseña';

  @override
  String get recoverPasswordDescription =>
      'Por favor, introduzca su número de teléfono. Le enviaremos un código para restablecer su contraseña.';

  @override
  String get sendButton => 'Enviar';

  @override
  String get noReviews => 'Aún sin reseñas del conductor';

  @override
  String get reviewSctHeader => 'Tu opinión nos ayuda a mejorar';

  @override
  String get reviewTooltip => '(Califica el viaje de 1 a 5 estrellas)';

  @override
  String get reviewTextHint => 'Ayúdanos a mejorar dejando tu opinión';

  @override
  String get tripCompleted => 'Viaje Finalizado';

  @override
  String get resetPasswordTitle => 'Restablecer Contraseña';

  @override
  String get newPasswordHint => 'Nueva contraseña';

  @override
  String get confirmPasswordHint => 'Vuelva a introducir su contraseña';

  @override
  String get resetButton => 'Restablecer';

  @override
  String get allFieldsRequiredMessage => 'Complete todos los campos';

  @override
  String get passwordsDoNotMatchMessage => 'Las contraseñas no coinciden';

  @override
  String get resetSuccessMessage => 'Contraseña restablecida correctamente';

  @override
  String get invalidCodeMessage => 'Código inválido o expirado';

  @override
  String get unexpectedErrorMessage => 'Error inesperado. Intente más tarde.';

  @override
  String get codeSendErrorMessage =>
      'Error al enviar el código. Intente nuevamente.';

  @override
  String get invalidPhoneMessage => 'Número inválido. Debe tener 8 dígitos.';

  @override
  String get incorrectPasswordMessage => 'La contraseña es incorrecta';

  @override
  String get phoneNotRegisteredMessage =>
      'El número de teléfono no se encuentra registrado';

  @override
  String get unexpectedErrorLoginMessage =>
      'Ocurrió algo mal, por favor inténtelo más tarde';

  @override
  String get locationNotFoundTitle => 'Ubicación no encontrada';

  @override
  String get locationNotFoundMessage => 'Aún no hemos encontrado su ubicación.';

  @override
  String get locationNotFoundHint =>
      'Seleccione este botón para intentar de nuevo.';

  @override
  String get locationNotFoundButton => 'Entendido';

  @override
  String get identityVerify => 'Verificación de identidad';

  @override
  String get confirmIdentity => 'Necesitamos confirmar su identidad.';

  @override
  String get noBot =>
      'Por favor, toma una selfie para confirmar que no eres un bot.';

  @override
  String get noUsedImage =>
      'No usaremos esta imagen como foto de perfil ni se mostrará públicamente.';

  @override
  String get verificationUser =>
      'Este paso es parte de nuestro sistema de verificación para garantizar la seguridad de todos los usuarios.';

  @override
  String get takeSelfie => 'Tomar Selfie';

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get name => 'Nombre:';

  @override
  String get nameAndLastName => 'Introduzca su nombre y apellidos';

  @override
  String get phoneNumber => 'Núm. teléfono:';

  @override
  String get password => 'Contraseña:';

  @override
  String get passwordConfirm => 'Confirmar contraseña:';

  @override
  String get endRegistration => 'Finalizar Registro';

  @override
  String get accountCreatedSuccess => 'Cuenta creada satisfactoriamente';

  @override
  String get errorCreatingAccount => 'Ocurrió un error al crear la cuenta';

  @override
  String get checkYourInternetConnection =>
      'Compruebe su conexión a Internet e intente de nuevo';

  @override
  String get nowCanAskForTaxi => '¡Ya puede ir a por su viaje!';

  @override
  String get thanks => 'Gracias por confirmar su identidad.';

  @override
  String get successConfirm => 'Hemos confirmado su identidad con éxito.';

  @override
  String get passSecurity =>
      'Este paso es parte de nuestro sistema de verificación para garantizar la seguridad de todos los usuarios.';

  @override
  String get driverInfoTitle => 'Información del Conductor';

  @override
  String get averageRating => 'Valoración promedio';

  @override
  String get vehiclePlate => 'Chapa del vehículo';

  @override
  String get seatNumber => 'Número de asientos';

  @override
  String get vehicleType => 'Tipo de vehículo';

  @override
  String get acceptButton => 'Aceptar';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get adminSettingsTitle => 'Ajustes del Administrador';

  @override
  String get pricesSectionTitle => 'Precios';

  @override
  String get driverCreditPercentage => 'Porciento de crédito para Quber:';

  @override
  String get tripPricePerKm => 'Precio de viaje por KM y vehículo:';

  @override
  String get saveButtonPanel => 'Guardar';

  @override
  String get passwordsSectionTitle => 'Contraseñas';

  @override
  String get newPassword => 'Nueva contraseña:';

  @override
  String get confirmPassword => 'Confirme contraseña:';

  @override
  String get otherActionsTitle => 'Otras acciones';

  @override
  String get viewAllTrips => 'Ver todos los viajes';

  @override
  String get viewAllDrivers => 'Ver todos los conductores';

  @override
  String get nameDriver => 'Nombre:';

  @override
  String get carRegistration => 'Chapa:';

  @override
  String get phoneNumberDriver => 'Num. teléfono:';

  @override
  String get email => 'Correo electrónico:';

  @override
  String get numberOfSeats => 'Número de asientos:';

  @override
  String get saveInformation => 'Guardar';

  @override
  String get myAccount => 'Ajustes';

  @override
  String get balance => 'Balance:';

  @override
  String get valuation => 'Valoración acumulada:';

  @override
  String get quberCredits => 'Crédito de Quber acumulado:';

  @override
  String get nextPay => 'Próxima fecha de pago:';

  @override
  String get passwordConfirmDriver => 'Confirme contraseña:';

  @override
  String get passwordDriver => 'Contraseña:';

  @override
  String get goBack => 'Regresar';

  @override
  String get aboutUsDriver => 'Sobre Nosotros';

  @override
  String get aboutDevDriver => 'Sobre el desarrollador';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get requiredLabel =>
      'Por favor complete todos los campos obligatorios';

  @override
  String get aboutUsTitle => 'Acerca de Nosotros';

  @override
  String get companyDescription => 'Empresa - Agencia de Taxi';

  @override
  String get companyAdress =>
      'Calle 4ta / Central y Mercado, Reparto Martín Pérez, San Miguel del Padrón';

  @override
  String get companyAboutText =>
      'Quber es una Empresa dedicada a ofrecer servicios de transporte a través de una red organizada de taxis, enfocada en brindar un servicio seguro, puntual y de calidad. La empresa se compromete con la satisfacción del cliente y el bienestar de sus conductores, promoviendo una experiencia de movilidad confiable, accesible, centrada en el respeto, la responsabilidad y la eficiencia.';

  @override
  String get contactAddress => 'Calle 10 entre Línea y 23';

  @override
  String get tripsPageTitle => 'Viajes';

  @override
  String get tripPrice => 'Precio del viaje: ';

  @override
  String get tripDuration => 'Duración del viaje: ';

  @override
  String get clientSectionTitle => 'Cliente:';

  @override
  String get clientName => 'Nombre: ';

  @override
  String get clientPhone => 'Teléfono: ';

  @override
  String get driverSectionTitle => 'Conductor:';

  @override
  String get driverName => 'Nombre: ';

  @override
  String get driverPhone => 'Teléfono: ';

  @override
  String get driverPlate => 'Chapa: ';

  @override
  String get aboutDeveloperTitle => 'Acerca del Desarrollador';

  @override
  String get softwareCompany => 'Empresa de software';

  @override
  String get aboutText =>
      'Irquen, fundada por tres estudiantes y construida como una familia de amigos, hoy es una empresa de software con bases firmes y visión de futuro. Su propósito es hacer que la digitalización sea rápida y accesible para todos. Su misión es llevar la tecnología a cada rincón, crecer, optimizar y expandirse. Su visión es superar límites, encontrar soluciones y crear lo que aún no existe.';

  @override
  String get identityVerificationTitle => 'Verificación de identidad';

  @override
  String get confirmIdentityHeader => 'Necesitamos confirmar su identidad';

  @override
  String get takeSelfieInstruction =>
      'Por favor, toma una selfie para confirmar que no eres un bot.';

  @override
  String get selfieUsageNote =>
      'No usaremos esta imagen como foto de perfil ni se mostrará públicamente.';

  @override
  String get verificationPurpose =>
      'Este paso es parte de nuestro proceso de verificación para garantizar la seguridad de todos los usuarios.';

  @override
  String get takeSelfieButton => 'Tomar Selfie';

  @override
  String get identityVerificationHeader => 'Verificación de identidad';

  @override
  String get thankYouForVerification => 'Gracias por confirmar su identidad';

  @override
  String get identityConfirmedSuccessfully =>
      'Hemos confirmado su identidad con éxito.';

  @override
  String get verificationBenefits =>
      'Este proceso nos ayuda a proteger su cuenta y a mantener nuestra comunidad segura para todos los usuarios.';

  @override
  String get createAccountButton => 'Crear Cuenta';

  @override
  String get titlePlaceholder =>
      'Aquí debería aparecer un texto, pero parece que no se ha cargado.';

  @override
  String get descriptionPlaceholder =>
      'Aquí debería aparecer una descripción, pero parece que no se ha cargado. Por favor, espere un momento. Si el problema persiste, cierre la aplicación y vuelva a abrirla.';

  @override
  String get createAccountTitle => 'Crear Cuenta';

  @override
  String get nameLabel => 'Nombre:';

  @override
  String get nameHint => 'Introduzca su nombre y apellidos';

  @override
  String get plateLabel => 'Chapa:';

  @override
  String get plateHint => 'Escriba la chapa de su vehículo';

  @override
  String get phoneLabel => 'Núm. de teléfono:';

  @override
  String get phoneHint => 'Ej: 5566XXXX';

  @override
  String get seatsLabel => 'Número de asientos:';

  @override
  String get seatsHint => 'Ej: 4';

  @override
  String get licenseLabel => 'Licencia de conducción';

  @override
  String get attachButton => 'Adjuntar';

  @override
  String get vehicleTypeLabel => 'Seleccione su tipo de vehículo:';

  @override
  String get standardVehicle => 'Estándar';

  @override
  String get standardDescription =>
      'La opción más común para viajes diarios. Para 3 o 4 pasajeros, con confort aceptable, buen rendimiento y tarifas accesibles.';

  @override
  String get familyVehicle => 'Familiar';

  @override
  String get familyDescription =>
      'Espacioso y cómodo, ideal para grupos de 6 o más personas o para viajes con equipaje adicional. Perfecto para traslados en grupo o viajes largos.';

  @override
  String get comfortVehicle => 'Confort';

  @override
  String get comfortDescription =>
      'Una experiencia superior en comodidad. Asientos más amplios, suspensión suave, aire acondicionado y mayor atención al detalle. Ideal para quienes buscan un viaje más relajado y placentero.';

  @override
  String get passwordLabel => 'Contraseña:';

  @override
  String get passwordHint => 'Introduzca la contraseña deseada';

  @override
  String get confirmPasswordLabel => 'Confirme contraseña:';

  @override
  String get finishButton => 'Finalizar registro';

  @override
  String get motoTaxiVehicle => 'Mototaxi';

  @override
  String get motoTaxiDescription =>
      'Vehículo de dos o tres ruedas, ideal para trayectos cortos en zonas con tráfico intenso. Económico, ágil y perfecto para movilizarse rápidamente por calles estrechas.';

  @override
  String get updatePasswordSuccess => 'Contraseña actualizada';

  @override
  String get somethingWentWrong =>
      'Algo salió mal, por favor inténtelo más tarde';

  @override
  String get checkConnection => 'Revise su conexión a internet';

  @override
  String get save => 'Guardar';

  @override
  String get aboutUs => 'Sobre Nosotros';

  @override
  String get aboutDeveloper => 'Sobre el desarrollador';

  @override
  String get hintPassword => 'Introduzca la contraseña deseada';

  @override
  String get labelNameDriver => 'Nombre:';

  @override
  String get labelCarRegistration => 'Chapa:';

  @override
  String get labelPhoneNumberDriver => 'Num. teléfono:';

  @override
  String get labelNumberOfSeats => 'Número de asientos:';

  @override
  String get balanceLabel => 'Balance:';

  @override
  String get quberCreditsLabel => 'Crédito de Quber acumulado:';

  @override
  String get nextPayLabel => 'Próxima fecha de pago:';

  @override
  String get valuationLabel => 'Valoración acumulada:';

  @override
  String get androidOnlyText => '-';

  @override
  String get cameraPermissionDenied => 'Permiso de cámara denegado.';

  @override
  String get goBackButton => 'Regresar';

  @override
  String get faceDetectionStep => '1. Detección de rostro';

  @override
  String get livenessDetectionStep => '2. Detección de vida';

  @override
  String get selfieCapturingStep => '3. Captura de selfie';

  @override
  String get compatibilityErrorTitle => 'Error de compatibilidad';

  @override
  String get faceDetectionInstruction =>
      'Le aconsejamos que coloque su rostro en la zona indicada.';

  @override
  String get livenessDetectionInstruction =>
      'Le aconsejamos que no actúe de forma rígida, sin pestañear o respirar de manera natural, para asegurar una detección precisa del rostro.';

  @override
  String get selfieProcessingInstruction =>
      'Nuestra inteligencia artificial está procesando la selfie. Por favor, manténgase conectado a internet y evite cerrar la aplicación.';

  @override
  String get deviceNotCompatibleMessage =>
      'Su dispositivo no es compatible con la verificación facial. Por favor, contacte con soporte técnico o intente con otro dispositivo.';

  @override
  String get imageProcessingErrorTitle => 'Error de Procesamiento de Imagen';

  @override
  String get imageProcessingErrorMessage =>
      'Ocurrió un error al procesar su imagen. Por favor, inténtelo de nuevo más tarde.';

  @override
  String get cameraPermissionPermanentlyDeniedTitle =>
      'Permiso de Cámara Requerido';

  @override
  String get cameraPermissionPermanentlyDeniedMessage =>
      'El acceso a la cámara ha sido denegado permanentemente. Para usar la verificación de identidad, por favor habilite el permiso de cámara en la configuración de su dispositivo.';

  @override
  String get goToSettingsButton => 'Ir a Configuración';

  @override
  String get confirmExitTitle => 'Confirmar salida';

  @override
  String get confirmExitMessage =>
      '¿Está seguro que desea salir? Perderá todo el progreso realizado hasta ahora.';

  @override
  String get passwordMinLengthError =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get phoneAlreadyRegistered =>
      'El número de teléfono ya se encuentra registrado';

  @override
  String get registrationError =>
      'No pudimos completar su registro. Por favor inténtelo más tarde';

  @override
  String get creatingAccount => 'Creando cuenta...';

  @override
  String get newTrip => 'Nuevo Viaje';

  @override
  String get noConnection => 'Sin conexión';

  @override
  String get noConnectionMessage =>
      'La app no podrá continuar sin conexión a internet';

  @override
  String get needsApproval => 'Necesita Aprobación';

  @override
  String get needsApprovalMessage =>
      'Su cuenta está en proceso de activación. Para continuar, por favor preséntese en nuestras oficinas para la revisión técnica de su vehículo y la firma del contrato. Nos encontramos en Calle 4ta / Central y mercado, reparto Martín Pérez, San Miguel del Padrón. Una vez complete este paso, podrá comenzar a usar la app normalmente y se mostrarán las peticiones de viaje disponibles.';

  @override
  String get weWaitForYou => '¡Le esperamos!';

  @override
  String get paymentSoon => 'Pago próximo';

  @override
  String get paymentPending => 'Pago pendiente';

  @override
  String get inThreeDays => 'en 3 días';

  @override
  String get dayAfterTomorrow => 'pasado mañana';

  @override
  String get tomorrow => 'mañana';

  @override
  String paymentReminderSoon(Object timeText) {
    return 'Le recordamos que su próxima fecha de pago es $timeText.';
  }

  @override
  String get paymentReminderToday =>
      'La fecha de pago programada para hoy ha llegado. Tiene hasta 4 días para realizar el pago.';

  @override
  String paymentExpired(Object date) {
    return 'La fecha límite para el pago previamente fijado para el día $date ha expirado.';
  }

  @override
  String paymentOverdue(Object date, Object days, Object daysText) {
    return 'La fecha de pago programada fue el $date. Tiene $days $daysText para realizar el pago.';
  }

  @override
  String paymentLastDay(Object date) {
    return 'La fecha de pago programada fue el $date. Hoy es su último día para realizar el pago.';
  }

  @override
  String get day => 'día';

  @override
  String get days => 'días';

  @override
  String get paymentOfficeInfo =>
      ' Por favor, diríjase a nuestra oficina en Calle 4ta / Central y mercado, reparto Martín Pérez, San Miguel del Padrón para realizarlo. Puede consultar el monto accediendo a su perfil en la app.';

  @override
  String get thanksForAttention => 'Gracias por su atención.';

  @override
  String distanceFixed(Object distance) {
    return 'Distancia: ${distance}km';
  }

  @override
  String distanceMinimum(Object distance) {
    return 'Distancia Mínima: ${distance}km';
  }

  @override
  String distanceMaximum(Object distance) {
    return 'Distancia Máxima: ${distance}km';
  }

  @override
  String priceFixedCost(Object price) {
    return 'Precio: $price CUP';
  }

  @override
  String priceMinimumCost(Object price) {
    return 'Precio mínimo que puede costar: $price CUP';
  }

  @override
  String priceMaximumCost(Object price) {
    return 'Precio máximo que puede costar: $price CUP';
  }

  @override
  String get driverStateNotConfirmed => 'No confirmado';

  @override
  String get driverStateCanPay => 'Puede pagar';

  @override
  String get driverStatePaymentRequired => 'Pago requerido';

  @override
  String get driverStateEnabled => 'Habilitado';

  @override
  String get driverStateDisabled => 'Deshabilitado';

  @override
  String get filterByName => 'Filtrar por nombre';

  @override
  String get filterByPhone => 'Filtrar por teléfono';

  @override
  String get filterByState => 'Filtrar por estado';

  @override
  String get allStates => 'Todos los estados';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get drivers => 'Conductores';

  @override
  String get noDriversYet => 'Aún no hay conductores';

  @override
  String get noDriversFound =>
      'No se encontraron conductores con los filtros aplicados';

  @override
  String get confirmAccount => 'Confirmar Cuenta';

  @override
  String get confirmPayment => 'Confirmar Pago';

  @override
  String get actions => 'Acciones';

  @override
  String get recharge => 'Recargar';

  @override
  String get rechargeAmount => 'Monto a recargar';

  @override
  String get credit => 'Crédito';

  @override
  String creditAmount(Object amount) {
    return 'Crédito: $amount CUP';
  }

  @override
  String get rechargeSuccess => 'Crédito recargado exitosamente';

  @override
  String get rechargeError => 'Error al recargar el crédito';

  @override
  String get invalidAmount => 'Monto inválido';

  @override
  String get blockAccount => 'Bloquear cuenta';

  @override
  String get enableAccount => 'Habilitar cuenta';

  @override
  String get errorTryLater => 'Algo salió mal, por favor inténtelo más tarde';

  @override
  String peopleCount(Object count) {
    return '$count personas';
  }

  @override
  String get withPet => 'Con mascota';

  @override
  String get withoutPet => 'Sin mascota';

  @override
  String fromLocation(Object location) {
    return 'Desde: $location';
  }

  @override
  String toLocation(Object location) {
    return 'Hasta: $location';
  }

  @override
  String get acceptTrip => 'Aceptar Viaje';

  @override
  String get acceptTripConfirmMessage =>
      'Se le notificará al cliente que se ha aceptado su solicitud de viaje. Su ubicación se comenzará a compartir solo con él.';

  @override
  String get accept => 'Aceptar';

  @override
  String get locationPermissionRequired =>
      'Para comenzar a compartir su ubicación con el cliente se necesita su acceso explícito';

  @override
  String get locationPermissionBlocked =>
      'Permiso de ubicación bloqueado. Habilitar nuevamente en ajustes';

  @override
  String get invalidCreditPercentage =>
      'El porcentaje debe estar entre 0 y 100';

  @override
  String get invalidPrice => 'El precio debe ser mayor a 0';

  @override
  String get passwordMinLength =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get tripDescription => 'Descripción del viaje';

  @override
  String get myDiscountCode => 'Mi código de descuento:';

  @override
  String get inviteFriendDiscount =>
      'Invita a un amigo a usar la app y pídele que ingrese tu código al registrarse o desde Ajustes. Así recibirá un 10% de descuento en su próximo viaje.';

  @override
  String get copied => 'Copiado';

  @override
  String get accountVerification => 'Verificación de cuenta';

  @override
  String get verificationCodeMessage =>
      'Le hemos enviado un código de verificación a su número de teléfono por WhatsApp, por favor coloque el código a continuación.';

  @override
  String get verificationCodeLabel => 'Código de verificación';

  @override
  String get verificationCodeHint => 'Ingrese el código';

  @override
  String get sendCode => 'Enviar';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get sendingCode => 'Enviando código...';

  @override
  String get verifying => 'Verificando...';

  @override
  String get sendCodeError => 'Error al enviar el código. Intente nuevamente.';

  @override
  String get verifyCodeError =>
      'Error al verificar el código. Intente nuevamente.';

  @override
  String get invalidVerificationCode => 'Código de verificación inválido';

  @override
  String get verificationCodeExpired => 'Código de verificación expirado';

  @override
  String get tripRequestCancelled =>
      'Se ha cancelado la solicitud de este viaje';

  @override
  String get operationSuccessful => 'Operación realizada con éxito';

  @override
  String get errorChangingConfiguration =>
      'Error. No se pudo cambiar la configuración';

  @override
  String get errorChangingPassword => 'Error. No se pudo cambiar la contraseña';

  @override
  String get couldNotOpenPhoneDialer =>
      'No se pudo abrir el marcador de teléfono';

  @override
  String get favoritesBottomItem => 'Favoritos';

  @override
  String get myMarkers => 'Mis marcadores';

  @override
  String get notAvailable => 'N/A';

  @override
  String get currency => 'CUP';

  @override
  String get kilometers => 'km';

  @override
  String get minutes => 'min';

  @override
  String get onboardingPage1Title => '¿Listo para Viajar?';

  @override
  String get onboardingPage1Subtitle =>
      'Con solo seleccionar el municipio de destino';

  @override
  String get onboardingPage1Description =>
      'podrá viajar de forma rápida y segura';

  @override
  String get onboardingPage2Title => 'Pero primero';

  @override
  String get onboardingPage2Subtitle => '¿Cómo supo de nosotros?';

  @override
  String get referralSourceFriend => 'Por un amigo';

  @override
  String get referralSourcePoster => 'Por un cartel';

  @override
  String get referralSourcePlayStore => 'Por PlayStore';

  @override
  String get onboardingPage3Title => '¿Tienes un código de referido?';

  @override
  String get onboardingPage3Subtitle => 'Ayuda a tu amigo y gana beneficios';

  @override
  String get onboardingPage3Description =>
      'Introduce un código de referido para que tu amigo obtenga un descuento en su próximo viaje. Si no dispones de uno, puedes continuar.';

  @override
  String get onboardingPage3InputHint => 'Introduzca su Código de referido';

  @override
  String get onboardingPage4Title => '¿Cómo se calcula el precio del viaje?';

  @override
  String get onboardingPage4Subtitle => 'Basado en la distancia y el destino';

  @override
  String get onboardingPage4Description =>
      'La aplicación irá calculando y mostrando el precio en tiempo real según la distancia que se va recorriendo. Así dependiendo del municipio al que te dirijas, se te mostrará al inicio un rango estimado de precio. Esto te permite hacer paradas y visitar múltiples destinos con mayor libertad.';

  @override
  String get onboardingPage5Title => 'Puntos Quber';

  @override
  String get onboardingPage5Subtitle => 'Viaja y gana descuentos';

  @override
  String get onboardingPage5Description =>
      'Cada vez que realizas un viaje o alguien introduce tu código de referido, acumulas Puntos Quber. Estos puntos te permiten obtener descuentos en futuros viajes. ¡Viaja más y ahorra más!';

  @override
  String get tripAccepted => 'Viaje Aceptado';

  @override
  String get tripAcceptedDescription =>
      'Un conductor ha aceptado su solicitud. Ahora está en espera de su llegada. Podrá ver su ubicación en tiempo real en el mapa. Le pediremos confirmación cuando esté listo para recogerle.';

  @override
  String get nameAboutDev => 'Irquen';

  @override
  String get emailAboutDev => 'qnecesitas.desarrollo@gmail.com';

  @override
  String get phoneAboutDev => '+5355759386';

  @override
  String get websiteAboutDev => 'https://qnecesitas.nat.cu';

  @override
  String get nameAboutUs => 'Quber';

  @override
  String get phoneAboutUs => '+53 52417814';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';
}
