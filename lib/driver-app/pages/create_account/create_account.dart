import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/enums/asset_dpi.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/storage/session_manger.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/workflow/core/workflow.dart';
import 'package:quber_taxi/utils/workflow/impl/form_validations.dart';

class CreateDriverAccountPage extends StatefulWidget {
  const CreateDriverAccountPage({super.key});

  @override
  State<CreateDriverAccountPage> createState() => _CreateDriverAccountPageState();
}

class _CreateDriverAccountPageState extends State<CreateDriverAccountPage> {

  late final ColorScheme _colorScheme;
  late final TextTheme _textTheme;
  late final DimensionExtension _dimensions;
  late final AppLocalizations _localizations;

  late bool _isConnected;

  final _formKey = GlobalKey<FormState>();

  final _nameTFController = TextEditingController();
  final _plateTFController = TextEditingController();
  final _phoneTFController = TextEditingController();
  final _seatsTFController = TextEditingController();

  final _passwordTFController = TextEditingController();
  final _confirmPasswordTFController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  TaxiType? _selectedTaxi;

  bool get _canSubmit => _formKey.currentState!.validate() && _selectedTaxi != null;

  @override
  void didChangeDependencies() {
    _isConnected = NetworkScope.statusOf(context) == ConnectionStatus.online;
    _colorScheme = Theme.of(context).colorScheme;
    _textTheme = Theme.of(context).textTheme;
    _dimensions = Theme.of(context).extension<DimensionExtension>()!;
    _localizations = AppLocalizations.of(context)!;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [Expanded(
            child: Stack(children: [
              // Header
              Positioned(
                top: -40,
                left: 0,
                right: 0,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: _colorScheme.primaryContainer,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(_dimensions.borderRadius))
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Icon(Icons.arrow_back, color: _colorScheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.createAccountTitle,
                            style: _textTheme.titleLarge?.copyWith(
                                fontSize: 26, fontWeight: FontWeight.bold, color: _colorScheme.onPrimaryContainer),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Positioned(
                  top: 120, left: 0, right: 0, bottom: 0,
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                          key: _formKey,
                          child: Column(children: [
                            // First Card
                            Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.only(top: 60, bottom: 16, left: 16, right: 16),
                                decoration: BoxDecoration(
                                  color: _colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                child: Stack(clipBehavior: Clip.none, children: [
                                  // Taxi Image
                                  Positioned(
                                    top: -50,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(50),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            CircleAvatar(
                                              radius: 60,
                                              backgroundColor: _colorScheme.onPrimary,
                                              child: SvgPicture.asset(
                                                "assets/icons/taxi.svg",
                                                width: 80,
                                                height: 80,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: CircleAvatar(
                                                radius: 18,
                                                backgroundColor: _colorScheme.surface,
                                                child: SvgPicture.asset(
                                                  "assets/icons/camera.svg",
                                                  fit: BoxFit.scaleDown,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Form
                                  Column(spacing: 12.0, children: [
                                    const SizedBox(height: 70),
                                    // Name Text Field
                                    _buildTextField(
                                        controller: _nameTFController,
                                        label: AppLocalizations.of(context)!.nameLabel,
                                        hint: AppLocalizations.of(context)!.nameHint),
                                    // Plate Text Field
                                    _buildTextField(
                                        controller: _plateTFController,
                                        label: _localizations.plateLabel,
                                        hint: _localizations.plateHint
                                    ),
                                    // Phone Text Field
                                    _buildTextField(
                                        inputType: TextInputType.phone,
                                        controller: _phoneTFController,
                                        label: _localizations.phoneLabel,
                                        hint: AppLocalizations.of(context)!.phoneHint
                                    ),
                                    // Seats Text Field
                                    _buildTextField(
                                        inputType: TextInputType.number,
                                        controller: _seatsTFController,
                                        label: _localizations.seatsLabel,
                                        hint: _localizations.seatsHint
                                    )
                                  ])
                                ])
                            ),
                            // Attach license
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: _colorScheme.surfaceContainerLowest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.licenseLabel,
                                    style: _textTheme.bodyLarge?.copyWith(fontSize: 18, color: _colorScheme.secondary),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors.black,
                                        width: 1.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    ),
                                    onPressed: () {},
                                    child: Text(
                                      AppLocalizations.of(context)!.attachButton,
                                      style: _textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Vehicle Section
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              child: Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.vehicleTypeLabel,
                                      style: _textTheme.bodyLarge?.copyWith(fontSize: 18, color: _colorScheme.secondary),
                                    ),
                                    ...List.generate(TaxiType.values.length, (index) {
                                      return _buildTaxiCardItem(index);
                                    })
                                  ]
                                ),
                              )
                            ),
                            // Password Section
                            Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                    spacing: 12.0,
                                    children: [
                                      _buildPasswordField(
                                          controller: _passwordTFController,
                                          label: _localizations.passwordLabel,
                                          visible: _isPasswordVisible,
                                          onToggle: (v) => setState(() => _isPasswordVisible = v),
                                          validationWorkflow: Workflow<String?>()
                                              .step(RequiredStep(errorMessage: _localizations.requiredField))
                                              .step(MinLengthStep(min: 6, errorMessage: "La contraseña debe tener al menos 6 carateres"))
                                              .breakOnFirstApply(true)
                                              .withDefault((_) => null)
                                      ),
                                      _buildPasswordField(
                                          controller: _confirmPasswordTFController,
                                          label: _localizations.confirmPasswordLabel,
                                          visible: _isConfirmPasswordVisible,
                                          onToggle: (v) => setState(() => _isConfirmPasswordVisible = v),
                                          validationWorkflow: Workflow<String?>()
                                              .step(RequiredStep(errorMessage: _localizations.requiredField))
                                              .step(MatchOtherStep(
                                                other: _passwordTFController.text,
                                                errorMessage: "Las contraseñas no coinciden")
                                              )
                                              .breakOnFirstApply(true)
                                              .withDefault((_) => null)
                                      )
                                    ]
                                )
                            )
                          ])
                      )
                  )
              )
            ]),
          ),
            // Submit Button
            SizedBox(
              width: double.infinity,
                height: 56,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _colorScheme.primaryContainer,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                    onPressed: () async {
                      if (!_canSubmit) return;
                      if(!_isConnected) {
                        showToast(context: context, message: "Revise su conexión a internet");
                        return;
                      }
                      // Make the register request
                      final response = await AccountService().registerDriver(
                          name: _nameTFController.text,
                          phone: _phoneTFController.text,
                          password: _passwordTFController.text,
                          plate: _plateTFController.text,
                          type: _selectedTaxi!,
                          seats: int.parse(_seatsTFController.text)
                      );
                      // Avoid context's gaps
                      if(!context.mounted) return;
                      print(response.statusCode);
                      // Handle responses (depends on status code)
                      // OK
                      if(response.statusCode == 200) {
                        final json = jsonDecode(response.body);
                        print(json);
                        final driver = Driver.fromJson(json);
                        print(driver.toString());
                        // Save the user's session
                        final success = await SessionManager.instance.save(driver);
                        print(success);
                        if(success) {
                          // Avoid context's gaps
                          if(!context.mounted) return;
                          // Navigate to home safely
                          context.go(DriverRoutes.home);
                        }
                      }
                      // CONFLICT
                      else if(response.statusCode == 409) {
                        showToast(context: context, message: "El número de teléfono ya se encuentra regitrado");
                      }
                      // ANY OTHER STATUS CODE
                      else {
                        showToast(
                            context: context,
                            message: "No pudimos completar su registro. Por favor inténtelo más tarde"
                        );
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.finishButton,
                      style:
                      _textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: _colorScheme.onPrimaryContainer),
                    )
                )
            )
        ])
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? inputType
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 6.0, children: [
      Text(label),
      TextFormField(
          keyboardType: inputType ?? TextInputType.text,
          controller: controller,
          validator: (value) =>
              Workflow<String?>()
                  .step(RequiredStep(errorMessage: _localizations.requiredField))
                  .withDefault((_) => null)
                  .proceed(value),
          decoration: InputDecoration(
              hintText: hint,
              fillColor: Theme.of(context).colorScheme.onPrimary,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white54, width: 0.1)
              )
          )
      )
    ]);
  }

  Widget _buildTaxiCardItem(int index) {
    final taxi = TaxiType.values[index];
    final isSelected = _selectedTaxi == taxi;
    return Card(
      color: isSelected ? _colorScheme.primaryFixed : _colorScheme.surfaceContainerLowest,
      child: ExpansionTile(
        title: GestureDetector(
          onTap: () => setState(()=> _selectedTaxi = taxi),
          child: ListTile(
            // value: isSelected,
            // onChanged: (_)=> setState(()=> _selectedTaxi = taxi),
            title: Row(
                spacing: 12.0,
                children: [
                  SizedBox(
                      width: 90, height: 48,
                      child: Image.asset(taxi.assetRef(AssetDpi.xhdpi), fit: BoxFit.fill)
                  ),
                  Text(
                      TaxiType.nameOf(taxi, _localizations),
                      style: isSelected
                          ? _textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                          : _textTheme.bodyMedium
                  )
                ]
            ),
            selected: isSelected,
            // activeColor: _colorScheme.primaryContainer,
            contentPadding: EdgeInsets.zero
          ),
        ),
        tilePadding: EdgeInsets.symmetric(horizontal: 12.0),
        childrenPadding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 6.0),
        children: [
          Text(TaxiType.descriptionOf(taxi, _localizations))
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required Function(bool) onToggle,
    required Workflow<String?> validationWorkflow
}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey.shade700),
        ),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          decoration: InputDecoration(
            fillColor: Theme.of(context).colorScheme.onPrimary,
            suffixIcon: IconButton(
              icon: Icon(
                visible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey.shade600,
              ),
              onPressed: () => onToggle(!visible),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.surfaceDim,
                width: 1,
              ),
            )
          ),
          validator: (value) => validationWorkflow.proceed(value)
        )
      ]
    );
  }
}