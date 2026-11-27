// Lab Activity 1 - Ephemeral vs. App State
// Author: Vince Erol P. Pangilinan
//
// This app combines both kinds of state:
//   * Ephemeral state  -> the counter on CounterScreen (setState, lives only
//                         inside that widget's State object).
//   * App state        -> the dark/light theme (ThemeModel + Provider, shared
//                         by the whole app and survives navigating between screens).
//
// Screen 1 (CounterScreen) = counter
// Screen 2 (ThemeToggleScreen) = theme switch

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Entry point of the app.
/// Wraps the whole widget tree in a [ChangeNotifierProvider] so every screen
/// can read and update the same [ThemeModel] (app state).
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeModel(),
      child: const MyApp(),
    ),
  );
}

/// Root widget of the application.
/// Listens to [ThemeModel] and rebuilds the [MaterialApp] whenever the
/// theme changes, so the new theme is applied to every screen at once.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Builds the MaterialApp using the current theme from the provider.
  @override
  Widget build(BuildContext context) {
    // Provider.of listens by default, so MyApp rebuilds on notifyListeners().
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      title: 'State Management Activity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const CounterScreen(),
    );
  }
}

/// APP STATE
/// Holds the theme preference for the entire app.
/// Extends [ChangeNotifier] so widgets that listen to it are rebuilt
/// whenever [toggleTheme] is called.
class ThemeModel with ChangeNotifier {
  // Private field: only ThemeModel can change it.
  bool _isDark = false;

  /// Public read-only getter for the current theme mode.
  bool get isDark => _isDark;

  /// Flips between dark and light mode and notifies all listeners
  /// (MyApp and ThemeToggleScreen) so they rebuild.
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

/// SCREEN 1 - EPHEMERAL STATE
/// A simple counter. The counter value belongs only to this screen,
/// so it is stored in the widget's State and updated with setState().
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  /// Creates the mutable State object that holds the counter.
  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

/// State for [CounterScreen]. `_counter` is ephemeral: it is lost when this
/// State object is disposed (e.g. app restart), and no other widget needs it.
class _CounterScreenState extends State<CounterScreen> {
  int _counter = 0;

  /// Increments the counter and calls setState so only this widget rebuilds.
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  /// Resets the counter back to zero (also ephemeral state).
  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  /// Opens the second screen where the app-wide theme can be toggled.
  void _openThemeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ThemeToggleScreen()),
    );
  }

  /// Builds the counter UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ephemeral State Example'),
        actions: [
          // Shortcut to screen 2 (theme toggle)
          IconButton(
            tooltip: 'Theme settings',
            icon: const Icon(Icons.palette_outlined),
            onPressed: _openThemeScreen,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _resetCounter,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _openThemeScreen,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Go to Theme Screen'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// SCREEN 2 - APP STATE
/// Lets the user switch between light and dark theme.
/// Reads and updates [ThemeModel] through Provider, so the change is
/// visible on every screen (including CounterScreen when you go back).
class ThemeToggleScreen extends StatelessWidget {
  const ThemeToggleScreen({super.key});

  /// Builds the toggle UI and wires the Switch to ThemeModel.toggleTheme().
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('App State Example')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                themeModel.isDark ? Icons.dark_mode : Icons.light_mode,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                themeModel.isDark ? 'Dark mode is ON' : 'Light mode is ON',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Dark mode'),
                subtitle: const Text(
                  'This setting is app state - go back and the counter screen uses it too.',
                ),
                value: themeModel.isDark,
                onChanged: (_) => themeModel.toggleTheme(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
