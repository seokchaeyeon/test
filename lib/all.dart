import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 예시 loginList와 로그인 응답 클래스 및 API 요청 함수
Map<String, Map<String, String>> loginList = {
  "Example University": {
    "logo": "assets/img/university_logo/yulogo.png"
  }
};

class AccountLoginResponse {
  final int apiCode;
  final String? token;
  final String? studentNumber;
  final String? name;
  final String? department;
  final String msg;

  AccountLoginResponse({
    required this.apiCode,
    this.token,
    this.studentNumber,
    this.name,
    this.department,
    required this.msg,
  });
}

Future<AccountLoginResponse> apiAccountLogin(String id, String pw) async {
  // 예시 응답
  if (id == "test" && pw == "1234") {
    return AccountLoginResponse(
      apiCode: 0,
      token: "exampleToken",
      studentNumber: "20250001",
      name: "홍길동",
      department: "컴퓨터공학과",
      msg: "로그인 성공",
    );
  } else {
    return AccountLoginResponse(
      apiCode: 1,
      msg: "ID 또는 비밀번호가 잘못되었습니다.",
    );
  }
}

const BACKGROUND_COLOR = Color(0xffE6ECF5);

void main() {
  runApp(MaterialApp(home: UniversitySelectPage()));
}

class UniversitySelectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BACKGROUND_COLOR,
      body: SafeArea(
        child: Column(
          children: [
            Center(),
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.15),
              child: MainTitle(),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: MainSearch(),
            ),
            Container(
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
              height: MediaQuery.of(context).size.height * 0.3,
              child: Image.asset(
                'assets/img/university_logo/yulogo.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Neo Click',
      style: TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class MainSearch extends StatefulWidget {
  const MainSearch({super.key});

  @override
  State<MainSearch> createState() => _MainSearchState();
}

class _MainSearchState extends State<MainSearch> {
  String? inputText;
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: '기관 검색',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (value) {
                if (loginList.containsKey(value)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(universityName: value),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final String universityName;

  LoginPage({super.key, required this.universityName});

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? idPw = loginList[universityName];

    return Scaffold(
      appBar: AppBar(
        title: Text(universityName),
        backgroundColor: BACKGROUND_COLOR,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: BACKGROUND_COLOR,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.22,
                margin: EdgeInsets.only(top: 30, bottom: 40),
                child: Image.asset(
                  '${idPw?['logo']}',
                  fit: BoxFit.contain,
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                width: MediaQuery.of(context).size.width * 0.8,
                margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.1),
                padding: EdgeInsets.only(top: 25),
                decoration: BoxDecoration(
                  color: Color(0xff86A6DE),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: LogIn(universityName: universityName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class inputAnyThing extends StatelessWidget {
  final TextEditingController controller;
  final String name;
  final bool obscureText;

  inputAnyThing({required this.controller, required this.name, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value!.isEmpty) {
          return '$name를 입력하세요';
        } else {
          return null;
        }
      },
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
        fillColor: Colors.grey[80],
        filled: true,
        label: Text(name),
        hintText: name,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(40.0)),
        ),
      ),
      obscureText: this.obscureText,
    );
  }
}

class LogIn extends StatefulWidget {
  final String universityName;

  LogIn({required this.universityName});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double textFormWidth = MediaQuery.of(context).size.width * 0.70;

    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: textFormWidth,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(top: 10, bottom: 10),
                child: inputAnyThing(controller: _idController, name: 'id'),
              ),
              Container(
                width: textFormWidth,
                padding: EdgeInsets.all(5),
                margin: EdgeInsets.only(bottom: 10),
                child: inputAnyThing(controller: _pwController, name: 'pw', obscureText: true),
              ),
              Container(
                margin: EdgeInsets.only(top: 25),
                width: MediaQuery.of(context).size.width * 0.5,
                height: 54,
                child: ElevatedButton(
                  onPressed: () async {
                    final formKeyState = _formKey.currentState!;
                    if (formKeyState.validate()) {
                      AccountLoginResponse response = await apiAccountLogin(_idController.text, _pwController.text);

                      if (response.apiCode == 0) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString("login_token", response.token!);
                        await prefs.setString("student_number", response.studentNumber!);
                        await prefs.setString("name", response.name!);
                        await prefs.setString("department", response.department!);

                        Navigator.push(context, MaterialPageRoute(builder: (context) => UniversitySelectPage()));
                      } else {
                        LoginErrorDialog("오류 코드: \${response.apiCode}\n\${response.msg}");
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff324F7B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  child: const Text('Log In', style: TextStyle(fontSize: 35, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void LoginErrorDialog(String err_msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Column(children: <Widget>[Text("로그인 오류!")]),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[Text(err_msg)],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
