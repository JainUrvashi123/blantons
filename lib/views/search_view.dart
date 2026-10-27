import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../viewmodels/search_viewmodel.dart';
import 'components/jewelry_item_card.dart';
import 'components/custom_text_field.dart';

class SearchView extends StatefulWidget {
  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {});

    if (query.isNotEmpty) {
      Provider.of<SearchViewModel>(context, listen: false).setQueryAndLoading(query);
    } else {
      Provider.of<SearchViewModel>(context, listen: false).clearSearch();
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), () {
      if (query.isNotEmpty) {
        Provider.of<SearchViewModel>(context, listen: false).performSearch(query);
      }
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      Provider.of<SearchViewModel>(context, listen: false).performSearch(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, vm, child) {
          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(AppConstants.horizontalPadding, 12, AppConstants.horizontalPadding, 8),
                child: CustomTextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  hintText: 'Search jewelry...',
                  prefixIcon: Icons.search_rounded,
                  suffixIcon: _searchController.text.isNotEmpty ? Icons.clear_rounded : null,
                  onSuffixTap: () {
                    _searchController.clear();
                    vm.clearSearch();
                    setState(() {});
                  },
                  onChanged: _onSearchChanged,
                  onFieldSubmitted: _onSearchSubmitted,
                  textInputAction: TextInputAction.search,
                ),
              ),

              Expanded(
                child: vm.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryButton,
                        ),
                      )
                    : vm.error != null
                        ? Center(
                            child: Text(
                              vm.error!,
                              style: GoogleFonts.poppins(color: Colors.red),
                            ),
                          )
                        : vm.currentQuery.isNotEmpty && vm.searchResults.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE0EEFE),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.search_off_rounded, size: 40, color: Color(0xFF6B8BBE)),
                                    ),
                                    const SizedBox(height: 16),

                                  ],
                                ),
                              )
                            : vm.currentQuery.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(20),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFBEADB),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.search_rounded, size: 40, color: Color(0xFFC78B6C)),
                                        ),
                                        const SizedBox(height: 16),

                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding, vertical: 16),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.65,
                                    ),
                                    itemCount: vm.searchResults.length,
                                    itemBuilder: (context, index) {
                                      final item = vm.searchResults[index];
                                      return JewelryItemCard(item: item);
                                    },
                                  ),
              ),
            ],
          );
        },
      ),
    );
  }
}


