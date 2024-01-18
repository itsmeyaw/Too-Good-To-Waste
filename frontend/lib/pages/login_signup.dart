import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_validator/form_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// Constants
const String _SIGN_UP_STATE_KEY = 'SIGN_UP_STEP';
const String _FIRST_NAME_KEY = 'SIGN_UP_FIRST_NAME';
const String _LAST_NAME_KEY = 'SIGN_UP_LAST_NAME';
const String _PHONE_NUM_KEY = 'SIGN_UP_PHONE_NUM';
const String _PASSWORD_KEY = 'SIGN_UP_PASSWORD';
const String _ADDRESS_LINE_1_KEY = 'SIGN_UP_ADDRESS_1';
const String _ADDRESS_LINE_2_KEY = 'SIGN_UP_ADDRESS_2';
const String _ZIP_CODE_KEY = 'SIGN_UP_ZIP_CODE';
const String _CITY_KEY = 'SIGN_UP_CITY';
const String _COUNTRY_KEY = 'SIGN_UP_COUNTRY';

const FlutterSecureStorage secureStorage = FlutterSecureStorage();

class LoginSignUpPage extends StatefulWidget {
  const LoginSignUpPage({super.key});

  @override
  State<LoginSignUpPage> createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUpPage> {
  int selectedPage = 0;
  var logger = Logger();

  Widget signUpText() {
    return RichText(
        text: TextSpan(
            text: 'Not a food warrior yet? ',
            style: Theme.of(context).textTheme.bodySmall,
            children: <TextSpan>[
          TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    selectedPage = 1;
                  });
                },
              style: TextStyle(color: Theme.of(context).primaryColor),
              text: 'Become one by signing up!')
        ]));
  }

  Widget logInText() {
    return RichText(
        text: TextSpan(
            text: 'Already a food warrior? ',
            style: Theme.of(context).textTheme.bodySmall,
            children: <TextSpan>[
          TextSpan(
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  setState(() {
                    selectedPage = 0;
                  });
                },
              style: TextStyle(color: Theme.of(context).primaryColor),
              text: 'Let\'s go to log in!')
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
          child: Container(
              margin: const EdgeInsets.fromLTRB(50, 0, 50, 0),
              child: Column(
                children: [
                  Expanded(
                    child: selectedPage == 0
                        ? const LoginPage()
                        : const SignUpPage(),
                  ),
                  SizedBox(
                      height: 50,
                      child: Center(
                        child: selectedPage == 0 ? signUpText() : logInText(),
                      ))
                ],
              ))),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var logger = Logger();
  bool _isPasswordObscured = true;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;

  final _emailValidator = ValidationBuilder().required().email().build();
  final _passwordValidator = ValidationBuilder().required().build();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Login',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor),
        ),
        const Text('Welcome back, food warrior!'),
        const SizedBox(
          height: 30,
        ),
        TextField(
          onChanged: (input) {
            setState(() {
              _emailErrorMessage = _emailValidator(input);
            });
          },
          controller: _emailController,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'E-Mail Address',
            errorText: _emailErrorMessage,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          onChanged: (input) {
            setState(() {
              _passwordErrorMessage = _passwordValidator(input);
            });
          },
          controller: _passwordController,
          obscureText: _isPasswordObscured,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Password',
              errorText: _passwordErrorMessage,
              suffixIcon: IconButton(
                icon: _isPasswordObscured
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              )),
        ),
        const SizedBox(
          height: 20,
        ),
        IntrinsicWidth(
            child: FilledButton(
          onPressed: () {
            if (_emailErrorMessage != null) {
              return;
            }
            if (_passwordErrorMessage != null) {
              return;
            }

            FirebaseAuth.instance
                .signInWithEmailAndPassword(
                    email: _emailController.value.text,
                    password: _passwordController.value.text)
                .then((user) {
              // On success login
              logger.d('Successfully logged in with ${user.toString()}');
            }).catchError((error) {
              logger.e('Error with object $error');
              String errorMessage = 'Unknown error occurred ${error.code}';
              if (error.message != null) {
                errorMessage = '${error.message}';
              }
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(errorMessage),
                showCloseIcon: true,
                closeIconColor: Theme.of(context).colorScheme.inversePrimary,
              ));
            });
          },
          child: const Row(
            children: [
              Text('Log In'),
              SizedBox(
                width: 10,
              ),
              Icon(Icons.arrow_right_alt)
            ],
          ),
        ))
      ],
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

enum SignUpState {
  information, // User filling information
  phoneVerification, // User verifies their phone number
}

