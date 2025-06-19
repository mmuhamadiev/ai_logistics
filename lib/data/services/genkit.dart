import 'dart:convert';
import 'dart:developer';
import 'package:ai_logistics_management_order_automation/domain/models/grouping_helper_result_model.dart';
import 'package:http/http.dart' as http;

class Genkit {

  static String genkitServerEndpoint = 'localhost:2222';

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  static Future<GroupingHelperResultModel> groupingHelperFlow(
      Map<String, dynamic> input,
      ) async {
    var url = Uri.http(genkitServerEndpoint, 'groupingHelperFlow');

    var body = json.encode({'data': input});

    http.Response response;

    try {
      response = await http.post(url, body: body, headers: _headers);
    } catch (e) {
      throw Exception('Failed to make network call: $e');
    }

    if (response.statusCode == 200) {
      log('GGGG ${response.body}');
      return GroupingHelperResultModel.fromJson(json.decode(response.body)['result']);
    } else {
      throw Exception(
        'Server responded with a non-200 status code: ${response.statusCode}',
      );
    }
  }
}