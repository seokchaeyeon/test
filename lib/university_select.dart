import 'package:flutter/material.dart';
import 'package:hello_world/all.dart';

import '../variables/variables.dart';
import 'login_page.dart';

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
                'assets/img/university_logo/yulogo.png', // 임시 로고
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
  SearchController controller = SearchController();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SearchAnchor(
          searchController: controller,
          viewPadding: EdgeInsets.only(bottom: 160),
          viewConstraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          viewBackgroundColor: Colors.white,
          builder: (context, controller) {
            return SearchBar(
              backgroundColor: WidgetStatePropertyAll(Colors.white),
              onTap: () => controller.openView(),
              onChanged: (_) {
                controller.openView();
              },
              // TODO 호출이 안되는것 같은데 확인필요. 현재 로그인 화면 넘어가는 부분은 onTap에서 처리중
              onSubmitted: (value) {
                if (loginList.containsKey(value)) {
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => LoginPage(universityName: value)
                  ));
                }
              },
              trailing: [
                Icon(Icons.search),
              ],
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8, maxHeight: 400
              ),
              hintText: '기관 검색',
              hintStyle: WidgetStatePropertyAll(
                TextStyle(
                  color: Colors.grey,
                ),
              ),
              textStyle: WidgetStatePropertyAll(
                TextStyle(
                  color: Colors.black,
                ),
              ),
              padding: WidgetStatePropertyAll(
                EdgeInsets.only(top: 10, left: 20, bottom: 10, right: 30),
              ),
              controller: controller,
            );
          },
          suggestionsBuilder: (context, controller) {
            List<String> schoolList = loginList.keys.toList();
            schoolList = schoolList.where(
                    (name) => name.contains(controller.text)
            ).toList();

            return List<ListTile>.generate(schoolList.length, (int index) {
              final String item = schoolList[index];
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() => controller.closeView(item));

                  // 검색결과 목록에서 선택시 바로 로그인 페이지로 가도록 하기
                  // onSubmit 부분이 작동 안하는것 같아 일단 넣었음
                  if (loginList.containsKey(item)) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(universityName: item),
                      ),
                    );
                  }
                },
              );
            });
          },
        )
    );
  }
}