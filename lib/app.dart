import 'package:flutter/material.dart';
import 'package:kite_group_app/ui/pages/pages.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      routes: {
        SplashPage.id: (context) => SplashPage(),
        HomePage.id: (context) => HomePage(),
        WithoutInternetPage.id: (context) => WithoutInternetPage(),
        WebViewPage.id: (context) => WebViewPage(),
        ProductsPage.id: (context) => ProductsPage(),
      },
      initialRoute: SplashPage.id,
    );
  }
}