class _SignUpPageState extends State<SignUpPage> {
  SignUpState signUpState = SignUpState.information;

  @override
  void initState() {
    super.initState();
    // Read all values if exists
    secureStorage.read(key: _SIGN_UP_STATE_KEY).then((persistedSignUpState) {
      setState(() {
        signUpState = persistedSignUpState != null
            ? SignUpState.values.byName(persistedSignUpState)
            : SignUpState.information;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (signUpState == SignUpState.information) {
      return const SignUpInformationPage();
    } else {
      return const VerifyPhonePage();
    }
  }
}

class SignUpInformationPage extends StatefulWidget {
  const SignUpInformationPage({super.key});

  @override
  State<SignUpInformationPage> createState() => _SignUpInformationState();
}

class _SignUpInformationState extends State<SignUpInformationPage> {
  var logger = Logger();
  bool _isPasswordObscured = true;
  SignUpState signUpState = SignUpState.information;
  String? _firstNameErrorMessage;
  String? _lastNameErrorMessage;
  String? _phoneNumErrorMessage;
  String? _passwordErrorMessage;
  String? _addressLine1ErrorMessage;
  String? _zipCodeErrorMessage;
  String? _cityErrorMessage;
  String? _countryErrorMessage;

  final requiredValidator = ValidationBuilder().required().build();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _cleanSignUpData() {}

  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

  IOSOptions _getIOSOptions() => const IOSOptions();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(
          height: 30,
        ),
        Text(
          'Sign Up',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor),
        ),
        const Text('Ready to be a food warrior?'),
        const SizedBox(
          height: 30,
        ),
        Text(
          'Personal Information',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          onChanged: (input) {
            secureStorage.write(key: _FIRST_NAME_KEY, value: input);
            setState(() {
              _firstNameErrorMessage = requiredValidator(input);
            });
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'First Name',
              errorText: _firstNameErrorMessage),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          onChanged: (input) {
            secureStorage.write(key: _LAST_NAME_KEY, value: input);
            setState(() {
              _lastNameErrorMessage = requiredValidator(input);
            });
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Last Name',
              errorText: _lastNameErrorMessage),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          onChanged: (input) {
            secureStorage.write(key: _PHONE_NUM_KEY, value: input);
            setState(() {
              _phoneNumErrorMessage = requiredValidator(input);
            });
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Phone Number',
              errorText: _phoneNumErrorMessage),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          onChanged: (input) {
            secureStorage.write(key: _PASSWORD_KEY, value: input);
            setState(() {
              _passwordErrorMessage = requiredValidator(input);
            });
          },
          obscureText: _isPasswordObscured,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Password',
              errorText: _passwordErrorMessage,
              suffixIcon: IconButton(
                icon: _isPasswordObscured
                    ? const Icon(Icons.visibility)
                    : const Icon(Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _isPasswordObscured = !_isPasswordObscured;
                  });
                },
              )),
        ),
        const SizedBox(
          height: 30,
        ),
        Text(
          'Address',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          onChanged: (input) {
            secureStorage.write(key: _ADDRESS_LINE_1_KEY, value: input);
            setState(() {
              _addressLine1ErrorMessage = requiredValidator(input);
            });
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Address Line 1',
              errorText: _addressLine1ErrorMessage),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          onChanged: (input) {
            secureStorage.write(key: _ADDRESS_LINE_2_KEY, value: input);
          },
          decoration: const InputDecoration(
              border: OutlineInputBorder(), labelText: 'Address Line 2'),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          onChanged: (input) {
            secureStorage.write(key: _ZIP_CODE_KEY, value: input);
            setState(() {
              _zipCodeErrorMessage = requiredValidator(input);
            });
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Zip Code',
              errorText: _zipCodeErrorMessage),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          onChanged: (input) {
            secureStorage.write(key: _CITY_KEY, value: input);
            setState(() {
              _cityErrorMessage = requiredValidator(input);
            });
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'City',
              errorText: _cityErrorMessage),
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          onChanged: (input) {
            secureStorage.write(key: _COUNTRY_KEY, value: input);
            setState(() {
              _countryErrorMessage = requiredValidator(input);
            });
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Country',
              errorText: _countryErrorMessage),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(children: [
          IntrinsicWidth(
              child: FilledButton(
            onPressed: () {
              logger.d('Pressed sign up button');
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Sign Up'),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.arrow_right_alt)
              ],
            ),
          ))
        ])
      ],
    );
  }
}

class VerifyPhonePage extends StatefulWidget {
  const VerifyPhonePage({super.key});

  @override
  State<VerifyPhonePage> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhonePage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
