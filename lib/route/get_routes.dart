import 'package:chatting_example/binding/binding.dart';
import 'package:chatting_example/route/route_const.dart';
import 'package:chatting_example/screen/auth/signin_screen.dart';
import 'package:chatting_example/screen/auth/signup_screen.dart';
import 'package:chatting_example/screen/chat/chat_screen.dart';
import 'package:chatting_example/screen/home_screen.dart';
import 'package:chatting_example/screen/chat/searching_page.dart';
import 'package:chatting_example/screen/splash/splash_screen.dart';
import 'package:get/get.dart';

class GetRoutes {
  static final pages = [
    GetPage(name: RouteName.Initial, page: () => SplashScreen()),
    GetPage(
        name: RouteName.Home, page: () => HomeScreen(), binding: HomeBinding()),
    GetPage(
        name: RouteName.Chat,
        page: () => ChattingScreen(),
        binding: ChatBinding()),
    GetPage(
        name: RouteName.SignIn,
        page: () => SignInScreen(),
        binding: AuthBinding()),
    GetPage(name: RouteName.SignUp, page: () => SignUpScreen()),
    GetPage(name: RouteName.UserSearching, page: () => UserSearchingPage())
  ];
}
