import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_validator/form_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/const/gradient_const.dart';
import 'package:tooGoodToWaste/const/styles.dart';
import 'package:tooGoodToWaste/dto/user_model.dart';
import 'package:tooGoodToWaste/dto/user_name_model.dart';
import 'package:tooGoodToWaste/widgets/appbar.dart';
import 'package:tooGoodToWaste/widgets/signup_arrow_button.dart';
import 'package:tooGoodToWaste/widgets/verifiable_text_field.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

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
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Column(
                children: [
                  Expanded(
                      child: FractionallySizedBox(
                    widthFactor: 1,
                    child: selectedPage == 0
                        ? const LoginPage()
                        : const SignUpPage(),
                  )),
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  Widget headlinesWidget() {
    return Container(
      margin: EdgeInsets.only(left: 48.0, top: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'WELCOME BACK,',
            textAlign: TextAlign.left,
            style: TextStyle(
                letterSpacing: 3,
                fontSize: 20.0,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold),
          ),
          Text(
            'FOOD WARRIOR!',
            textAlign: TextAlign.left,
            style: TextStyle(
                letterSpacing: 3,
                fontSize: 20.0,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold),
          ),
          Container(
            margin: EdgeInsets.only(top: 40.0),
            child: Text(
              'Log in \nto continue.',
              textAlign: TextAlign.left,
              style: TextStyle(
                letterSpacing: 3,
                fontSize: 32.0,
                fontFamily: 'Montserrat',
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget emailTextFieldWidget() {
    return Container(
      margin: EdgeInsets.only(left: 16.0, right: 32.0, top: 32.0),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 15,
                spreadRadius: 0,
                offset: Offset(0.0, 16.0)),
          ],
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
              begin: FractionalOffset(0.0, 0.4),
              end: FractionalOffset(0.9, 0.7),
              // Add one stop for each color. Stops should increase from 0 to 1
              stops: [
                0.2,
                0.9
              ],
              colors: [
                Color(0xffFFC3A0),
                Color(0xffFFAFBD),
              ])),
      child: TextField(
        controller: _emailController,
        onChanged: (input) {
          setState(() {
            _emailErrorMessage = _emailValidator(input);
          });
        },
        style: hintAndValueStyle,
        decoration: InputDecoration(
            suffixIcon:
                Icon(Icons.email_rounded, color: Color(0xff35AA90), size: 20.0),
            contentPadding: EdgeInsets.fromLTRB(40.0, 30.0, 10.0, 10.0),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none),
            hintText: 'Email',
            errorText: _emailErrorMessage,
            hintStyle: hintAndValueStyle),
      ),
    );
  }

  Widget passwordTextFieldWidget() {
    return Container(
      margin: EdgeInsets.only(left: 32.0, right: 16.0),
      child: TextField(
        style: hintAndValueStyle,
        onChanged: (input) {
          setState(() {
            _passwordErrorMessage = _passwordValidator(input);
          });
        },
        controller: _passwordController,
        obscureText: _isPasswordObscured,
        decoration: InputDecoration(
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 30.0),
              child: Icon(Icons.lock_rounded,
                  color: Color(0xff35AA90), size: 20.0),
            ),
            fillColor: Color(0x3305756D),
            filled: true,
            contentPadding: EdgeInsets.fromLTRB(40.0, 30.0, 10.0, 10.0),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none),
            hintText: 'Password',
            errorText: _passwordErrorMessage,
            hintStyle: hintAndValueStyle),
      ),
    );
  }

  Widget loginButtonWidget() {
    return Container(
      margin: EdgeInsets.only(left: 32.0, top: 32.0),
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: () {
              // if (!_formKey.currentState!.validate()) {
              //       return;
              //     }
              FirebaseAuth.instance
                  .signInWithEmailAndPassword(
                      email: _emailController.value.text,
                      password: _passwordController.value.text)
                  .then((user) {
                // On success login
                logger.d('Successfully logged in with ${user.toString()}');
                FirebaseAnalytics.instance
                    .logLogin(loginMethod: "EmailPassword");
              }).catchError((error) {
                logger.e('Cannot sign in with username and password',
                    error: error);
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
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 36.0, vertical: 16.0),
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: Offset(0.0, 32.0)),
                  ],
                  borderRadius: new BorderRadius.circular(36.0),
                  gradient: LinearGradient(
                      begin: FractionalOffset.centerLeft,
// Add one stop for each color. Stops should increase from 0 to 1
                      stops: [
                        0.2,
                        1
                      ],
                      colors: [
                        Color(0xff000000),
                        Color(0xff434343),
                      ])),
              child: Text(
                'LOGIN',
                style: TextStyle(
                    color: Color(0xffF1EA94),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 64.0),
        decoration: BoxDecoration(gradient: SIGNUP_BACKGROUND),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            Center(
              child: Image.asset(
                'assets/images/logo_signup.png',
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
              ),
            ),
            headlinesWidget(),
            emailTextFieldWidget(),
            passwordTextFieldWidget(),
            loginButtonWidget(),
          ],
        ),
      ),
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
  final StreamController<SignUpState> signUpState = StreamController();
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    // Read all values if exists
    secureStorage.read(key: _SIGN_UP_STATE_KEY).then((persistedSignUpState) {
      signUpState.add(persistedSignUpState != null
          ? SignUpState.values.byName(persistedSignUpState)
          : SignUpState.information);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: signUpState.stream,
        builder: (context, snapshot) {
          logger.d('Showing sign up phase: ${snapshot.data}');
          if (snapshot.data == SignUpState.information) {
            return SignUpInformationPage(
              signUpState: signUpState,
            );
          } else if (snapshot.data != null) {
            return const VerifyPhonePage();
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class SignUpInformationPage extends StatefulWidget {
  final StreamController<SignUpState> signUpState;

  const SignUpInformationPage({super.key, required this.signUpState});

  @override
  State<SignUpInformationPage> createState() =>
      _SignUpInformationState(signUpState: signUpState);
}

class _SignUpInformationState extends State<SignUpInformationPage> {
  var logger = Logger();
  final bool _isPasswordObscured = true;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final StreamController<SignUpState> signUpState;

  _SignUpInformationState({required this.signUpState});

  final _requiredValidator = ValidationBuilder().required().build();
  final _phoneValidator = ValidationBuilder().required().phone().build();
  final _emailValidator = ValidationBuilder().required().email().build();
  final _passwordValidator =
      ValidationBuilder().required().minLength(8).build();

  bool allInputsAreValid() {
    return _requiredValidator(_firstNameController.value.text) == null &&
        _requiredValidator(_lastNameController.value.text) == null;
  }

  void _cleanSignUpData() {}

  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

  IOSOptions _getIOSOptions() => const IOSOptions();

  void _putIntoStorage(String key, String value) async {
    await secureStorage.write(
        key: key,
        value: value,
        iOptions: _getIOSOptions(),
        aOptions: _getAndroidOptions());
  }

  int widgetIndex = 0;
  late PageController _pageController;
  bool _isSelected = false;

  _selectType(bool isSelected) {
    setState(() {
      _isSelected = isSelected;
    });
  }

  @override
  void initState() {
    _pageController = PageController();

    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Widget emailTextFieldWidget() {
    return TextField(
      onChanged: (input) {
        _putIntoStorage(_LAST_NAME_KEY, input);
      },
      controller: _emailController,
      decoration: new InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child:
              Icon(Icons.email_rounded, color: Color(0xff35AA90), size: 20.0),
        ),
        hintText: 'Email',
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget passwordTextFieldWidget() {
    return TextField(
      onChanged: (input) {
        _putIntoStorage(_PASSWORD_KEY, input);
      },
      controller: _passwordController,
      decoration: new InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Icon(Icons.lock_rounded, color: Color(0xff35AA90), size: 20.0),
        ),
        hintText: 'Password',
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: InputBorder.none,
      ),
      obscureText: true,
    );
  }

  Widget firstNameTextFieldWidget() {
    return TextField(
      onChanged: (input) {
        _putIntoStorage(_FIRST_NAME_KEY, input);
      },
      controller: _firstNameController,
      decoration: new InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child:
              Icon(Icons.person_rounded, color: Color(0xff35AA90), size: 20.0),
        ),
        hintText: 'First Name',
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget lastNameTextFieldWidget() {
    return TextField(
      onChanged: (input) {
        _putIntoStorage(_LAST_NAME_KEY, input);
      },
      controller: _lastNameController,
      decoration: new InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Icon(Icons.person_search_outlined,
              color: Color(0xff35AA90), size: 20.0),
        ),
        hintText: 'Last Name',
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget phoneNumTextFieldWidget() {
    return TextField(
      onChanged: (input) {
        _putIntoStorage(_PHONE_NUM_KEY, input);
      },
      controller: _phoneController,
      decoration: InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child:
              Icon(Icons.phone_rounded, color: Color(0xff35AA90), size: 20.0),
        ),
        hintText: 'Phone Number',
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget add1TextFieldWidget() {
    return TextField(
      onChanged: (input) {
        _putIntoStorage(_ADDRESS_LINE_1_KEY, input);
        setState(() {
          _addressLine1Controller.text = input;
        });
      },
      controller: _addressLine1Controller,
      decoration: new InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Icon(Icons.streetview_rounded,
              color: Color(0xff35AA90), size: 20.0),
        ),
        hintText: 'Address Line 1',
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget add2TextFieldWidget() {
    return TextField(
      onChanged: (input) {
        _putIntoStorage(_ADDRESS_LINE_2_KEY, input);
      },
      controller: _addressLine2Controller,
      decoration: new InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child:
              Icon(Icons.house_rounded, color: Color(0xff35AA90), size: 20.0),
        ),
        hintText: 'Address Line 2',
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: InputBorder.none,
      ),
      obscureText: true,
    );
  }

  Widget zipTextFieldWidget() {
    return TextField(
      onChanged: (input) {
        _putIntoStorage(_ZIP_CODE_KEY, input);
      },
      controller: _zipCodeController,
      decoration: new InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Icon(Icons.post_add_rounded,
              color: Color(0xff35AA90), size: 20.0),
        ),
        hintText: 'Zip Code',
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget cityTextFieldWidget() {
    return TextField(
      onChanged: (input) {
        _putIntoStorage(_CITY_KEY, input);
      },
      controller: _cityController,
      decoration: new InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Icon(Icons.location_city_rounded,
              color: Color(0xff35AA90), size: 20.0),
        ),
        hintText: 'City',
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: InputBorder.none,
      ),
    );
  }

  Widget countryTextFieldWidget() {
    return TextField(
      onChanged: (input) {
        _putIntoStorage(_COUNTRY_KEY, input);
      },
      controller: _countryController,
      decoration: new InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Icon(Icons.map_rounded, color: Color(0xff35AA90), size: 20.0),
        ),
        hintText: 'Country',
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        border: InputBorder.none,
      ),
    );
  }

  Column PersonalColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Text(
          "Pers. Info",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w400,
            wordSpacing: 2,
            letterSpacing: 2,
          ),
        ),
        firstNameTextFieldWidget(),
        SizedBox(
          height: 1.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        lastNameTextFieldWidget(),
        SizedBox(
          height: 1.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        emailTextFieldWidget(),
        SizedBox(
          height: 1.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        phoneNumTextFieldWidget(),
        SizedBox(
          height: 1.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        passwordTextFieldWidget(),
        SizedBox(
          height: 1.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  Column AddressColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Text(
          "Address",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w400,
            wordSpacing: 2,
            letterSpacing: 2,
          ),
        ),
        // Text(
        //   "Fillin",
        //   style: TextStyle(
        //     fontSize: 35,
        //     fontWeight: FontWeight.w400,
        //     wordSpacing: 2,
        //     letterSpacing: 2,
        //   ),
        // ),
        add1TextFieldWidget(),
        SizedBox(
          height: 1.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        add2TextFieldWidget(),
        SizedBox(
          height: 1.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        zipTextFieldWidget(),
        SizedBox(
          height: 1.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        cityTextFieldWidget(),
        SizedBox(
          height: 1.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        countryTextFieldWidget(),
        SizedBox(
          height: 1.5,
          child: Container(
            color: Colors.black,
          ),
        ),
        // Text(
        //   "NEXT",
        //   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        // ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
      PersonalColumn(),
      AddressColumn(),
    ];

    return Scaffold(
      appBar: SignupApbar(
        title: "SIGNUP",
      ),
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: SIGNUP_BACKGROUND,
            ),
          ),
          SingleChildScrollView(
            child: Container(
              child: Stack(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                            top: 80,
                            left: 70,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      _selectType(false);
                                      _pageController.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: Opacity(
                                      opacity: _isSelected ? 0.5 : 1,
                                      child: Text(
                                        "Pers.",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          wordSpacing: 1.5,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _pageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                      _selectType(true);
                                    },
                                    child: Opacity(
                                      opacity: _isSelected ? 1 : 0.5,
                                      child: Text(
                                        "Address",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.5,
                                          wordSpacing: 1.5,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Column(
                                children: <Widget>[
                                  Container(
                                    height: MediaQuery.of(context).size.height /
                                        1.8,
                                    width: double.infinity,
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                1.8,
                                            width: double.infinity,
                                            padding: EdgeInsets.all(25),
                                            decoration: BoxDecoration(
                                              gradient: SIGNUP_CARD_BACKGROUND,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(
                                                  15,
                                                ),
                                                bottomLeft: Radius.circular(
                                                  15,
                                                ),
                                              ),
                                            ),
                                            child: PageView.builder(
                                              controller: _pageController,
                                              itemBuilder: (context, index) {
                                                return widgets[index];
                                              },
                                              physics: BouncingScrollPhysics(),
                                              itemCount: widgets.length,
                                              scrollDirection: Axis.horizontal,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    margin: EdgeInsets.only(
                                      left: 15,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.white70.withOpacity(0.3),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    margin: EdgeInsets.only(
                                      left: 30,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.white70.withOpacity(0.2),
                                          blurRadius: 2,
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    margin: EdgeInsets.only(
                                      left: 45,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.white54.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: Offset(0, 3),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 35,
                    left: 97,
                    child: SignUpArrowButton(
                      icon: Icons.arrow_forward,
                      iconSize: 20,
                      onTap: () {
                        logger.d('Pressed sign up button');
                        setState(() {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: _emailController.value.text,
                            password: _passwordController.value.text,
                          )
                              .then((cred) {
                            logger.d('Created user with credential $cred');

                            if (cred.user == null) {
                              throw Exception('User UID is null');
                            }

                            TGTWUser user = TGTWUser(
                                name: UserName(
                                    first: _firstNameController.value.text,
                                    last: _lastNameController.value.text),
                                rating: 0,
                                phoneNumber: _phoneController.value.text,
                                address: UserAddress(
                                    line1: _addressLine1Controller.value.text,
                                    line2: _addressLine2Controller.value.text,
                                    zipCode: _zipCodeController.value.text,
                                    city: _cityController.value.text,
                                    country: _countryController.value.text),
                                allergies: const [],
                                goodPoints: 0,
                                reducedCarbonKg: 0.0,
                                points: 1000.00);

                            return FirebaseFirestore.instance
                                .collection('users')
                                .doc(cred.user!.uid)
                                .set(user.toJson());
                          }).then((_) {
                            logger.d(
                                'Successfully created user in database with uid: ${FirebaseAuth.instance.currentUser?.uid}');
                            FirebaseAnalytics.instance
                                .logSignUp(signUpMethod: "EmailPassword");
                          }).catchError((e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${e.message}'),
                              showCloseIcon: true,
                              closeIconColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ));
                          });
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VerifyPhonePage extends StatefulWidget {
  const VerifyPhonePage({super.key});

  @override
  State<VerifyPhonePage> createState() => _VerifyPhoneState();
}

enum PhoneVerificationStatus {
  init,
  codeSent,
  verificationCompleted,
  verificationFailed,
  timeout
}

class _VerifyPhoneState extends State<VerifyPhonePage> {
  String _verificationId = '';
  String? _phoneNumber;
  int? _resendToken;
  PhoneVerificationStatus _verificationStatus = PhoneVerificationStatus.init;
  final TextEditingController _userCodeController = TextEditingController();
  PhoneAuthCredential? _cred;
  final Logger logger = Logger();

  AndroidOptions _getAndroidOptions() =>
      const AndroidOptions(encryptedSharedPreferences: true);

  IOSOptions _getIOSOptions() => const IOSOptions();

  Future<String?> getPhoneNumber() async {
    String? phoneNumber = await secureStorage.read(
        key: _PHONE_NUM_KEY,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions());

    setState(() {
      _phoneNumber = phoneNumber;
    });

    logger.d('Got phone number $phoneNumber');
    return phoneNumber;
  }

  @override
  void initState() {
    super.initState();

    // Populate the phone number
    getPhoneNumber().then((phoneNumber) {
      if (phoneNumber != null) {
        FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: phoneNumber,
            verificationCompleted: (PhoneAuthCredential cred) async {
              logger.d('Logged in user with credential ${cred.toString()}');
              setState(() {
                _verificationStatus =
                    PhoneVerificationStatus.verificationCompleted;
                _cred = cred;
              });
              await FirebaseAuth.instance.signInWithCredential(cred);
            },
            verificationFailed: (FirebaseAuthException e) {
              logger.e('Error on sending verification message', error: e);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${e.message}'),
                showCloseIcon: true,
                closeIconColor: Theme.of(context).colorScheme.inversePrimary,
              ));
              setState(() {
                _verificationStatus =
                    PhoneVerificationStatus.verificationFailed;
              });
            },
            codeSent: (String verificationId, int? resendToken) async {
              _verificationId = verificationId;
              _resendToken = resendToken;
              setState(() {
                _verificationStatus = PhoneVerificationStatus.codeSent;
              });
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              setState(() {
                _verificationStatus = PhoneVerificationStatus.timeout;
                _verificationId = verificationId;
              });
            });
      } else {
        logger.w('Phone number is a null!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Verification',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor),
        ),
        Text(
            'Let us do a small check. Please enter the code we have sent to $_phoneNumber'),
        const SizedBox(
          height: 30,
        ),
        TextField(
            controller: _userCodeController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Code',
            )),
        const SizedBox(
          height: 30,
        ),
        Row(children: [
          IntrinsicWidth(
              child: FilledButton(
            onPressed: () {
              PhoneAuthCredential cred = PhoneAuthProvider.credential(
                  verificationId: _verificationId,
                  smsCode: _userCodeController.value.text);
              FirebaseAuth.instance.signInWithCredential(cred);
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Verify'),
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
