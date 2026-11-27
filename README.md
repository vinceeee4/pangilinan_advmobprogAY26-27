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

## Lab Activity 2: API — discussion

**How the model, service and screen work together**

1. **Model (`models/product.dart`)** – `Product` describes the shape of one product returned by `https://dummyjson.com/products`. Its `Product.fromJson()` factory turns a raw JSON map into a typed Dart object, using `??` defaults and `num → double` conversion so a missing or differently-typed field never crashes the app. Nested JSON (dimensions, reviews, meta) gets its own small model class.
2. **Service (`services/product_service.dart`)** – `ProductService` is the only class that knows about HTTP. `getAllProducts()` builds the URL from `host` (read from `assets/.env` through `flutter_dotenv` in `constants.dart`), calls `http.get`, checks the status code, decodes the body with `jsonDecode`, and maps every item through `Product.fromJson`. It returns `Future<List<Product>>` or throws an exception. `getProductById()` does the same for one product.
3. **Screen (`screens/product_screen.dart`)** – `ProductScreen` calls the service once in `initState()` and keeps the `Future`. A `FutureBuilder` listens to that future and renders one of four states: loading spinner, error message, "No products found", or the `GridView` of product cards. The screen never touches JSON; it only works with `Product` objects.

So the data flows **API → Service (HTTP + JSON) → Model (typed object) → Screen (FutureBuilder → widgets)**.

**The new design pattern**

The project moved from a single `main.dart` to a layered folder structure:

| Folder | Responsibility |
|---|---|
| `models/` | Data classes + JSON parsing |
| `services/` | Network calls to the API |
| `providers/` | App-wide state (`ThemeProvider`) |
| `screens/` | Full pages (home, product, detail, settings) |
| `widgets/` | Reusable UI pieces (`CustomText`) |
| `constants.dart` | Shared config (API host from `.env`, colors) |

This is a separation-of-concerns (MVC/MVVM-like) pattern: each layer has one job, so the UI can change without touching the API code, the API can change by editing one service, and pieces such as `CustomText` and `DetailScreen` can be reused. `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`) keeps sizes consistent on different screen sizes, and the base URL in `.env` keeps configuration out of the code.

**Enhancements implemented**

- **Enhancement 1** – A search `TextField` above the product grid filters products by title, brand or category as you type, with a clear button.
- **Enhancement 2** – Tapping a card opens `DetailScreen` (image header + rounded content sheet like the sample) showing images, price, discount, rating, description, stock, shipping, warranty, return policy and reviews. A `Hero` animation connects the card image to the details page.
- **Enhancement 3** – A `SettingsScreen` (opened from the gear icon, route `/settings`) now holds the dark/light mode switch, backed by `ThemeProvider`.
