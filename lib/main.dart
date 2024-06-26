import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:food_recipe_final/core/app_pages.dart';
import 'package:food_recipe_final/core/app_theme.dart';
import 'package:food_recipe_final/firebase_options.dart';
import 'package:food_recipe_final/localization/localization.dart';
import 'package:food_recipe_final/src/features/bookmark_recipe/repository/bookmark_interface.dart';
import 'package:food_recipe_final/src/models/shopping_item.dart';
import 'package:food_recipe_final/src/navigation/route_generator.dart';
import 'package:food_recipe_final/src/providers/auth_provider.dart';
import 'package:food_recipe_final/src/providers/bookmark_provider.dart';
import 'package:food_recipe_final/src/providers/message_provider.dart';
import 'package:food_recipe_final/src/providers/recipe_post_provider.dart';
import 'package:food_recipe_final/src/providers/settings_provider.dart';
import 'package:food_recipe_final/src/providers/shopping_provider.dart';
import 'package:food_recipe_final/src/features/splash/screens/splash_screen.dart';
import 'package:food_recipe_final/src/providers/user_image_provider.dart';
import 'package:food_recipe_final/src/providers/user_provider.dart';
import 'package:get/route_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Box? onboardingBox;
void main() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Hive.initFlutter();
  Hive.registerAdapter(ShoppingItemAdapter());
  await Hive.openBox<ShoppingItem>('shoppingItems');
  onboardingBox = await Hive.openBox('onboarding');
  // SystemChrome.setSystemUIOverlayStyle(
  // const SystemUiOverlayStyle(
  //   systemNavigationBarColor: kBlackColor2,
  // ),
  // );
  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BookmarkInterface>(
          create: (context) => BookmarkProvider(),
        ),
        ChangeNotifierProvider<MessageProvider>(
          lazy: false,
          create: (context) => MessageProvider(
            FirebaseFirestore.instance,
            firebase.FirebaseAuth.instance,
          ),
        ),
        ChangeNotifierProvider<UserProvider>(
          lazy: false,
          create: (context) => UserProvider(
            FirebaseFirestore.instance,
            firebase.FirebaseAuth.instance,
          ),
        ),
        ChangeNotifierProvider<UserImageProvider>(
          create: (context) => UserImageProvider(
            firebase.FirebaseAuth.instance,
            FirebaseStorage.instance,
          ),
        ),
        ChangeNotifierProvider<RecipePostProvider>(
          lazy: false,
          create: (context) => RecipePostProvider(
            FirebaseFirestore.instance,
          ),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => ShoppingProvider(),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => AuthProvider(
            firebase.FirebaseAuth.instance,
            FirebaseFirestore.instance,
          ),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => SettingsProvider(),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsManager, _) {
          ThemeData theme;
          if (settingsManager.darkMode) {
            theme = AppTheme.dark();
          } else {
            theme = AppTheme.light();
          }
          return GetMaterialApp(
            supportedLocales: Localization.all,
            debugShowCheckedModeBanner: false,
            theme: theme,
            initialRoute: AppPages.splashPath,
            onGenerateRoute: RouteGenerator.generateRoute,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
