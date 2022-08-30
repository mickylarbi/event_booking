import 'package:event_booking/screens/auth_screen.dart';
import 'package:event_booking/upload_company_screen/company_list_screen.dart';
import 'package:flutter/material.dart';

class Src extends StatelessWidget {
  const Src({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: AuthWidget(),
      home: CompanyListScreen(),
    );
  }
}
