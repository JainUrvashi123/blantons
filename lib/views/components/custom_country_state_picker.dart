import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/country_state_data.dart';

class CustomCountryStatePicker extends StatefulWidget {
  final String? selectedCountry;
  final String? selectedState;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onStateChanged;

  const CustomCountryStatePicker({
    super.key,
    required this.selectedCountry,
    required this.selectedState,
    required this.onCountryChanged,
    required this.onStateChanged,
  });

  @override
  State<CustomCountryStatePicker> createState() => _CustomCountryStatePickerState();
}

class _CustomCountryStatePickerState extends State<CustomCountryStatePicker> {
  void _showSearchBottomSheet({
    required String title,
    required List<String> items,
    required String? currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SearchBottomSheet(
          title: title,
          items: items,
          currentValue: currentValue,
          onSelected: onSelected,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get list of sorted countries
    final List<String> countries = countryStateData.keys.toList()..sort();
    
    // Get list of states for the selected country
    final List<String> states = widget.selectedCountry != null 
        ? (countryStateData[widget.selectedCountry] ?? [])
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country*',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        // Country Selector
        GestureDetector(
          onTap: () {
            _showSearchBottomSheet(
              title: "Select Country",
              items: countries,
              currentValue: widget.selectedCountry,
              onSelected: (value) {
                widget.onCountryChanged(value);
              },
            );
          },
          child: _buildSelectorField(
            hintText: "Select Country",
            value: widget.selectedCountry,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'State*',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        // State Selector
        GestureDetector(
          onTap: widget.selectedCountry == null || widget.selectedCountry!.isEmpty
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select a country first."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              : () {
                  _showSearchBottomSheet(
                    title: "Select State",
                    items: states,
                    currentValue: widget.selectedState,
                    onSelected: (value) {
                      widget.onStateChanged(value);
                    },
                  );
                },
          child: AbsorbPointer(
            child: _buildSelectorField(
              hintText: "Select State",
              value: widget.selectedState,
              isDisabled: widget.selectedCountry == null || widget.selectedCountry!.isEmpty,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectorField({
    required String hintText,
    required String? value,
    bool isDisabled = false,
  }) {
    final hasValue = value != null && value.isNotEmpty && !value.contains("Select");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              hasValue ? value : hintText,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: hasValue 
                    ? Colors.black87 
                    : (isDisabled ? Colors.black26 : Colors.black38),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: isDisabled ? Colors.black26 : Colors.black38,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _SearchBottomSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final String? currentValue;
  final ValueChanged<String> onSelected;

  const _SearchBottomSheet({
    required this.title,
    required this.items,
    required this.currentValue,
    required this.onSelected,
  });

  @override
  State<_SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<_SearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;
    
    return Container(
      height: mediaQuery.size.height * 0.6 + bottomInset,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: bottomInset > 0 ? bottomInset + 16 : 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: GoogleFonts.cormorantUpright(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.black54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search Box
          TextField(
            controller: _searchController,
            autofocus: true,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: "Search...",
              hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.black38, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: const Color(0xFFF7F8FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryButton, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // List of items
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      "No results found",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black38,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredItems.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = widget.currentValue == item;
                      return InkWell(
                        onTap: () {
                          widget.onSelected(item);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppColors.primaryButton.withOpacity(0.08) 
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: isSelected 
                                        ? FontWeight.w600 
                                        : FontWeight.normal,
                                    color: isSelected 
                                        ? AppColors.primaryButton 
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primaryButton,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
