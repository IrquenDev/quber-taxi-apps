import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/services/auth_service.dart';
import 'package:quber_taxi/common/widgets/custom_network_alert.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/admin_routes.dart';
import 'package:quber_taxi/navigation/routes/client_routes.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/util/runtime.dart' as runtime;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _formKey = GlobalKey<FormState>();
  final _phoneTFController = TextEditingController();
  final _passwordTFController = TextEditingController();
  var _obscureText = true;
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {

    // Init Inherited Customizers
    final localization = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;

    final isConnected = NetworkScope.statusOf(context) == ConnectionStatus.online;

    return NetworkAlertTemplate(
      alertBuilder: (_, status) => CustomNetworkAlert(status: status),
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(child: Image.asset("assets/images/login_background.png", fit: BoxFit.fill)),
            // Opacity Mask
            Positioned.fill(child: ColoredBox(color: colorScheme.shadow.withAlpha(200))),
            // Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Text
                    Text(
                      localization.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)
                    ),
                    SizedBox(height: 60),
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20.0,
                        children: [
                          // Phone Number TF
                          TextFormField(
                            controller: _phoneTFController,
                            decoration: InputDecoration(
                              hintText: localization.enterPhoneNumber,
                              fillColor: colorScheme.surfaceContainer.withAlpha(200),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: _phoneTFController.text.length == 8
                                  ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                  'assets/icons/yelow_check.svg',
                                  width: 10,
                                  height: 10,
                                ),
                              )
                                  : null,
                            ),
                            onChanged: (value) => setState(() {}),
                            validator: (value) {
                              if (value == null || value.isEmpty) return localization.requiredField;
                              return null;
                            },
                          ),
                          // Password TF
                          TextFormField(
                            controller: _passwordTFController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              hintText: localization.enterPassword,
                              suffixIcon: IconButton(
                                icon: Icon(_obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscureText = !_obscureText),
                              ),
                                fillColor: colorScheme.surfaceContainer.withAlpha(200),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(dimensions.borderRadius * 0.5),
                                borderSide: BorderSide.none
                              )
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return localization.requiredField;
                              return null;
                            },
                          ),
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () async {
                                // Validate form
                                if (_formKey.currentState!.validate()) {
                                  // Get form data
                                  final phone = _phoneTFController.text;
                                  final password = _passwordTFController.text;
                                  // Check connection
                                  if(!isConnected) return;
                                  // Init var
                                  http.Response? response;
                                  String route;
                                  // Depending on appProfile decides who we need to authenticate and set the next
                                  // route.
                                  if(runtime.isClientMode) {
                                    response = await _authService.loginClient(phone, password);
                                    route = ClientRoutes.home;
                                  } else if(runtime.isDriverMode) {
                                    response = await _authService.loginDriver(phone, password);
                                    route = DriverRoutes.home;
                                  } else {
                                    response = await _authService.loginAdmin(phone, password);
                                    route = AdminRoutes.settings;
                                  }
                                  // Handle response
                                  if(!context.mounted) return;
                                  switch (response.statusCode) {
                                    case 200: context.go(route);
                                    case 401: showToast(context: context, message: "Credenciales Incorrrectas");
                                    case 404: showToast(context: context, message: "El número de teléfono no se "
                                        "encuentra "
                                        "registrado");
                                    default: showToast(context: context, message: "Ocurrió algo mal, por favor "
                                        "inténtelo más tarde");
                                  }
                                }
                              },
                              child: Text(
                                  localization.loginButton,
                                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                              )
                            )
                          ),
                          // Forgot Password
                          TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            onPressed: () {
                              // TODO("yapmDev": @Reminder)
                              // - Impl recover password logic
                            },
                            child: Text(
                                localization.forgotPassword,
                                style: textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 16)
                            )
                          ),
                          // Create New Account
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              // TODO("yapmDev": @Reminder)
                              // - Go to create account (depends on app profile)
                            },
                            child: Text(
                              localization.createAccountLogin,
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primaryFixedDim,
                                  fontSize: 18
                              )
                            )
                          )
                        ]
                      )
                    )
                  ]
                )
              )
            )
          ]
        )
      )
    );
  }
}