import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_logistics_management_order_automation/config/app_colors.dart';
import 'package:ai_logistics_management_order_automation/config/app_text_styles.dart';
import 'package:ai_logistics_management_order_automation/domain/models/post_code_model.dart';
import 'package:ai_logistics_management_order_automation/presentation/manager/postalcode/postcode_cubit.dart';

class PostcodeMenu extends StatefulWidget {
  final Function(PostalCode) onPostcodeSelected;

  const PostcodeMenu({Key? key, required this.onPostcodeSelected}) : super(key: key);

  @override
  _PostcodeMenuState createState() => _PostcodeMenuState();
}

class _PostcodeMenuState extends State<PostcodeMenu> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PostcodeCubit>().resetPostcodes();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if(_searchController.text.isEmpty) {
        context.read<PostcodeCubit>().loadMorePostcodes();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<PostcodeCubit>().searchPostcodes(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: AppColors.white,
      child: Container(
        width: 500,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Select Location", style: AppTextStyles.head22RobotoMedium),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.indigo, width: 2.0),
                      borderRadius: BorderRadius.circular(8)
                  ),
                ),
                onChanged: (value) => _onSearchChanged(),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4, left: 8, right: 8),
                child: Text("Search Results", style: AppTextStyles.body17RobotoMedium.copyWith(color: AppColors.grey)),
              ),
            ),
            Expanded(
              child: BlocBuilder<PostcodeCubit, List<PostalCode>>(
                builder: (context, postcodes) {
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: postcodes.length,
                    itemBuilder: (context, index) {
                      final postcode = postcodes[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: ListTile(
                          title: Text(
                            '${postcode.name} (${postcode.postalCode})',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${postcode.countryCode} - Lat: ${postcode.latitude}, Long: ${postcode.longitude}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          onTap: () => widget.onPostcodeSelected(postcode),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

