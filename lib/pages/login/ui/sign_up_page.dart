import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../style/theme.dart' as theme;

/// 注册界面
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 23),
        child: Stack(
          alignment: Alignment.topCenter,
          //overflow: Overflow.visible,
          children: <Widget>[
            Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  color: Colors.white,),
                width: 300,
                height: 360,
                child: buildSignUpTextForm()
            ),

            Positioned(top: 340,child: Center(child:
            Container(
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 42, right: 42),
              decoration: const BoxDecoration(
                gradient: theme.Theme.primaryGradient,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: const Text("SignUp",
                style: TextStyle(fontSize: 25, color: Colors.white),),
            ),),)

          ],
        )
    );
  }

  Widget buildSignUpTextForm() {
    return Form(child: Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        //用户名字
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 25, right: 25, top: 20, bottom: 20),
            child: TextFormField(
              decoration: const InputDecoration(
                  icon: Icon(FontAwesomeIcons.user, color: Colors.black,),
                  hintText: "Name",
                  border: InputBorder.none
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
        Container(
          height: 1,
          width: 250,
          color: Colors.grey[400],
        ),
        //邮箱
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 25, right: 25, top: 20, bottom: 20),
            child: TextFormField(
              decoration: const InputDecoration(
                  icon: Icon(Icons.email, color: Colors.black,),
                  hintText: "Email Address",
                  border: InputBorder.none
              ),
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
        Container(
          height: 1,
          width: 250,
          color: Colors.grey[400],
        ),
        //密码
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 25, right: 25, top: 20, bottom: 20),
            child: TextFormField(
              decoration: InputDecoration(
                icon: const Icon(Icons.lock, color: Colors.black,),
                hintText: "Password",
                border: InputBorder.none,
                suffixIcon: IconButton(
                    icon: const Icon(Icons.remove_red_eye, color: Colors.black,),
                    onPressed: () {}),
              ),
              obscureText: true,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),
        Container(
          height: 1,
          width: 250,
          color: Colors.grey[400],
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 25, right: 25, top: 20, bottom: 20),
            child: TextFormField(
              decoration: InputDecoration(
                icon: const Icon(Icons.lock, color: Colors.black,),
                hintText: "Confirm Passowrd",
                border: InputBorder.none,
                suffixIcon: IconButton(
                    icon: const Icon(Icons.remove_red_eye, color: Colors.black,),
                    onPressed: () {}),
              ),
              obscureText: true,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ),

      ],
    ));
  }

}