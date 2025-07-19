import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/enums/asset_dpi.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/storage/session_manger.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/image/image_utils.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'package:quber_taxi/utils/workflow/core/workflow.dart';
import 'package:quber_taxi/utils/workflow/impl/form_validations.dart';

class CreateDriverAccountPage extends StatefulWidget {

  final Uint8List faceIdImage;

  const CreateDriverAccountPage({super.key, required this.faceIdImage});

  @override
  State<CreateDriverAccountPage> createState() => _CreateDriverAccountPageState();
}

class _CreateDriverAccountPageState extends State<CreateDriverAccountPage> {

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
  XFile? _taxiImage;
  // XFile? _licenseImage;

  bool get _canSubmit => _formKey.currentState!.validate()
      && _selectedTaxi != null
      && _taxiImage != null;
      // && _licenseImage != null;

  bool _isProcessingImage = false;

  void _showExitConfirmationDialog() {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.confirmExitTitle),
          content: Text(localizations.confirmExitMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.cancelButton),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go(CommonRoutes.login);
              },
              child: Text(localizations.acceptButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final localizations = AppLocalizations.of(context)!;
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
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(dimensions.borderRadius)),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          IconButton(onPressed: _showExitConfirmationDialog, icon: Icon(Icons.arrow_back), color: Theme.of(context).colorScheme.onPrimaryContainer),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.createAccountTitle,
                            style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
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
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(dimensions.borderRadius),
                                  border: Border.all(
                                    color: colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Center(
                                        child: GestureDetector(
                                            onTap: () async {
                                              final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                                              if (pickedImage != null) {
                                                setState(() => _isProcessingImage = true);
                                                final compressedImage = await compressXFileToTargetSize(pickedImage, 5);
                                                setState(() => _isProcessingImage = false);
                                                if (compressedImage != null) {
                                                  setState(() {
                                                    _taxiImage = compressedImage;
                                                  });
                                                }
                                              }
                                            },
                                            child: _buildCircleImagePicker()
                                        )
                                    ),
                                    // Form
                                    Column(spacing: 12.0, children: [
                                      // Name Text Field
                                      _buildTextField(
                                          controller: _nameTFController,
                                          maxLength: 50,
                                          label: AppLocalizations.of(context)!.nameLabel,
                                          hint: AppLocalizations.of(context)!.nameHint),
                                      // Plate Text Field
                                      _buildTextField(
                                          controller: _plateTFController,
                                          label: AppLocalizations.of(context)!.carRegistration,
                                          hint: localizations.plateHint,
                                          maxLength: 7,
                                        ),
                                        // Phone Text Field
                                        _buildTextField(
                                          inputType: TextInputType.phone,
                                          controller: _phoneTFController,
                                          label: AppLocalizations.of(context)!.phoneNumberDriver,
                                          hint: AppLocalizations.of(context)!.phoneHint,
                                          maxLength: 8,
                                        ),
                                        // Seats Text Field
                                        _buildTextField(
                                          inputType: TextInputType.number,
                                          controller: _seatsTFController,
                                          label: AppLocalizations.of(context)!.numberOfSeats,
                                          hint: localizations.seatsHint,
                                        maxLength: 3,
                                      )
                                    ]),
                                  ],
                                )
                            ),
                            // Attach license
                            // Container(
                            //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            //   decoration: BoxDecoration(
                            //     color: colorScheme.surfaceContainerLowest,
                            //     borderRadius: BorderRadius.circular(16),
                            //     border: Border.all(
                            //       color: Colors.grey.shade200,
                            //       width: 1,
                            //     ),
                            //   ),
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Text(
                            //         AppLocalizations.of(context)!.licenseLabel,
                            //         style: textTheme.bodyLarge?.copyWith(fontSize: 18, color: colorScheme.secondary),
                            //       ),
                            //       TextButton(
                            //         style: TextButton.styleFrom(
                            //           side: BorderSide(
                            //             color: Colors.black,
                            //             width: 1.0,
                            //           ),
                            //           shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.circular(8),
                            //           ),
                            //           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            //         ),
                            //         onPressed: () async {
                            //           final image = await ImagePicker().pickImage(source: ImageSource.camera);
                            //           if(image != null) {
                            //             setState(() => _licenseImage = image);
                            //           }
                            //         },
                            //         child: Text(
                            //           _licenseImage == null
                            //               ? AppLocalizations.of(context)!.attachButton
                            //               : "Cambiar"
                            //         )
                            //       )
                            //     ]
                            //   )
                            // ),
                            // Vehicle Section
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              child: Card(
                                color: colorScheme.surface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusLarge),
                                  side: BorderSide(
                                    color: colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          AppLocalizations.of(context)!.vehicleTypeLabel,
                                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.secondary),
                                        ),
                                      ),
                                      ...List.generate(TaxiType.values.length, (index) {
                                        return _buildTaxiCardItem(index);
                                      })
                                    ]
                                  ),
                                ),
                              )
                            ),
                            // Password Section
                            Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusLarge),
                                ),
                                child: Column(
                                    spacing: 12.0,
                                    children: [
                                      _buildPasswordField(
                                          controller: _passwordTFController,
                                          label: localizations.passwordLabel,
                                          hint: localizations.passwordHint,
                                          visible: _isPasswordVisible,
                                          onToggle: (v) => setState(() => _isPasswordVisible = v),
                                          validationWorkflow: Workflow<String?>()
                                              .step(RequiredStep(errorMessage: localizations.requiredField))
                                              .step(MinLengthStep(min: 6, errorMessage: localizations.passwordMinLengthError))
                                              .breakOnFirstApply(true)
                                              .withDefault((_) => null)
                                      ),
                                      _buildPasswordField(
                                          controller: _confirmPasswordTFController,
                                          label: localizations.confirmPasswordLabel,
                                          hint: localizations.confirmPasswordHint,
                                          visible: _isConfirmPasswordVisible,
                                          onToggle: (v) => setState(() => _isConfirmPasswordVisible = v),
                                          validationWorkflow: Workflow<String?>()
                                              .step(RequiredStep(errorMessage: localizations.requiredField))
                                              .step(MatchOtherStep(
                                                other: _passwordTFController.text,
                                                errorMessage: localizations.passwordsDoNotMatch))
                                              .breakOnFirstApply(true)
                                              .withDefault((_) => null)
                                      )
                                    ]
                                )
                            )
                          ])
                      )
                  )
              ),
              if(_isProcessingImage)
                Positioned.fill(child: Center(child: CircularProgressIndicator()))
            ]),
          ),
            // Submit Button
            SizedBox(
              width: double.infinity,
                height: 56,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
                    onPressed: () async {
                      if (!_canSubmit) return;
                      if(!hasConnection(context)) {
                        showToast(context: context, message: localizations.checkConnection);
                        return;
                      }
                      // Make the register request
                      final response = await AccountService().registerDriver(
                          name: _nameTFController.text,
                          phone: _phoneTFController.text,
                          password: _passwordTFController.text,
                          plate: _plateTFController.text,
                          type: _selectedTaxi!,
                          seats: int.parse(_seatsTFController.text),
                          taxiImage: _taxiImage!,
                          // licenseImage: _licenseImage!,
                          faceIdImage: widget.faceIdImage
                      );
                      // Avoid context's gaps
                      if(!context.mounted) return;
                      // Handle responses (depends on status code)
                      // OK
                      if(response.statusCode == 200) {
                        final json = jsonDecode(response.body);
                        final driver = Driver.fromJson(json);
                        // Save the user's session
                        final success = await SessionManager.instance.save(driver);
                        if(success) {
                          // Avoid context's gaps
                          if(!context.mounted) return;
                          // Navigate to home safely
                          context.go(DriverRoutes.home);
                        }
                      }
                      // CONFLICT
                      else if(response.statusCode == 409) {
                        showToast(context: context, message: localizations.phoneAlreadyRegistered);
                      }
                      // ANY OTHER STATUS CODE
                      else {
                        showToast(
                            context: context,
                            message: localizations.registrationError
                        );
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.finishButton,
                      style:
                      textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer),
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
    TextInputType? inputType,
    int? maxLength,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.normal,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          keyboardType: inputType ?? TextInputType.text,
          controller: controller,
          maxLength: maxLength,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink(),
          validator: (value) =>
              Workflow<String?>()
                  .step(RequiredStep(errorMessage: AppLocalizations.of(context)!.requiredField))
                  .withDefault((_) => null)
                  .proceed(value),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTaxiCardItem(int index) {
    final localizations = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final taxi = TaxiType.values[index];
    final isSelected = _selectedTaxi == taxi;
    return Card(
      color: isSelected ? colorScheme.primaryFixed : colorScheme.surface,
      child: ExpansionTile(
        title: GestureDetector(
          onTap: () => setState(()=> _selectedTaxi = taxi),
          child: ListTile(
              title: Row(
                  spacing: 12.0,
                  children: [
                    SizedBox(
                        width: 90, height: 48,
                        child: Image.asset(taxi.assetRef(AssetDpi.xhdpi), fit: BoxFit.fill)
                    ),
                    Text(
                        TaxiType.nameOf(taxi, localizations),
                        style: isSelected
                            ? textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
                            : textTheme.bodyMedium
                    )
                  ]
              ),
              selected: isSelected,
              contentPadding: EdgeInsets.zero
          ),
        ),
        tilePadding: EdgeInsets.symmetric(horizontal: 12.0),
        childrenPadding: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 6.0),
        children: [
          Text(TaxiType.descriptionOf(taxi, localizations))
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool visible,
    required Function(bool) onToggle,
    required Workflow<String?> validationWorkflow,
    int? maxLength,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: !visible,
          maxLength: maxLength,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => const SizedBox.shrink(),
          validator: (value) => validationWorkflow.proceed(value),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            suffixIcon: IconButton(
              icon: Icon(
                visible ? Icons.visibility : Icons.visibility_off,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () => onToggle(!visible),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCircleImagePicker() {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        // Main Circle with shadow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 80,
            backgroundColor: colorScheme.onSecondary,
            backgroundImage: _taxiImage != null ? FileImage(File(_taxiImage!.path)) : null,
            child: _taxiImage == null
                ? SvgPicture.asset(
              "assets/icons/taxi.svg",
              width: Theme.of(context).iconTheme.size! * 3,
              color: colorScheme.onSecondaryContainer,
            )
                : null,
          ),
        ),
        // Camera icon positioned at bottom right (similar to first code)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 33,
            height: 33,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: SvgPicture.asset(
                "assets/icons/camera.svg",
                color: Theme
                    .of(context)
                    .colorScheme
                    .onSecondaryContainer,
                fit: BoxFit.scaleDown,
              ),
              onPressed: () async {
                final image = await ImagePicker().pickImage(
                    source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _taxiImage = image);
                }
              },
            ),
          ),
        ),
        if (_taxiImage != null)
          Positioned(
            top: 8.0,
            right: 8.0,
            child: GestureDetector(
              onTap: () {
                setState(() => _taxiImage = null);
              },
              child: CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.error,
                child: Icon(Icons.close, color: colorScheme.onError, size: 16),
              ),
            ),
          ),
      ],
    );
  }
}