# pangilinan_advmobprogAY2627

Advanced Mobile Programming laboratory activities — Vince Erol P. Pangilinan.
The Flutter project lives in `pangilinan_advmobprog/`.

## Lab Activity 1: Ephemeral vs. App State — discussion

**State management** in Flutter is how an app stores data that can change over time and how it tells the UI to rebuild when that data changes.

**Ephemeral (local) state** belongs to a single widget. In this activity the counter on `CounterScreen` is ephemeral: the value lives in `_CounterScreenState`, it is changed with `setState()`, and only that widget rebuilds. No other screen needs it, and it disappears when the State object is disposed.

**App state** is shared across many parts of the app and lives longer. The dark/light theme is app state: it is stored in `ThemeModel` (a `ChangeNotifier`), provided at the top of the tree with `ChangeNotifierProvider`, and read with `Provider.of<ThemeModel>(context)`. Toggling the switch on `ThemeToggleScreen` calls `notifyListeners()`, which rebuilds `MyApp` and every listening screen, so the counter screen also changes theme.

**setState vs. Provider**

| | `setState` | `Provider` |
|---|---|---|
| Scope | One widget and its children | Any widget below the provider |
| Where the data lives | Inside a `State` object | Inside a separate model class (`ChangeNotifier`) |
| How the UI updates | `setState()` rebuilds that widget | `notifyListeners()` rebuilds every listener |
| Best for | UI-only values (counters, text-field input, animation flags) | Values many screens need (theme, logged-in user, cart) |
| Drawback | Data must be passed manually through constructors to share it | A bit more setup (model class + provider) |

Rule of thumb: start with `setState` for local UI values, and move a value into a Provider model as soon as more than one screen needs to read or change it.
