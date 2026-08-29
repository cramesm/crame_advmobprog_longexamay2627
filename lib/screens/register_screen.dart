import 'package:crame_longexam/constants.dart';
import 'package:crame_longexam/widgets/custom_font.dart';
import 'package:crame_longexam/widgets/custom_inkwell_button.dart';
import 'package:crame_longexam/widgets/custom_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/custom_dialogs.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController mobilenumController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isObscure = true;
  bool _isConfirmObscure = true;

  void register() {
    String title = "Registration Failed";
    

    RegExp passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');

    if (firstnameController.text.isEmpty) {
      customDialog(context, title: title, content: "First name is required.");
    } else if (lastnameController.text.isEmpty) {
      customDialog(context, title: title, content: "Last name is required.");
    } else if (mobilenumController.text.length != 11) {
      customDialog(context, title: title, content: "Mobile number must be 11 digits.");
    } else if (passwordController.text.isEmpty) {
      customDialog(context, title: title, content: "Password is required.");
    } else if (!passwordRegex.hasMatch(passwordController.text)) {
      customDialog(
        context, 
        title: title, 
        content: "Password must be at least 8 characters, include uppercase, lowercase, number, and a special character."
      );
    } else if (passwordController.text != confirmpasswordController.text) {
      customDialog(context, title: title, content: "Passwords do not match.");
    } else {
      customDialog(context, title: "Success", content: "Account registered successfully!");
       Future.delayed(const Duration(seconds: 1), () {
         if (!mounted) return;
         Navigator.popAndPushNamed(context, '/login');
       });
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
                SizedBox(height: ScreenUtil().setHeight(25)),
                CustomFont(
                  text: 'Register Here',
                  fontSize: ScreenUtil().setSp(50),
                  fontWeight: FontWeight.bold,
                  color: FB_DARK_PRIMARY,
                ),
                SizedBox(height: ScreenUtil().setHeight(25)),
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
                  maxLength: 11,
                  keyboardType: TextInputType.number,
                  height: ScreenUtil().setHeight(10),
                  width: ScreenUtil().setWidth(10),
                  onSaved: null,
                  fontColor: null,
                  hintText: 'Mobile Num',
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
                    icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
                SizedBox(height: ScreenUtil().setHeight(10)),
                Text(
                  '(Password should be 8 characters, a mixture of letter and numbers consisting of at least one special character with Uppercase and Lowercase letters.)',
                  style: TextStyle(color: Colors.black45, fontSize: ScreenUtil().setSp(10)),
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
                    icon: Icon(_isConfirmObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: () => setState(() => _isConfirmObscure = !_isConfirmObscure),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'You have an account? ',
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
                SizedBox(
                  height: ScreenUtil().setHeight(10),
                ),
                CustomInkwellButton(
                  onTap: () => register(),
                  height: ScreenUtil().setHeight(45),
                  width: ScreenUtil().screenWidth,
                  fontSize: ScreenUtil().setSp(15),
                  fontWeight: FontWeight.bold,
                  buttonName: 'Submit',
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