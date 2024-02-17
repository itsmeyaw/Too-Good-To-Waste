import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/dto/user_item_model.dart';

Logger logger = Logger();

class AiService {
  FirebaseFunctions functions = FirebaseFunctions.instance;

  Future<List<UserItem>> readReceipt(String mimeType, String base64Data) async {
    HttpsCallable callable = functions.httpsCallable('readReceipt');

    try {
      HttpsCallableResult<Map<String, dynamic>> result = await callable
          .call({'mime_type': mimeType, 'base64_image_data': base64Data});

      final text = result.data["candidates"][0]["content"]["parts"][0]["text"];
      logger.d('Obtained result from AI\n$text');

      if (text == null) {
        logger.w("Result text from AI is null or empty");
        return List.empty();
      }

      final List<UserItem> items = [];

      // Remove trailing and tailing Markdown
      final RegExp markdownParseRegex =
          RegExp(r"\s*```json\s*(?<Data>[\S\s]*)\s*```\s*", multiLine: true);
      final RegExpMatch? markdownParseMatch =
          markdownParseRegex.firstMatch(text);

      logger.d("Markdown regex match from result: $markdownParseMatch");

      final String? cleanedText = markdownParseMatch?.namedGroup("Data");

      if (cleanedText == null) {
        logger.w("Cleaned text from AI is null or empty");
        return List.empty();
      }

      logger.d("Markdown result data: $cleanedText");

      final List<dynamic> decodedResult = jsonDecode(cleanedText);

      for (final item in decodedResult) {
        items.add(UserItem(
            id: null,
            name: item["item"],
            category: item["category"],
            buyDate: DateTime.parse(item["buy_date"]).millisecondsSinceEpoch,
            expiryDate: DateTime.parse(item["suggested_expiry_date"]).millisecondsSinceEpoch,
            quantityType: item["amount_unit"],
            quantityNum: (item["amount_count"] as num).toDouble(),
            consumeState: 0,
            state: "good"));
      }

      logger.d("AI Got ${items.length} item results");
      return items;
    } catch (e) {
      logger.e('Error when trying to read receipt with AI: $e');
      throw Exception("Cannot correctly read receipt");
    }
  }
}
