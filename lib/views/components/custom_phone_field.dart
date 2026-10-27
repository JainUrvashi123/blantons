import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../../core/constants/app_colors.dart';

class CustomPhoneField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final Function(String)? onChanged;

  const CustomPhoneField({
    Key? key,
    this.controller,
    required this.hintText,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  String _dialCode = '+1';
  String _isoCode = 'US';
  bool _isInternalUpdating = false;

  static const List<Map<String, String>> _countryList = [
    {'code': 'US', 'dialCode': '+1'},
    {'code': 'CA', 'dialCode': '+1'},
    {'code': 'IN', 'dialCode': '+91'},
    {'code': 'GB', 'dialCode': '+44'},
    {'code': 'AU', 'dialCode': '+61'},
    {'code': 'NZ', 'dialCode': '+64'},
    {'code': 'ZA', 'dialCode': '+27'},
    {'code': 'IE', 'dialCode': '+353'},
    {'code': 'DE', 'dialCode': '+49'},
    {'code': 'FR', 'dialCode': '+33'},
    {'code': 'IT', 'dialCode': '+39'},
    {'code': 'ES', 'dialCode': '+34'},
    {'code': 'BR', 'dialCode': '+55'},
    {'code': 'MX', 'dialCode': '+52'},
    {'code': 'CN', 'dialCode': '+86'},
    {'code': 'JP', 'dialCode': '+81'},
    {'code': 'KR', 'dialCode': '+82'},
    {'code': 'RU', 'dialCode': '+7'},
    {'code': 'PK', 'dialCode': '+92'},
    {'code': 'BD', 'dialCode': '+880'},
    {'code': 'LK', 'dialCode': '+94'},
    {'code': 'NP', 'dialCode': '+977'},
    {'code': 'AE', 'dialCode': '+971'},
    {'code': 'SA', 'dialCode': '+966'},
    {'code': 'SG', 'dialCode': '+65'},
    {'code': 'MY', 'dialCode': '+60'},
    {'code': 'HK', 'dialCode': '+852'},
    {'code': 'TW', 'dialCode': '+886'},
    {'code': 'NL', 'dialCode': '+31'},
    {'code': 'CH', 'dialCode': '+41'},
    {'code': 'SE', 'dialCode': '+46'},
    {'code': 'NO', 'dialCode': '+47'},
    {'code': 'DK', 'dialCode': '+45'},
    {'code': 'FI', 'dialCode': '+358'},
    {'code': 'BE', 'dialCode': '+32'},
    {'code': 'AT', 'dialCode': '+43'},
    {'code': 'PT', 'dialCode': '+351'},
    {'code': 'GR', 'dialCode': '+30'},
    {'code': 'IL', 'dialCode': '+972'},
    {'code': 'TR', 'dialCode': '+90'},
    {'code': 'PH', 'dialCode': '+63'},
    {'code': 'ID', 'dialCode': '+62'},
    {'code': 'TH', 'dialCode': '+66'},
    {'code': 'VN', 'dialCode': '+84'},
    {'code': 'CO', 'dialCode': '+57'},
    {'code': 'PE', 'dialCode': '+51'},
    {'code': 'AR', 'dialCode': '+54'},
    {'code': 'CL', 'dialCode': '+56'},
    {'code': 'VE', 'dialCode': '+58'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _parseControllerText();
      widget.controller!.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    if (widget.controller != null) {
      widget.controller!.removeListener(_onControllerChanged);
    }
    super.dispose();
  }

  void _onControllerChanged() {
    _parseControllerText();
  }

  void _parseControllerText() {
    if (_isInternalUpdating || widget.controller == null) return;
    String text = widget.controller!.text.trim();
    if (text.startsWith('+')) {
      final sortedCountries = List<Map<String, String>>.from(_countryList)
        ..sort((a, b) => b['dialCode']!.length.compareTo(a['dialCode']!.length));

      bool matched = false;
      for (var country in sortedCountries) {
        final dialCode = country['dialCode']!;
        if (text.startsWith(dialCode)) {
          final localNumber = text.substring(dialCode.length).trim();
          
          _isInternalUpdating = true;
          _dialCode = dialCode;
          _isoCode = country['code']!;
          widget.controller!.text = localNumber;
          _isInternalUpdating = false;
          
          if (mounted) {
            setState(() {});
          }
          matched = true;
          break;
        }
      }

      // Fallback if country not in list: parse first 1 to 4 digits after '+'
      if (!matched) {
        final regex = RegExp(r'^\+(\d{1,4})');
        final match = regex.firstMatch(text);
        if (match != null) {
          final dialCode = match.group(0)!;
          final localNumber = text.substring(dialCode.length).trim();
          
          _isInternalUpdating = true;
          _dialCode = dialCode;
          _isoCode = dialCode; 
          widget.controller!.text = localNumber;
          _isInternalUpdating = false;
          
          if (mounted) {
            setState(() {});
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CountryCodePicker(
            key: ValueKey(_isoCode),
            onChanged: (country) {
              setState(() {
                _dialCode = country.dialCode ?? '+1';
                _isoCode = country.code ?? 'US';
              });
              if (widget.onChanged != null && widget.controller != null) {
                widget.onChanged!('$_dialCode ${widget.controller!.text}');
              }
            },
            initialSelection: _isoCode,
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            alignLeft: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            textStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 50,
            child: TextFormField(
              controller: widget.controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                PhoneInputFormatter(
                  defaultCountryCode: _isoCode.startsWith('+') ? 'US' : _isoCode,
                )
              ],
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              onChanged: (value) {
                if (widget.onChanged != null) {
                  widget.onChanged!('$_dialCode $value');
                }
              },
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: GoogleFonts.poppins(color: Colors.black38, fontSize: 14),
                errorStyle: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
