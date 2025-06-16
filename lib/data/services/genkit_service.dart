import 'dart:convert';
import 'package:ai_logistics_management_order_automation/config/constants.dart';
import 'package:ai_logistics_management_order_automation/domain/models/grouping_helper_result_model.dart';
import 'package:http/http.dart' as http;

/// A service class to interact with Genkit backend flows.
class Genkit {
  // Headers used for HTTP requests.
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  /// Calls the 'groupingHelperFlow' endpoint on the Genkit backend.
  ///
  /// [input]: A Map representing the order group structure.
  static Future<GroupingHelperResultModel> groupingHelperFlow(
      Map<String, dynamic> input) async {
    final url = Uri.http(genkitServerEndpoint, 'groupingHelperFlow');

    final body = jsonEncode({
      'data': input
    });

    try {
      final response = await http.post(url, body: body, headers: _headers);

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
        final decoded = jsonDecode(response.body);
        return GroupingHelperResultModel.fromJson(decoded['result']);
      } else {
        throw Exception(
            'Server responded with status: ${response.statusCode}\n${response.body}');
      }
    } catch (e, stack) {
      // Optionally print or log the error and stack trace for debugging
      print('Error in groupingHelperFlow: $e');
      print('Stack trace: $stack');
      print('Request body: $body');
      print('Request url: $url');
      throw Exception('Failed to call groupingHelperFlow: $e\nStack: $stack\nRequest: $body\nURL: $url');
    }
  }
}
