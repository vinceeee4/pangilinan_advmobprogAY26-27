import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base URL of the API, loaded from assets/.env (HOST=https://dummyjson.com).
var host = dotenv.env['HOST'];

/// App colors used across screens.
const Color kPrimary = Color(0xFF344394); // navy
const Color kAccent = Color(0xFFFFC425); // gold

/// Lab 3 has no login yet, so the cart screen shows the cart of this
/// DummyJSON user (GET /carts/user/{id}). Change it to try another user.
const int kDefaultUserId = 33;
