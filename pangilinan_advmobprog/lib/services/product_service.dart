import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/product.dart';

/// Talks to the /products endpoint and converts JSON into [Product] objects.
class ProductService {
  /// GET $host/products -> list of products
  Future<List<Product>> getAllProducts() async {
    final response = await http.get(Uri.parse('$host/products'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List productsJson = data['products'] ?? [];
      return productsJson.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // ENHANCEMENT 2 (support): GET $host/products/{id}
  // Used by DetailScreen so it can load a product from just its id.
  Future<Product> getProductById(int id) async {
    final response = await http.get(Uri.parse('$host/products/$id'));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product $id');
    }
  }
}
