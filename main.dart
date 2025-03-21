import 'package:database/drawer.dart';
import 'package:database/gaisano_p2.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:database/firebase/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.initNotification();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('shoppingList');
  await Hive.openBox('budgetBox');
  await Hive.openBox('priceBox');
  await Hive.openBox('masterList');
  await Hive.openBox('historyBox');
  await Hive.openBox('productsBox');
  ////// Gaisano
  await Hive.openBox('canned');
  await Hive.openBox('noodles');
  await Hive.openBox('sauce');
  await Hive.openBox('coffee');
  await Hive.openBox('Chocolates');
  await Hive.openBox('biscuit');
  await Hive.openBox('wines');
  await Hive.openBox('diswashing');
  await Hive.openBox('rice');
  await Hive.openBox('meat');
  await Hive.openBox('hair');
  /////Ororama
  await Hive.openBox('canneds');
  await Hive.openBox('noodless');
  await Hive.openBox('sauces');
  await Hive.openBox('coffees');
  await Hive.openBox('Chocolatess');
  await Hive.openBox('biscuits');
  await Hive.openBox('winess');
  await Hive.openBox('diswashings');
  await Hive.openBox('rices');
  await Hive.openBox('meats');
  await Hive.openBox('hairs');
  ///////// ororama
  await Hive.openBox('shoppingL');
  await Hive.openBox('budgetB');
  await Hive.openBox('priceB');
  await Hive.openBox('masterL');
  await Hive.openBox('productB');
  await Hive.openBox('historyB');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopList',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final AudioPlayer _player = AudioPlayer();
  late Box audioBox;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 6,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[50]!, Colors.blue[200]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            "assets/images/shop.gif",
                            width: 400,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 1000))
                      .slideY(
                        begin: 0.5,
                        end: 0.0,
                        duration: const Duration(milliseconds: 1000),
                      ), // Animate top image
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Text(
                      "Welcome to Your Shopping Adventure!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 0.8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 200),
                  ), // Animate welcome text
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/cart.png",
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                  ).animate().scale(
                    duration: const Duration(milliseconds: 800),
                    delay: const Duration(milliseconds: 400),
                  ), // Animate cart image
                  SizedBox(
                        height: 65,
                        width: 200,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                            shadowColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GaisanoP2(),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.arrow_forward,
                                size: 28,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "GET STARTED",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(
                        duration: const Duration(milliseconds: 1000),
                        delay: const Duration(milliseconds: 600),
                      )
                      .then()
                      .shake(
                        duration: const Duration(milliseconds: 500),
                        hz: 2,
                      ), // Animate button with shake
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blue[300]!, width: 1.5),
                    ),
                    child: const Text(
                      "\"The only way to do great work is to love what you do.\" – Steve Jobs",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ).animate().fadeIn(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 800),
                  ), // Animate quote
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
