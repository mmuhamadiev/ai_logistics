// cubits/postcode_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_logistics_management_order_automation/domain/models/post_code_model.dart';

class PostcodeCubit extends Cubit<List<PostalCode>> {
  PostcodeCubit() : super([]);

  List<PostalCode> allPostcodes = [];
  int currentPage = 0;
  final int pageSize = 100;

  Future<void> loadInitialPostcodesTemp() async {
    // final String response = await rootBundle.loadString('assets/postalcodes/all_postalcodes.json');
    final String response = await rootBundle.loadString(kDebugMode? 'postalcodes/all_postalcodes.json': 'assets/postalcodes/all_postalcodes.json');
    final List<dynamic> data = json.decode(response);

    print(data.last);
    allPostcodes = data
        .where((postcode) =>
    postcode['country_code'] != null &&
        postcode['postalcode'] != null &&
        postcode['code'] != null &&
        postcode['name'] != null &&
        postcode['latitude'] != null &&
        postcode['longitude'] != null)
        .map((item) => PostalCode(
      countryCode: item['country_code'].toString(),
      postalCode: item['postalcode'].toString(),
      name: item['name'],
      code: item['code'] != null ? item['code'].toString() : null,
      latitude: item['latitude'],
      longitude: item['longitude'],
    )).toList();
    print('${allPostcodes.last.postalCode} ${allPostcodes.last.name} ${allPostcodes.last.countryCode}');
    loadMorePostcodes();
  }

  Future<void> resetPostcodes() async {
    currentPage = 0;
    loadMorePostcodes();
  }

  // void loadInitialPostcodes(String jsonContent) {
  //   final List<dynamic> data = json.decode(jsonContent);
  //
  //   print(data.last);
  //
  //   allPostcodes = data
  //       .where((postcode) =>
  //   postcode['country_code'] != null &&
  //       postcode['postalcode'] != null &&
  //       postcode['code'] != null &&
  //       postcode['name'] != null &&
  //       postcode['latitude'] != null &&
  //       postcode['longitude'] != null)
  //       .map((item) => PostalCode(
  //     countryCode: item['country_code'].toString(),
  //     postalCode: item['postalcode'].toString(),
  //     name: item['name'],
  //     code: item['code'] != null ? item['code'].toString() : null,
  //     latitude: item['latitude'],
  //     longitude: item['longitude'],
  //   )).toList();
  //   print('${allPostcodes.last.postalCode} ${allPostcodes.last.name} ${allPostcodes.last.countryCode}');
  //   loadMorePostcodes();
  // }

  void loadMorePostcodes() {
    final int nextPage = currentPage + 1;
    final int startIndex = currentPage * pageSize;
    final int endIndex = startIndex + pageSize;

    if (startIndex < allPostcodes.length) {
      final List<PostalCode> newPostcodes = allPostcodes.sublist(
        startIndex,
        endIndex > allPostcodes.length ? allPostcodes.length : endIndex,
      );
      emit(List.from(state)..addAll(newPostcodes));
      currentPage = nextPage;
    }
  }

  void searchPostcodes(String query) {
    final lowercaseQuery = query.toLowerCase();

    final List<PostalCode> searchResults = allPostcodes.where((postcode) {
      return postcode.name.toLowerCase().contains(lowercaseQuery) ||
          postcode.countryCode.toLowerCase().contains(lowercaseQuery) ||
          postcode.postalCode.toString().startsWith(lowercaseQuery); // Ensure postal code starts with the query
    }).toList();

    emit(searchResults);
  }

}