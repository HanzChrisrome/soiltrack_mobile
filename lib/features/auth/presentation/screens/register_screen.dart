import 'package:flutter/services.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart';
import 'package:soiltrack_mobile/core/utils/notifier_helpers.dart';
import 'package:soiltrack_mobile/core/utils/validators.dart';
import 'package:soiltrack_mobile/features/auth/controller/auth_controller.dart';
import 'package:soiltrack_mobile/features/auth/presentation/widgets/custom_dropdown.dart';
import 'package:soiltrack_mobile/widgets/filled_button.dart';
import 'package:soiltrack_mobile/widgets/outline_button.dart';
import 'package:soiltrack_mobile/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soiltrack_mobile/widgets/text_gradient.dart';
import 'package:philippines_rpcmb/philippines_rpcmb.dart' as PhilippinesRPCMB;
import 'package:soiltrack_mobile/features/auth/provider/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController userFname = TextEditingController();
  final TextEditingController userLname = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Region? selectedRegion;
  Province? selectedProvince;
  Municipality? selectedMunicipality;
  String? selectedBarangay;

  List<Region> regions = PhilippinesRPCMB.philippineRegions;
  @override
  void dispose() {
    userFname.dispose();
    userLname.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAuthState = ref.watch(authProvider);
    final userAuthStateNotifier = ref.read(authProvider.notifier);
    final currentStep = userAuthState.currentRegistrationStep;
    final AuthController authController = AuthController(ref, context);

    double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) {
            userAuthStateNotifier.updateCurrentStep(0);
          }
        },
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 0),
              top: keyboardHeight > 0 ? 50 : 40.0,
              bottom: keyboardHeight > 0 ? 280 : 40.0,
              left: 0,
              right: 0,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (keyboardHeight == 0)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 0,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                context.pop();
                              },
                            ),
                          ),
                          Center(
                            child: Image.asset(
                              'assets/logo/DARK HORIZONTAL.png',
                              width: 150,
                            ),
                          ),
                        ],
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          if (currentStep == 0) ...[
                            if (keyboardHeight == 0)
                              _buildStepTitle(
                                  '[ STEP 1 ]', 'Enter your information'),
                            TextFieldWidget(
                              label: 'First Name',
                              controller: userFname,
                              validator: Validators.validateUsername,
                              prefixIcon: Icons.person,
                            ),
                            TextFieldWidget(
                              label: 'Last Name',
                              controller: userLname,
                              validator: Validators.validateUsername,
                              prefixIcon: Icons.person,
                            ),
                          ],
                          if (currentStep == 1) ...[
                            if (keyboardHeight == 0)
                              _buildStepTitle(
                                  '[ STEP 2 ]', 'Enter your address'),
                            _buildCustomRegionDropdown(),
                            _buildCustomProvinceDropdown(),
                            _buildCustomMunicipalityDropdown(),
                            _buildCustomBarangayDropdown(),
                          ],
                          if (currentStep == 2) ...[
                            if (keyboardHeight == 0)
                              _buildStepTitle(
                                  '[ STEP 3 ]', 'Enter your credentials'),
                            TextFieldWidget(
                              label: 'Email',
                              controller: emailController,
                              validator: Validators.validateEmail,
                              prefixIcon: Icons.email,
                            ),
                            TextFieldWidget(
                              label: 'Password',
                              controller: passwordController,
                              isPasswordField: true,
                              validator: Validators.validatePassword,
                              prefixIcon: Icons.lock,
                            ),
                            TextFieldWidget(
                              label: 'Confirm Password',
                              controller: confirmPasswordController,
                              isPasswordField: true,
                              validator: Validators.validatePassword,
                              prefixIcon: Icons.lock,
                            ),
                          ],
                          const SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (currentStep > 0)
                                Expanded(
                                  flex: 1,
                                  child: OutlineCustomButton(
                                    buttonText: 'Back',
                                    onPressed: () {
                                      if (currentStep > 0) {
                                        userAuthStateNotifier
                                            .updateCurrentStep(currentStep - 1);
                                      }
                                    },
                                  ),
                                ),
                              if (currentStep > 0) const SizedBox(width: 5),
                              Expanded(
                                flex: currentStep > 0 ? 2 : 3,
                                child: FilledCustomButton(
                                  buttonText:
                                      currentStep < 2 ? 'Next' : 'Register',
                                  icon: currentStep < 2
                                      ? Icons.arrow_forward
                                      : Icons.check,
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();

                                    if (userAuthState.isRegistering) return;
                                    bool isValid = _validateCurrentStep(
                                        context, currentStep);

                                    if (isValid) {
                                      if (currentStep < 2) {
                                        userAuthStateNotifier
                                            .updateCurrentStep(currentStep + 1);
                                      } else {
                                        authController
                                          ..signUp(
                                            userFname.text,
                                            userLname.text,
                                            emailController.text,
                                            passwordController.text,
                                            selectedMunicipality?.name ?? '',
                                            selectedProvince?.name ?? '',
                                            selectedBarangay ?? '',
                                          );
                                      }
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            if (keyboardHeight == 0)
              Positioned(
                bottom: 30.0,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 350,
                    child: Text(
                      "By creating an account, you agree to our\nterms and conditions",
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomRegionDropdown() {
    return DropdownButtonFormFieldWidget<Region>(
      label: 'Region',
      items: regions,
      selectedValue: selectedRegion,
      onChanged: (Region? region) {
        setState(() {
          selectedRegion = region;
          selectedProvince = null;
          selectedMunicipality = null;
          selectedBarangay = null;
        });
      },
      itemBuilder: (Region region) {
        return Text(region.regionName);
      },
    );
  }

  Widget _buildCustomProvinceDropdown() {
    List<Province> provinceList = selectedRegion?.provinces ?? [];

    return DropdownButtonFormFieldWidget<Province>(
      label: 'Province',
      items: provinceList,
      selectedValue: selectedProvince,
      onChanged: (Province? province) {
        setState(() {
          selectedProvince = province;
          selectedMunicipality = null;
          selectedBarangay = null;
        });
      },
      itemBuilder: (Province province) {
        return Text(province.name);
      },
    );
  }

  Widget _buildCustomMunicipalityDropdown() {
    List<Municipality> municipalityList =
        selectedProvince?.municipalities ?? [];

    return DropdownButtonFormFieldWidget<Municipality>(
      label: 'Municipality',
      items: municipalityList,
      selectedValue: selectedMunicipality,
      onChanged: (Municipality? municipality) {
        setState(() {
          selectedMunicipality = municipality;
          selectedBarangay = null;
        });
      },
      itemBuilder: (Municipality municipality) {
        return Text(municipality.name);
      },
    );
  }

  Widget _buildCustomBarangayDropdown() {
    List<String> barangayList = selectedMunicipality?.barangays ?? [];

    return DropdownButtonFormFieldWidget<String>(
      label: 'Barangay',
      items: barangayList,
      selectedValue: selectedBarangay,
      onChanged: (String? barangay) {
        setState(() {
          selectedBarangay = barangay;
        });
      },
      itemBuilder: (String barangay) {
        return Text(barangay);
      },
    );
  }

  // Helper function to build step titles
  Widget _buildStepTitle(String stepNumber, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        children: [
          Text(
            stepNumber,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 5.0),
          TextGradient(
            text: description,
            fontSize: 52,
            heightSpacing: 0.9,
            letterSpacing: -2.5,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _validateCurrentStep(BuildContext context, int currentStep) {
    if (currentStep == 0) {
      if (userFname.text.isEmpty || userLname.text.isEmpty) {
        vibrateError();
        NotifierHelper.showErrorToast(context, 'All fields are required.');
        return false;
      }
    } else if (currentStep == 1) {
      if (selectedRegion == null ||
          selectedProvince == null ||
          selectedMunicipality == null ||
          selectedBarangay == null) {
        vibrateError();
        NotifierHelper.showErrorToast(context, 'All fields are required.');
        return false;
      }
    } else if (currentStep == 2) {
      vibrateError();
      final emailError = Validators.validateEmail(emailController.text);
      if (emailError != null) {
        NotifierHelper.showErrorToast(context, emailError);
        return false;
      }

      final passwordError =
          Validators.validatePassword(passwordController.text);
      if (passwordError != null) {
        vibrateError();
        NotifierHelper.showErrorToast(context, passwordError);
        return false;
      }

      if (confirmPasswordController.text.isEmpty) {
        vibrateError();
        NotifierHelper.showErrorToast(context, 'Please confirm your password.');
        return false;
      }

      if (passwordController.text != confirmPasswordController.text) {
        vibrateError();
        NotifierHelper.showErrorToast(context, 'Passwords do not match.');
        return false;
      }
    }
    return true;
  }

  void vibrateError() {
    HapticFeedback.heavyImpact();
  }
}
