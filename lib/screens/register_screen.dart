import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../services/user_service.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_font.dart';
import '../widgets/custom_inkwell_button.dart';
import '../widgets/custom_textformfield.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController mobilenumController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;

  Future<void> register() async {
    const String title = "Registration Failed";
    final RegExp passwordRegex =
        RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

    if (firstnameController.text.trim().isEmpty) {
      customDialog(context, title: title, content: "First name is required.");
    } else if (lastnameController.text.trim().isEmpty) {
      customDialog(context, title: title, content: "Last name is required.");
    } else if (usernameController.text.trim().isEmpty) {
      customDialog(context, title: title, content: "Username is required.");
    } else if (mobilenumController.text.trim().length != 11) {
      customDialog(context, title: title, content: "Mobile number must be 11 digits.");
    } else if (passwordController.text.isEmpty) {
      customDialog(context, title: title, content: "Password is required.");
    } else if (!passwordRegex.hasMatch(passwordController.text)) {
      customDialog(
        context,
        title: title,
        content:
            "Password must be at least 8 characters, include uppercase, lowercase, number, and a special character.",
      );
    } else if (passwordController.text != confirmpasswordController.text) {
      customDialog(context, title: title, content: "Passwords do not match.");
    } else {
      setState(() => _isLoading = true);
      try {
        await _userService.registerUser(
          username: usernameController.text.trim(),
          password: passwordController.text,
          firstName: firstnameController.text.trim(),
          lastName: lastnameController.text.trim(),
          mobile: mobilenumController.text.trim(),
        );

        if (!mounted) return;
        customDialog(
          context,
          title: "Success",
          content: "Account registered successfully! You can now log in with your credentials.",
        );

        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!mounted) return;
          Navigator.popAndPushNamed(context, '/login');
        });
      } catch (e) {
        if (!mounted) return;
        customDialog(context, title: title, content: "Failed to register account: $e");
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: ScreenUtil().screenHeight,
          ),
          child: Container(
            width: ScreenUtil().screenWidth,
            padding: EdgeInsets.fromLTRB(
              ScreenUtil().setWidth(25),
              ScreenUtil().setHeight(40),
              ScreenUtil().setWidth(25),
              ScreenUtil().setHeight(10),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: ScreenUtil().setHeight(15)),
                  CustomFont(
                    text: 'Register Here',
                    fontSize: ScreenUtil().setSp(40),
                    fontWeight: FontWeight.bold,
                    color: FB_DARK_PRIMARY,
                  ),
                  SizedBox(height: ScreenUtil().setHeight(20)),
                  CustomTextFormField(
                    height: ScreenUtil().setHeight(10),
                    width: ScreenUtil().setWidth(10),
                    onSaved: null,
                    fontColor: null,
                    hintText: 'First name',
                    validator: (value) => null,
                    hintTextSize: ScreenUtil().setSp(15),
                    fontSize: ScreenUtil().setSp(15),
                    controller: firstnameController,
                  ),
                  SizedBox(height: ScreenUtil().setHeight(10)),
                  CustomTextFormField(
                    height: ScreenUtil().setHeight(10),
                    width: ScreenUtil().setWidth(10),
                    onSaved: null,
                    fontColor: null,
                    hintText: 'Last name',
                    validator: (value) => null,
                    hintTextSize: ScreenUtil().setSp(15),
                    fontSize: ScreenUtil().setSp(15),
                    controller: lastnameController,
                  ),
                  SizedBox(height: ScreenUtil().setHeight(10)),
                  CustomTextFormField(
                    height: ScreenUtil().setHeight(10),
                    width: ScreenUtil().setWidth(10),
                    onSaved: null,
                    fontColor: null,
                    hintText: 'Username',
                    validator: (value) => null,
                    hintTextSize: ScreenUtil().setSp(15),
                    fontSize: ScreenUtil().setSp(15),
                    controller: usernameController,
                  ),
                  SizedBox(height: ScreenUtil().setHeight(10)),
                  CustomTextFormField(
                    maxLength: 11,
                    keyboardType: TextInputType.number,
                    height: ScreenUtil().setHeight(10),
                    width: ScreenUtil().setWidth(10),
                    onSaved: null,
                    fontColor: null,
                    hintText: 'Mobile Num (11 digits)',
                    validator: (value) => null,
                    hintTextSize: ScreenUtil().setSp(15),
                    fontSize: ScreenUtil().setSp(15),
                    controller: mobilenumController,
                  ),
                  SizedBox(height: ScreenUtil().setHeight(10)),
                  CustomTextFormField(
                    isObscure: _isObscure,
                    height: ScreenUtil().setHeight(10),
                    width: ScreenUtil().setWidth(10),
                    onSaved: null,
                    fontColor: null,
                    hintText: 'Password',
                    validator: (value) => null,
                    hintTextSize: ScreenUtil().setSp(15),
                    fontSize: ScreenUtil().setSp(15),
                    controller: passwordController,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(6)),
                  Text(
                    '(Password should be 8+ chars, with uppercase, lowercase, number, and special character.)',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: ScreenUtil().setSp(10),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(10)),
                  CustomTextFormField(
                    isObscure: _isConfirmObscure,
                    hintText: 'Confirm Password',
                    height: ScreenUtil().setHeight(10),
                    width: ScreenUtil().setWidth(10),
                    onSaved: null,
                    fontColor: null,
                    validator: (value) => null,
                    hintTextSize: ScreenUtil().setSp(15),
                    fontSize: ScreenUtil().setSp(15),
                    controller: confirmpasswordController,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () =>
                          setState(() => _isConfirmObscure = !_isConfirmObscure),
                    ),
                  ),
                  SizedBox(height: ScreenUtil().setHeight(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: ScreenUtil().setSp(15),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.popAndPushNamed(context, '/login'),
                        child: Text(
                          'Login here',
                          style: TextStyle(
                            color: FB_DARK_PRIMARY,
                            fontSize: ScreenUtil().setSp(15),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setHeight(15)),
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(color: FB_DARK_PRIMARY),
                    )
                  else
                    CustomInkwellButton(
                      onTap: register,
                      height: ScreenUtil().setHeight(45),
                      width: ScreenUtil().screenWidth,
                      fontSize: ScreenUtil().setSp(15),
                      fontWeight: FontWeight.bold,
                      buttonName: 'Submit',
                    ),
                  SizedBox(height: ScreenUtil().setHeight(15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}