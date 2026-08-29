import 'package:crame_longexam/widgets/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants.dart';
import '../services/user_service.dart';
import '../widgets/custom_dialogs.dart';
import '../widgets/custom_inkwell_button.dart';

// Enhancement 1: Login screen that authenticates with DummyJSON API
class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  bool _isObscure = true;
  bool _isLoading = false;

  // Enhancement 1: Validates form, calls login API, and navigates to Home on success
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _userService.login(
        usernameController.text,
        passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: user,
      );
    } catch (e) {
      if (!mounted) return;
      customDialog(
        context,
        title: 'Login Failed',
        content: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
          child: SizedBox(
            width: ScreenUtil().screenWidth,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: ScreenUtil().screenWidth,
                    height: ScreenUtil().setHeight(40),
                    color: FB_DARK_PRIMARY,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil().setWidth(25),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/NUCCITLogo_Black.png',
                          height: ScreenUtil().setHeight(180),
                        ),
                        SizedBox(height: ScreenUtil().setHeight(20)),
                        CustomTextFormField(
                          height: ScreenUtil().setHeight(10),
                          width: ScreenUtil().setWidth(10),
                          controller: usernameController,
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Enter your username'
                                  : null,
                          onSaved: (value) {},
                          fontSize: ScreenUtil().setSp(15),
                          fontColor: FB_DARK_PRIMARY,
                          hintTextSize: ScreenUtil().setSp(15),
                          hintText: 'Username',
                        ),
                        SizedBox(height: ScreenUtil().setHeight(10)),

                        // Password field with visibility toggle
                        CustomTextFormField(
                          height: ScreenUtil().setHeight(10),
                          width: ScreenUtil().setWidth(10),
                          controller: passwordController,
                          isObscure: _isObscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: FB_DARK_PRIMARY,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Enter your password'
                                  : null,
                          onSaved: (value) {},
                          fontSize: ScreenUtil().setSp(15),
                          fontColor: FB_DARK_PRIMARY,
                          hintTextSize: ScreenUtil().setSp(15),
                          hintText: 'Password',
                        ),

                        SizedBox(height: ScreenUtil().setHeight(30)),

                        if (_isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: FB_DARK_PRIMARY,
                            ),
                          )
                        else
                          CustomInkwellButton(
                            onTap: _handleLogin,
                            height: ScreenUtil().setHeight(40),
                            width: ScreenUtil().screenWidth,
                            buttonName: 'Login',
                            fontSize: ScreenUtil().setSp(15),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: ScreenUtil().screenWidth,
                    height: ScreenUtil().setHeight(40),
                    color: FB_DARK_PRIMARY,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'You do not have an account? ',
                          style: TextStyle(
                            color: Colors.grey.shade200,
                            fontSize: ScreenUtil().setSp(15),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.popAndPushNamed(
                              context, '/register'),
                          child: Text(
                            'Register here',
                            style: TextStyle(
                              color: FB_LIGHT_PRIMARY,
                              fontSize: ScreenUtil().setSp(15),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}