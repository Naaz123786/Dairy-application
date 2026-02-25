import 'dart:convert';
import 'package:flutter/foundation.dart';

class JsonUtils {
  /// Robustly decodes JSON strings.
  ///
  /// If decoding fails due to **unescaped control characters inside JSON string
  /// literals** (common with legacy rich-text content), we sanitize by escaping
  /// those characters *only while inside a quoted JSON string*.
  static dynamic safeDecode(String content) {
    if (content.isEmpty) return null;

    final trimmed = content.trim();
    if (!trimmed.startsWith('[') && !trimmed.startsWith('{')) {
      return null;
    }

    try {
      return jsonDecode(trimmed);
    } catch (e1) {
      try {
        final sanitized = _escapeControlCharsInStrings(trimmed);
        return jsonDecode(sanitized);
      } catch (e2) {
        debugPrint('JsonUtils.safeDecode failed: $e1');
        debugPrint('JsonUtils.safeDecode failed after sanitize: $e2');
        return null;
      }
    }
  }

  static String _escapeControlCharsInStrings(String input) {
    final sb = StringBuffer();
    bool inString = false;
    bool escaping = false;

    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      final code = input.codeUnitAt(i);

      if (!inString) {
        if (ch == '"') {
          inString = true;
        }
        // Outside strings, keep JSON whitespace/newlines as-is.
        sb.write(ch);
        continue;
      }

      // Inside strings
      if (escaping) {
        escaping = false;
        // If the source contains an actual control char right after a backslash,
        // JSON decoding fails (e.g. "\\\n"). Convert it into a valid escape.
        if (code < 0x20) {
          switch (code) {
            case 0x08:
              sb.write('b');
              break;
            case 0x09:
              sb.write('t');
              break;
            case 0x0A:
              sb.write('n');
              break;
            case 0x0C:
              sb.write('f');
              break;
            case 0x0D:
              sb.write('r');
              break;
            default:
              final hex = code.toRadixString(16).padLeft(4, '0');
              sb.write('u$hex');
          }
        } else {
          sb.write(ch);
        }
        continue;
      }

      if (ch == r'\') {
        escaping = true;
        sb.write(ch);
        continue;
      }

      if (ch == '"') {
        inString = false;
        sb.write(ch);
        continue;
      }

      // Unescaped control characters inside JSON strings are invalid.
      if (code < 0x20) {
        switch (code) {
          case 0x08:
            sb.write(r'\b');
            break;
          case 0x09:
            sb.write(r'\t');
            break;
          case 0x0A:
            sb.write(r'\n');
            break;
          case 0x0C:
            sb.write(r'\f');
            break;
          case 0x0D:
            sb.write(r'\r');
            break;
          default:
            final hex = code.toRadixString(16).padLeft(4, '0');
            sb.write('\\u$hex');
        }
        continue;
      }

      sb.write(ch);
    }

    return sb.toString();
  }

  /// Extracts ops list from decoded JSON, supporting both naked List and {ops: []} formats.
  static List<dynamic>? getOps(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map && decoded['ops'] is List) {
      return decoded['ops'] as List;
    }
    return null;
  }
}
