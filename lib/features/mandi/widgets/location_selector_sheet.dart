import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/mandi_models.dart';

class LocationSelectorSheet extends StatefulWidget {
  final List<StateDistrictsInfo> statesList;
  final String? currentState;
  final String? currentDistrict;
  final void Function(String state, String district) onLocationSelected;

  const LocationSelectorSheet({
    super.key,
    required this.statesList,
    this.currentState,
    this.currentDistrict,
    required this.onLocationSelected,
  });

  @override
  State<LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends State<LocationSelectorSheet> {
  String? _selectedState;
  String? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _selectedState = widget.currentState ?? 'Karnataka';
    _selectedDistrict = widget.currentDistrict ?? 'Bangalore';

    // Verify selected state exists in list
    if (widget.statesList.isNotEmpty) {
      final stateMatches = widget.statesList.where((s) => s.state.toLowerCase() == _selectedState?.toLowerCase());
      if (stateMatches.isNotEmpty) {
        _selectedState = stateMatches.first.state;
      } else {
        _selectedState = widget.statesList.first.state;
      }
    }
    if (_selectedDistrict == null || _selectedDistrict!.isEmpty) {
      _selectedDistrict = 'All Districts';
    }
  }

  List<String> get _availableDistricts {
    if (_selectedState == null || widget.statesList.isEmpty) return ['All Districts'];
    final match = widget.statesList.firstWhere(
      (s) => s.state == _selectedState,
      orElse: () => widget.statesList.first,
    );
    return ['All Districts', ...match.districts];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Select Mandi Location',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F4D33),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Text(
            'Select your state and district to view local APMC market prices.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // State Dropdown
          const Text(
            'STATE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD4E3DA), width: 1.2),
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFFAFCFA),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedState,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0F4D33)),
                items: widget.statesList.map((stateInfo) {
                  return DropdownMenuItem<String>(
                    value: stateInfo.state,
                    child: Text(
                      stateInfo.state,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newState) {
                  if (newState != null) {
                    setState(() {
                      _selectedState = newState;
                      final districts = _availableDistricts;
                      _selectedDistrict = districts.isNotEmpty ? districts.first : null;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // District Dropdown
          const Text(
            'DISTRICT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD4E3DA), width: 1.2),
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFFFAFCFA),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDistrict,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF0F4D33)),
                items: _availableDistricts.map((district) {
                  return DropdownMenuItem<String>(
                    value: district,
                    child: Text(
                      district,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newDistrict) {
                  setState(() {
                    _selectedDistrict = newDistrict;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4D33),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                if (_selectedState != null && _selectedDistrict != null) {
                  widget.onLocationSelected(_selectedState!, _selectedDistrict!);
                  Navigator.of(context).pop();
                }
              },
              child: const Text(
                'Apply Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

