import 'dart:async';
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
import 'package:quber_taxi/common/services/auth_service.dart';
import 'package:quber_taxi/enums/asset_dpi.dart';
import 'package:quber_taxi/enums/taxi_type.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/navigation/routes/driver_routes.dart';
import 'package:quber_taxi/navigation/routes/common_routes.dart';
import 'package:quber_taxi/storage/session_prefs_manger.dart';
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

  bool _showVehicleTypeError = false;
  bool _showImageError = false;

  bool get _canSubmit => _formKey.currentState!.validate()
      && _selectedTaxi != null
      && _taxiImage != null;
      // && _licenseImage != null;

  bool _isProcessingImage = false;
  bool _isSubmitting = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey _vehicleTypeKey = GlobalKey();
  
  // SMS Verification
  final _authService = AuthService();

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

  Future<void> _showVerificationDialog() async {
    final localizations = AppLocalizations.of(context)!;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    final TextEditingController codeController = TextEditingController();

    // Resend code timer logic
    bool canResendCode = false;
    int resendTimeoutSeconds = 240; // 4 minutes fixed
    Timer? resendTimer;
    
    // SMS states
    bool isSendingCode = false;
    bool isVerifying = false;
    String? errorMessage;
    
    // Function to format time as mm:ss
    String formatTime(int seconds) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }

    // Function to send verification code (for resend only)
    Future<void> sendVerificationCode(Function setDialogState) async {
      // Prevent multiple simultaneous calls
      if (isSendingCode) return;
      
      if(!hasConnection(context)) {
        setDialogState(() {
          errorMessage = localizations.checkConnection;
        });
        return;
      }

      setDialogState(() {
        isSendingCode = true;
        errorMessage = null;
      });

      try {
        final response = await _authService.requestPhoneVerificationCode(_phoneTFController.text);
        
        if (!mounted) return;
        
        setDialogState(() {
          isSendingCode = false;
          if (response.statusCode == 200) {
            errorMessage = null;
          } else {
            errorMessage = localizations.sendCodeError;
          }
        });
      } catch (e) {
        if (mounted) {
          setDialogState(() {
            isSendingCode = false;
            errorMessage = localizations.checkConnection;
          });
        }
      }
    }

    // Function to verify code
    Future<void> verifyCode(String code, Function setDialogState) async {
      if(!hasConnection(context)) {
        setDialogState(() {
          errorMessage = localizations.checkConnection;
        });
        return;
      }

      setDialogState(() {
        isVerifying = true;
        errorMessage = null;
      });

      try {
        final response = await _authService.verifyPhoneNumber(_phoneTFController.text, code);
        
        if (!mounted) return;
        
        setDialogState(() {
          isVerifying = false;
          if (response.statusCode == 200) {
            // Success - proceed with registration
            resendTimer?.cancel();
            resendTimer = null;
            Navigator.of(context).pop();
            // Wait a bit to ensure dialog is fully closed before submitting
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                _submitForm();
              }
            });
          } else if (response.statusCode == 400) {
            final responseBody = response.body;
            if (responseBody.contains("Invalid verification code")) {
              errorMessage = localizations.invalidVerificationCode;
            } else if (responseBody.contains("Verification code expired")) {
              errorMessage = localizations.verificationCodeExpired;
            } else {
              errorMessage = localizations.invalidVerificationCode;
            }
          } else {
            errorMessage = localizations.verifyCodeError;
          }
        });
      } catch (e) {
        if (mounted) {
          setDialogState(() {
            isVerifying = false;
            errorMessage = localizations.checkConnection;
          });
        }
      }
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => WillPopScope(
          onWillPop: () async => false, // Prevent back button from closing dialog
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              // Start countdown timer
              resendTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
                  if (mounted) {
                    setDialogState(() {
                      if (resendTimeoutSeconds > 0) {
                        resendTimeoutSeconds--;
                      } else {
                        canResendCode = true;
                        timer.cancel();
                      }
                    });
                  } else {
                    timer.cancel();
                  }
                });

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusMedium),
                ),
                title: Text(
                  localizations.accountVerification,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.verificationCodeMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Loading indicator for sending code
                    if (isSendingCode) ...[
                      Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            localizations.sendingCode,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                    ],
                    
                    // Error message
                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusSmall),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                              size: 16,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                    
                    TextField(
                      controller: codeController,
                      keyboardType: TextInputType.number,
                      enabled: !isSendingCode && !isVerifying,
                      decoration: InputDecoration(
                        labelText: localizations.verificationCodeLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusSmall),
                        ),
                        hintText: localizations.verificationCodeHint,
                      ),
                      maxLength: 6,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        TextButton(
                          onPressed: (canResendCode && !isSendingCode && !isVerifying) ? () {
                            setDialogState(() {
                              canResendCode = false;
                              // Reset timeout to 4 minutes
                              resendTimeoutSeconds = 240;
                              resendTimer?.cancel();
                              resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
                                if (mounted) {
                                  setDialogState(() {
                                    if (resendTimeoutSeconds > 0) {
                                      resendTimeoutSeconds--;
                                    } else {
                                      canResendCode = true;
                                      timer.cancel();
                                    }
                                  });
                                } else {
                                  timer.cancel();
                                }
                              });
                            });
                            // Send verification code again
                            sendVerificationCode(setDialogState);
                          } : null,
                          child: Text(
                            localizations.resendCode,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: (canResendCode && !isSendingCode && !isVerifying)
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        if (!canResendCode) ...[
                          const SizedBox(width: 8.0),
                          Text(
                            formatTime(resendTimeoutSeconds),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                actions: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
                        ),
                      ),
                      onPressed: (!isSendingCode && !isVerifying) ? () {
                        final code = codeController.text.trim();
                        if (code.isNotEmpty) {
                          verifyCode(code, setDialogState);
                        }
                      } : null,
                      child: isVerifying
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              Text(localizations.verifying),
                            ],
                          )
                        : Text(localizations.sendCode),
                    ),
                  ),
                ],
              );
            },
          ),
        )
    ).then((_) {
      // Clean up timer if dialog is closed by any other means
      resendTimer?.cancel();
      resendTimer = null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFirstError() {
    // Scroll to the first error found
    if (!_formKey.currentState!.validate()) {
      // If there are errors in TextFormFields, scroll to the top of the form
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else if (_taxiImage == null) {
      // Scroll to vehicle image
      _scrollToWidget(_imageKey);
    } else if (_selectedTaxi == null) {
      // Scroll to vehicle type section
      _scrollToWidget(_vehicleTypeKey);
    }
  }

  void _scrollToWidget(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _validateAndSubmit() async {
    final localizations = AppLocalizations.of(context)!;
    setState(() {
      _showImageError = _taxiImage == null;
      _showVehicleTypeError = _selectedTaxi == null;
    });

    if (!_canSubmit) {
      _scrollToFirstError();
      return;
    }

    // Send verification code first, then show dialog
    await _sendVerificationCodeAndShowDialog();
  }

  Future<void> _sendVerificationCodeAndShowDialog() async {
    final localizations = AppLocalizations.of(context)!;
    
    if(!hasConnection(context)) {
      showToast(context: context, message: localizations.checkConnection);
      return;
    }

    // Show loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _authService.requestPhoneVerificationCode(_phoneTFController.text);
      
      if (!mounted) return;
      
      setState(() {
        _isSubmitting = false;
      });
      
      if (response.statusCode == 200) {
        // Success - show verification dialog
        _showVerificationDialog();
      } else {
        showToast(context: context, message: localizations.sendCodeError);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        showToast(context: context, message: localizations.checkConnection);
      }
    }
  }

  Future<void> _submitForm() async {
    final localizations = AppLocalizations.of(context)!;
    
    if(!hasConnection(context)) {
      showToast(context: context, message: localizations.checkConnection);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Log request data
      print('=== DRIVER REGISTRATION REQUEST ===');
      print('Name: ${_nameTFController.text}');
      print('Phone: ${_phoneTFController.text}');
      print('Plate: ${_plateTFController.text}');
      print('Type: ${_selectedTaxi!}');
      print('Seats: ${int.parse(_seatsTFController.text)}');
      print('Has taxi image: ${_taxiImage != null}');
      print('Has face ID image: ${widget.faceIdImage.isNotEmpty}');
      
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
      
      // Log complete server response
      print('=== DRIVER REGISTRATION RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body: ${response.body}');
      print('Response Body Length: ${response.body.length}');
      print('Response Body Type: ${response.body.runtimeType}');
      print('======================================');
      
      // Avoid context's gaps
      if(!context.mounted) return;
      
      // Handle responses (depends on status code)
      // OK
      if(response.statusCode == 200) {
        print('Success: Processing 200 response');
        final json = jsonDecode(response.body);
        print('Parsed JSON: $json');
        final driver = Driver.fromJson(json);
        print('Driver object created: ${driver.name} - ID: ${driver.id}');
        // Save the user's session
        final success = await SessionPrefsManager.instance.save(driver);
        print('Session save success: $success');
        if(success) {
          // Avoid context's gaps
          if(!context.mounted) return;
          // Navigate to home safely
          print('Navigating to driver home');
          context.go(DriverRoutes.home);
        } else {
          print('Failed to save session');
          showToast(context: context, message: localizations.registrationError);
        }
      }
      // CONFLICT
      else if(response.statusCode == 409) {
        print('Conflict: Phone already registered');
        showToast(context: context, message: localizations.phoneAlreadyRegistered);
      }
      // ANY OTHER STATUS CODE
      else {
        print('Error: Unexpected status code ${response.statusCode}');
        showToast(
            context: context,
            message: localizations.registrationError
        );
      }
    } catch (e, stackTrace) {
      // Handle any network or parsing errors
      print('=== DRIVER REGISTRATION ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      print('=================================');
      if(context.mounted) {
        showToast(context: context, message: localizations.registrationError);
      }
    } finally {
      if(mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
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
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Form(
                          key: _formKey,
                          child: Column(children: [
                            // First Card
                            Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(dimensions.borderRadius),

                                ),
                                child: Column(
                                  children: [
                                    Center(
                                        child: Column(
                                          key: _imageKey,
                                          children: [
                                            GestureDetector(
                                                onTap: () async {
                                                  final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                                                  if (pickedImage != null) {
                                                    setState(() => _isProcessingImage = true);
                                                    final compressedImage = await compressXFileToTargetSize(pickedImage, 5);
                                                    setState(() => _isProcessingImage = false);
                                                    if (compressedImage != null) {
                                                      setState(() {
                                                        _taxiImage = compressedImage;
                                                        _showImageError = false; // Clear error when selecting
                                                      });
                                                    }
                                                  }
                                                },
                                                child: _buildCircleImagePicker()
                                            ),
                                            if (_showImageError)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 8.0),
                                                child: Text(
                                                  localizations.requiredField,
                                                  style: textTheme.labelSmall?.copyWith(
                                                    color: colorScheme.error,
                                                  ),
                                                ),
                                              ),
                                          ],
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
                            //               : "Change"
                            //         )
                            //       )
                            //     ]
                            //   )
                            // ),
                            // Vehicle Section
                            Container(
                              key: _vehicleTypeKey,
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              child: Card(
                                color: colorScheme.surfaceContainerLowest,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(dimensions.cardBorderRadiusLarge),
                                ),
                                child: Theme(
                                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.vehicleTypeLabel,
                                              style: textTheme.bodyLarge?.copyWith(color: colorScheme.secondary),
                                            ),
                                            if (_showVehicleTypeError)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 4.0),
                                                child: Text(
                                                  localizations.requiredField,
                                                  style: textTheme.labelSmall?.copyWith(
                                                    color: colorScheme.error,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Column(
                                          children: List.generate(TaxiType.values.length, (index) {
                                            return _buildTaxiCardItem(index);
                                          }),
                                        ),
                                      )
                                    ]
                                  ),
                                ),
                              )
                            ),
                            // Password Section
                            Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                                      _buildPasswordFieldWithDynamicValidation(
                                          controller: _confirmPasswordTFController,
                                          label: localizations.confirmPasswordLabel,
                                          hint: localizations.confirmPasswordHint,
                                          visible: _isConfirmPasswordVisible,
                                          onToggle: (v) => setState(() => _isConfirmPasswordVisible = v),
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return localizations.requiredField;
                                            }
                                            if (value != _passwordTFController.text) {
                                              return localizations.passwordsDoNotMatch;
                                            }
                                            return null;
                                          }
                                      )
                                    ]
                                )
                            )
                          ])
                      )
                  )
              ),
              if(_isProcessingImage)
                Positioned.fill(child: Center(child: CircularProgressIndicator())),
              if(_isSubmitting)
                Positioned.fill(
                  child: Container(
                    color: colorScheme.scrim.withValues(alpha: 0.6),
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                localizations.creatingAccount,
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
            ]),
          ),
            // Submit Button
            SizedBox(
              width: double.infinity,
                height: 56,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius))),
                    onPressed: _isSubmitting ? null : _validateAndSubmit,
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
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyLarge?.copyWith(
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
            hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(dimensions.buttonBorderRadius),
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
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
          onTap: () => setState(() {
            _selectedTaxi = taxi;
            _showVehicleTypeError = false; // Clear error when selecting
          }),
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
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyMedium?.copyWith(
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
            hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
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
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
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

  Widget _buildPasswordFieldWithDynamicValidation({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool visible,
    required Function(bool) onToggle,
    required String? Function(String?) validator,
    int? maxLength,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: textTheme.bodyMedium?.copyWith(
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
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
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
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: colorScheme.outlineVariant,
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
                color: colorScheme.shadow.withValues(alpha: 0.2),
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
        // Camera icon positioned at bottom right
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.15),
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
                  setState(() {
                    _taxiImage = image;
                    _showImageError = false; // Clear error when selecting
                  });
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
                setState(() {
                  _taxiImage = null;
                  _showImageError = false; // Don't show error immediately when removing
                });
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