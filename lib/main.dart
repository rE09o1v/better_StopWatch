import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/shared/constants/app_colors.dart';
import 'src/shared/constants/app_constants.dart';
import 'src/shared/services/storage_service.dart';
import 'src/features/timer/timer_screen.dart';
import 'src/features/records/record_input_screen.dart';
import 'src/features/records/records_list_screen.dart';
import 'src/features/statistics/statistics_screen.dart';
import 'src/shared/providers/timer_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ストレージサービスを初期化
  await StorageService.instance.initialize();
  
  runApp(
    const ProviderScope(
      child: StopwatchApp(),
    ),
  );
}

class StopwatchApp extends StatelessWidget {
  const StopwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primaryBlue,
        scaffoldBackgroundColor: AppColors.backgroundWhite,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.backgroundWhite,
          foregroundColor: AppColors.primaryBlue,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TimerScreen(),
    const RecordsListScreen(),
    const StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textGray,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'タイマー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: '記録一覧',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '統計',
          ),
        ],
      ),
      floatingActionButton: timerState.canSaveRecord
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RecordInputScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.save),
              label: const Text('記録を保存'),
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
