import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

/// Talks to the /carts endpoints and converts JSON into [Cart] objects.
class CartService {
  /// Items added with "Add to cart" during this app session.
  /// DummyJSON only *simulates* POST /carts/add (nothing is saved on the
  /// server), so we keep the returned items here and merge them into the
  /// cart screen.
  static final List<CartProduct> addedItems = [];

  /// GET $host/carts -> every cart of every user
  Future<List<Cart>> getAllCarts() async {
    final response = await http.get(Uri.parse('$host/carts'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsJson = data['carts'] ?? [];
      return cartsJson.map((json) => Cart.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load carts');
    }
  }

  // ENHANCEMENT 3: GET $host/carts/{id} -> one cart by its cart id
  Future<Cart> getCartById(int cartId) async {
    final response = await http.get(Uri.parse('$host/carts/$cartId'));

    if (response.statusCode == 200) {
      return Cart.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load cart $cartId');
    }
  }

  // ENHANCEMENT 3: GET $host/carts/user/{userId} -> carts of ONE user.
  // Returns the user's first cart, or null if the user has no cart.
  Future<Cart?> getCartByUserId(int userId) async {
    final response = await http.get(Uri.parse('$host/carts/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List cartsJson = data['carts'] ?? [];
      if (cartsJson.isEmpty) return null;
      return Cart.fromJson(cartsJson.first);
    } else {
      throw Exception('Failed to load cart of user $userId');
    }
  }

  // ENHANCEMENT 3: POST $host/carts/add -> add a product to a cart.
  // Body: { "userId": 1, "products": [ { "id": 144, "quantity": 4 } ] }
  // The API answers with the new (simulated) cart; its products are kept
  // in [addedItems] so the cart screen can show them.
  Future<Cart> addToCart({
    required int userId,
    required int productId,
    int quantity = 1,
  }) async {
    final response = await http.post(
      Uri.parse('$host/carts/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'products': [
          {'id': productId, 'quantity': quantity},
        ],
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final cart = Cart.fromJson(jsonDecode(response.body));
      for (final item in cart.products) {
        final i = addedItems.indexWhere((e) => e.id == item.id);
        if (i >= 0) {
          addedItems[i] = addedItems[i].copyWith(
            quantity: addedItems[i].quantity + item.quantity,
          );
        } else {
          addedItems.add(item.copyWith());
        }
      }
      return cart;
    } else {
      throw Exception('Failed to add to cart: ${response.body}');
    }
  }
}
