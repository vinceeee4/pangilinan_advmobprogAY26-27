import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Base URL of the API, loaded from assets/.env (HOST=https://dummyjson.com).
var host = dotenv.env['HOST'];

/// App colors used across screens.
const Color kPrimary = Color(0xFF344394); // navy
const Color kAccent = Color(0xFFFFC425); // gold
