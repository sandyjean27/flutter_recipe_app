import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/recipe_service.dart';
import 'services/auth_service.dart';
import 'services/favorites_service.dart';
import 'services/theme_service.dart';
import 'pages/login_page.dart';
import 'pages/recipe_list_page.dart';
import 'pages/favorites_page.dart';
import 'pages/profile_page.dart';
import 'pages/add_recipe_page.dart';
import 'models/recipe.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    if (!kIsWeb) {
      // Initialize path provider only for mobile platforms
      final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path);
    } else {
      // For web, initialize Hive without a specific path
      await Hive.initFlutter();
    }
    
    // Register Hive Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RecipeAdapter());
    }
    
    // Initialize Services
    final authService = AuthService();
    final recipeService = RecipeService();
    final favoritesService = FavoritesService();
    final themeService = ThemeService();
    
    await authService.init();
    await recipeService.init();
    await favoritesService.init();
    await themeService.init();
    
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => themeService),
        ],
        child: MyApp(
          authService: authService,
          recipeService: recipeService,
          favoritesService: favoritesService,
        ),
      ),
    );
  } catch (e) {
    debugPrint('Error initializing app: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final RecipeService recipeService;
  final FavoritesService favoritesService;

  const MyApp({
    super.key,
    required this.authService,
    required this.recipeService,
    required this.favoritesService,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    final playfairDisplay = GoogleFonts.playfairDisplay();
    final playfairDisplayBold = GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold);

    // Light theme colors
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF5722),
      primary: const Color(0xFFFF5722),
      secondary: const Color(0xFF4CAF50),
      tertiary: const Color(0xFFFFA726),
      background: const Color(0xFFFAFAFA),
      surface: Colors.white,
    );

    // Dark theme colors
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF5722),
      brightness: Brightness.dark,
      primary: const Color(0xFFFF7043),
      secondary: const Color(0xFF66BB6A),
      tertiary: const Color(0xFFFFB74D),
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      onBackground: Colors.white,
      onSurface: Colors.white,
    );

    return MaterialApp(
      title: 'Recipe App',
      debugShowCheckedModeBanner: false,
      themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFFFF5722),
          titleTextStyle: playfairDisplayBold.copyWith(
            fontSize: 24,
            color: const Color(0xFFFF5722),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: playfairDisplayBold,
          headlineMedium: playfairDisplayBold,
          titleLarge: playfairDisplayBold,
          bodyLarge: playfairDisplay,
          bodyMedium: playfairDisplay,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFFF5722), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5722),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey.shade100,
          selectedColor: const Color(0xFFFF5722),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide.none,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFFF5722),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF5722),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: const Color(0xFFFF7043),
          titleTextStyle: playfairDisplayBold.copyWith(
            fontSize: 24,
            color: const Color(0xFFFF7043),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: playfairDisplayBold.copyWith(color: Colors.white),
          headlineMedium: playfairDisplayBold.copyWith(color: Colors.white),
          titleLarge: playfairDisplayBold.copyWith(color: Colors.white),
          bodyLarge: playfairDisplay.copyWith(color: Colors.white),
          bodyMedium: playfairDisplay.copyWith(color: Colors.white),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          color: const Color(0xFF2C2C2C),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF3C3C3C)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFFFF7043), width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7043),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
          ),
        ),
        chipTheme: const ChipThemeData(
          backgroundColor: Color(0xFF2C2C2C),
          selectedColor: Color(0xFFFF7043),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          side: BorderSide.none,
          labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Color(0xFFFF7043),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF7043),
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: authService.isLoggedIn() 
        ? HomePage(
            authService: authService,
            recipeService: recipeService,
            favoritesService: favoritesService,
            onThemeToggle: themeService.toggleTheme,
            isDarkMode: themeService.isDarkMode,
          )
        : LoginPage(
            authService: authService,
            recipeService: recipeService,
            favoritesService: favoritesService,
          ),
    );
  }
}

class HomePage extends StatefulWidget {
  final AuthService authService;
  final RecipeService recipeService;
  final FavoritesService favoritesService;
  final Function(bool) onThemeToggle;
  final bool isDarkMode;

  const HomePage({
    super.key,
    required this.authService,
    required this.recipeService,
    required this.favoritesService,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _recipeListKey = GlobalKey<RecipeListPageState>();
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      RecipeListPage(
        key: _recipeListKey,
        recipeService: widget.recipeService,
        authService: widget.authService,
        favoritesService: widget.favoritesService,
      ),
      FavoritesPage(
        recipeService: widget.recipeService,
        authService: widget.authService,
        favoritesService: widget.favoritesService,
      ),
      ProfilePage(
        authService: widget.authService,
        recipeService: widget.recipeService,
        favoritesService: widget.favoritesService,
      ),
    ];
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await widget.recipeService.init();
    await widget.authService.init();
    await widget.favoritesService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? 'Cookbook' :
          _selectedIndex == 1 ? 'Favorites' : 'Chef Profile',
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.onThemeToggle(!widget.isDarkMode),
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              activeIcon: Icon(Icons.menu_book_rounded, size: 28),
              label: 'Cookbook',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite, size: 28),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, size: 28),
              label: 'Chef Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_recipe_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecipePage(
                recipeService: widget.recipeService,
                authService: widget.authService,
              ),
            ),
          ).then((_) {
            if (_selectedIndex == 0) {
              _recipeListKey.currentState?.refreshRecipes();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('New Recipe'),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Update the DetailScreen to handle local images
class DetailScreen extends StatelessWidget {
  final String imagePath;

  const DetailScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Detail'),
      ),
      body: Center(
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Center(
                child: Text('Error loading image'),
              ),
            );
          },
        ),
      ),
    );
  }
}
