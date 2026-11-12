import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../models/mandi_models.dart';
import '../services/mandi_api_service.dart';
import '../widgets/location_selector_sheet.dart';
import '../widgets/mandi_card.dart';

class MandiPricesScreen extends StatefulWidget {
  final String? initialCommodity;

  const MandiPricesScreen({
    super.key,
    this.initialCommodity,
  });

  @override
  State<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends State<MandiPricesScreen> {
  final MandiApiService _apiService = MandiApiService();
  final TextEditingController _searchController = TextEditingController();

  // Location State (Default: Karnataka, All Districts)
  String _state = 'Karnataka';
  String _district = 'All Districts';

  // Commodity & Filter State (Default: All commodities)
  String _selectedCommodity = 'All';
  String _sortBy = 'latest_date'; // 'latest_date', 'highest_price', 'lowest_price'

  // Data State
  bool _isLoading = true;
  String? _errorMessage;
  List<MandiRecord> _records = [];
  int? _totalRecords;
  List<StateDistrictsInfo> _statesList = [];

  // Popular quick commodities for instant one-tap filtering
  final List<Map<String, String>> _quickCommodities = const [
    {'name': 'All', 'emoji': '🌾'},
    {'name': 'Groundnut', 'emoji': '🥜'},
    {'name': 'Maize', 'emoji': '🌽'},
    {'name': 'Tomato', 'emoji': '🍅'},
    {'name': 'Onion', 'emoji': '🧅'},
    {'name': 'Potato', 'emoji': '🥔'},
    {'name': 'Apple', 'emoji': '🍎'},
    {'name': 'Banana', 'emoji': '🍌'},
    {'name': 'Mango', 'emoji': '🥭'},
    {'name': 'Chilli', 'emoji': '🌶️'},
    {'name': 'Brinjal', 'emoji': '🍆'},
    {'name': 'Cabbage', 'emoji': '🥬'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialCommodity != null && widget.initialCommodity!.isNotEmpty) {
      _selectedCommodity = widget.initialCommodity!;
    }
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // 1. Load state & district catalog in background
    _apiService.fetchLocations().then((locs) {
      if (mounted && locs.isNotEmpty) {
        setState(() {
          _statesList = locs;
        });
      }
    }).catchError((_) {});

    // 2. Fetch live prices from Government API
    await _fetchPrices();
  }

  Future<void> _fetchPrices() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.fetchPrices(
        state: _state,
        district: (_district.isNotEmpty && _district != 'All Districts') ? _district : null,
        commodity: (_selectedCommodity.isNotEmpty && _selectedCommodity != 'All')
            ? _selectedCommodity
            : null,
        sortBy: _sortBy,
        limit: 50,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _records = response.records;
        _totalRecords = response.totalRecords;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    }
  }

  void _openLocationSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LocationSelectorSheet(
        statesList: _statesList,
        currentState: _state,
        currentDistrict: _district,
        onLocationSelected: (newState, newDistrict) {
          setState(() {
            _state = newState;
            _district = newDistrict;
          });
          _fetchPrices();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final districtLabel = (_district.isNotEmpty && _district != 'All Districts')
        ? _district
        : 'All Districts';

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.mandiPricesTitle,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F4D33),
              ),
            ),
            Text(
              '$_state • $districtLabel',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F4D33)),
            tooltip: 'Refresh prices',
            onPressed: _fetchPrices,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF0F4D33),
        onRefresh: _fetchPrices,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // 1. Simple, Clean State & District Selector Card
            SliverToBoxAdapter(
              child: _buildLocationBar(),
            ),

            // 2. Search & Quick Commodity Bar
            SliverToBoxAdapter(
              child: _buildCommoditySelector(),
            ),

            // 3. Summary & Sort Bar
            SliverToBoxAdapter(
              child: _buildSummaryAndSortBar(),
            ),

            // 4. Mandi Price Cards List / Loading / Error
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF0F4D33),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Fetching live Government Mandi prices...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildErrorState(),
              )
            else if (_records.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final record = _records[index];
                    return MandiPriceCard(record: record);
                  },
                  childCount: _records.length,
                ),
              ),

            // Bottom Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationBar() {
    final districtLabel = (_district.isNotEmpty && _district != 'All Districts')
        ? _district
        : 'All Districts';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2EBE5), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _openLocationSelector,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Location Pin Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2F5EC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF0F4D33),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Selected State & District Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_state • $districtLabel',
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F4D33),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Tap to change state or district',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Change pill indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F5EC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F4D33),
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: Color(0xFF0F4D33),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommoditySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCE6DF), width: 1.2),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search crop (e.g. Groundnut, Tomato, Maize)...',
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F4D33), size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _selectedCommodity = 'All';
                          });
                          _fetchPrices();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  setState(() {
                    _selectedCommodity = value.trim();
                  });
                  _fetchPrices();
                }
              },
            ),
          ),
        ),

        // Quick Commodity Chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _quickCommodities.length,
            itemBuilder: (context, index) {
              final item = _quickCommodities[index];
              final isSelected = _selectedCommodity.toLowerCase() == item['name']!.toLowerCase();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
                  label: Text('${item['emoji']} ${item['name']}'),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0F4D33),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF0F4D33) : const Color(0xFFDCE6DF),
                      width: 1.2,
                    ),
                  ),
                  showCheckmark: false,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCommodity = item['name']!;
                      _searchController.clear();
                    });
                    _fetchPrices();
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryAndSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, size: 14, color: Color(0xFF0F4D33)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    _totalRecords != null
                        ? '$_totalRecords market records'
                        : '${_records.length} market records',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF0F4D33),
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Sort Menu
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDCE6DF)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded, size: 15, color: Color(0xFF0F4D33)),
                  SizedBox(width: 4),
                  Text(
                    'Sort',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F4D33),
                    ),
                  ),
                ],
              ),
            ),
            initialValue: _sortBy,
            onSelected: (val) {
              setState(() {
                _sortBy = val;
              });
              _fetchPrices();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'latest_date',
                child: Text('Latest Date (Default)'),
              ),
              const PopupMenuItem(
                value: 'highest_price',
                child: Text('Highest Modal Price'),
              ),
              const PopupMenuItem(
                value: 'lowest_price',
                child: Text('Lowest Modal Price'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final districtLabel = (_district.isNotEmpty && _district != 'All Districts')
        ? 'in $_district ($_state)'
        : 'in $_state';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE2F5EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_outlined,
                size: 38,
                color: Color(0xFF0F4D33),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Mandi Records Found',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F4D33),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCommodity != 'All'
                  ? 'No market price records found for $_selectedCommodity $districtLabel.'
                  : 'No market price records found $districtLabel.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_selectedCommodity != 'All')
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F4D33),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedCommodity = 'All';
                        _searchController.clear();
                      });
                      _fetchPrices();
                    },
                    child: const Text('View All Crops'),
                  ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F4D33),
                    side: const BorderSide(color: Color(0xFF0F4D33)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _openLocationSelector,
                  child: const Text('Change State / District'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to Load Mandi Prices',
              style: TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F4D33),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Network error connecting to government data server.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F4D33),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              onPressed: _fetchPrices,
            ),
          ],
        ),
      ),
    );
  }
}
