import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:go_router/go_router.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/common/services/driver_service.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/driver_account_state.dart';
import 'package:quber_taxi/l10n/app_localizations.dart';
import 'package:quber_taxi/theme/dimensions.dart';
import 'package:quber_taxi/utils/runtime.dart';
import 'dart:async';

enum FilterType { name, phone, state }

class DriversListPage extends StatefulWidget {
  const DriversListPage({super.key});

  @override
  State<DriversListPage> createState() => _DriversListPageState();
}

class _DriversListPageState extends State<DriversListPage> {

  late Future _futureDrivers;
  final _accountService = AccountService();
  
  // Filter controllers and variables
  final _nameFilterController = TextEditingController();
  final _phoneFilterController = TextEditingController();
  DriverAccountState? _selectedStateFilter;
  List<Driver> _allDrivers = [];
  List<Driver> _filteredDrivers = [];
  FilterType? _expandedFilter;
  
  // Animation variables
  Timer? _animationTimer;
  int _currentFilterIndex = 0;
  bool _userInteracted = false;
  final List<FilterType> _filterOrder = [FilterType.name, FilterType.phone, FilterType.state];

  void _loadDrivers() => _futureDrivers = _accountService.findAllDrivers();

  Future<void> _refreshDrivers() async {
    final drivers = await _accountService.findAllDrivers();
    setState(() {
      _allDrivers = drivers;
      _filteredDrivers = drivers;
      _futureDrivers = Future.value(drivers);
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredDrivers = _allDrivers.where((driver) {
        // Filter by name
        final nameMatch = _nameFilterController.text.isEmpty ||
            driver.name.toLowerCase().contains(_nameFilterController.text.toLowerCase());
        
        // Filter by phone
        final phoneMatch = _phoneFilterController.text.isEmpty ||
            driver.phone.contains(_phoneFilterController.text);
        
        // Filter by state
        final stateMatch = _selectedStateFilter == null ||
            driver.accountState == _selectedStateFilter;
        
        return nameMatch && phoneMatch && stateMatch;
      }).toList();
    });
  }

  void _clearFilters() {
    _onUserInteraction();
    setState(() {
      _nameFilterController.clear();
      _phoneFilterController.clear();
      _selectedStateFilter = null;
      _expandedFilter = null;
    });
    _applyFilters();
  }

  void _toggleFilter(FilterType? filterType) {
    // Stop animation on any filter interaction
    _onUserInteraction();
    
    setState(() {
      _expandedFilter = _expandedFilter == filterType ? null : filterType;
    });
  }

  void _startAnimation() {
    if (_userInteracted) return; // Don't start if user has interacted
    
    _animationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _userInteracted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _expandedFilter = _filterOrder[_currentFilterIndex];
        _currentFilterIndex = (_currentFilterIndex + 1) % _filterOrder.length;
      });
    });
  }

  void _stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;
  }

  void _onTextChanged() {
    // Stop animation when user starts typing
    if (!_userInteracted) {
      _stopAnimation();
      _userInteracted = true;
    }
  }

  void _onUserInteraction() {
    // Stop animation on any user interaction with filters
    if (!_userInteracted) {
      _stopAnimation();
      _userInteracted = true;
    }
  }

  bool get _hasActiveFilters => 
    _nameFilterController.text.isNotEmpty ||
    _phoneFilterController.text.isNotEmpty ||
    _selectedStateFilter != null;

  @override
  void dispose() {
    _stopAnimation();
    _nameFilterController.removeListener(_onTextChanged);
    _phoneFilterController.removeListener(_onTextChanged);
    _nameFilterController.dispose();
    _phoneFilterController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDrivers();
    
    // Add listeners to text controllers to detect user interaction
    _nameFilterController.addListener(_onTextChanged);
    _phoneFilterController.addListener(_onTextChanged);
    
    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_userInteracted) {
        _startAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = Theme.of(context).extension<DimensionExtension>()?.borderRadius ?? 20.0;
    final colorScheme = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: colorScheme.surfaceContainer,
        body: Stack(
            children: [
              // "Appbar" Header
              Positioned(
                left: 0.0, right: 0.0, top: 0.0,
                child: Container(
                    height: 240,
                    decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius))
                    ),
                    child: SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 30, left: 20.0),
                          child: Row(
                            spacing: 8.0,
                            children: [
                              IconButton(icon: Icon(Icons.arrow_back_outlined), onPressed: context.pop),
                              Text(
                                  localizations.drivers,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold
                                  )
                              ),
                            ],
                          ),
                        )
                      )
                    )
                )
              ),
              Positioned(
                  top: 130.0, bottom: 20.0, right: 20.0, left: 20.0,
                  child: FutureBuilder(
                      future: _futureDrivers,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        else if(snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text(localizations.noDriversYet));
                        }
                        else {
                          final drivers = snapshot.data!;
                          // Initialize filtered drivers if not already done
                          if (_allDrivers.isEmpty) {
                            _allDrivers = drivers;
                            _filteredDrivers = drivers;
                          }
                          
                          return RefreshIndicator(
                            onRefresh: _refreshDrivers,
                            child: Column(
                              spacing: 8.0,
                              children: [
                                // Filters always visible
                                _buildFiltersRow(localizations, colorScheme, borderRadius),
                                // Clear filters text
                                if (_hasActiveFilters)
                                  GestureDetector(
                                    onTap: _clearFilters,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        localizations.clearFilters,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: colorScheme.error,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationColor: colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  ),
                                // Content area
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                                    child: _filteredDrivers.isEmpty
                                      ? Container(
                                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                                        child: Center(
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              _allDrivers.isEmpty
                                                ? localizations.noDriversYet
                                                : localizations.noDriversFound,
                                            ),
                                          ),
                                      )
                                      : ListView.separated(
                                        padding: EdgeInsets.zero,
                                        itemCount: _filteredDrivers.length,
                                        itemBuilder: (context, index) => Container(
                                          color: colorScheme.surfaceContainerLowest,
                                          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                          child: _buildDriverItem(_filteredDrivers[index]),
                                        ),
                                        separatorBuilder: (_, __) => Divider(
                                          height: 1.0, thickness: 3.0,
                                          color: Theme.of(context).colorScheme.surfaceContainer,
                                        ),
                                      ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                  )
              )
            ]
        )
    );
  }

  Widget _buildDriverItem(Driver driver) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              spacing: 12.0,
              children: [
                ClipOval(
                    child: SizedBox(
                        width: 80.0, height: 80.0,
                        child: Image.network('${ApiConfig().baseUrl}/${driver.taxi.imageUrl}', fit: BoxFit.cover)
                    )
                ),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8.0,
                      children: [
                        Text(
                          driver.name, 
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                            spacing: 8.0,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_outlined, size: 16),
                              Expanded(
                                child: Text(
                                  driver.phone,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ]
                        )
                      ]
                  ),
                ),
                Image.asset(DriverAccountState.imageOf(driver.accountState), width: 32, height: 32),
              ]
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                      onTap: () async {
                        if(!hasConnection(context)) return;
                        final response = await DriverService().changeState(driverId: driver.id);
                        if(!mounted) return;
                        if(response.statusCode == 200) {
                          _refreshDrivers();
                        }
                        else {
                          showToast(context: context, message: localizations.errorTryLater);
                        }
                      },
                      child: Text(
                          switch (driver.accountState) {
                            DriverAccountState.notConfirmed => localizations.confirmAccount,
                            DriverAccountState.canPay => localizations.confirmPayment,
                            DriverAccountState.paymentRequired => localizations.confirmPayment,
                            DriverAccountState.enabled => localizations.blockAccount,
                            DriverAccountState.disabled => localizations.enableAccount
                          },
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primaryContainer
                          )
                      )
                  )
              )
          )
        ]
    );
  }

  Widget _buildFiltersRow(AppLocalizations localizations, ColorScheme colorScheme, double borderRadius) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Name filter
        AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          width: _expandedFilter == FilterType.name ? 200 : 60,
          child: GestureDetector(
            onTap: () => _toggleFilter(FilterType.name),
            child: Card(
              color: colorScheme.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                padding: _expandedFilter == FilterType.name
                  ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
                  : const EdgeInsets.all(12.0),
                child: _expandedFilter == FilterType.name
                  ? SizedBox(
                      height: 36,
                      child: TextFormField(
                        controller: _nameFilterController,
                        style: Theme.of(context).textTheme.bodySmall,
                        decoration: InputDecoration(
                          hintText: localizations.filterByName,
                          hintStyle: Theme.of(context).textTheme.bodySmall,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerLowest,
                        ),
                        onChanged: (_) => _applyFilters(),
                      ),
                    )
                  : Icon(
                      Icons.person_search_outlined,
                      color: colorScheme.primary,
                      size: 24,
                    ),
              ),
            ),
          ),
        ),
        // Phone filter
        AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          width: _expandedFilter == FilterType.phone ? 200 : 60,
          child: GestureDetector(
            onTap: () => _toggleFilter(FilterType.phone),
            child: Card(
              color: colorScheme.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                padding: _expandedFilter == FilterType.phone
                  ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
                  : const EdgeInsets.all(12.0),
                child: _expandedFilter == FilterType.phone
                  ? SizedBox(
                      height: 36,
                      child: TextFormField(
                        controller: _phoneFilterController,
                        style: Theme.of(context).textTheme.bodySmall,
                        decoration: InputDecoration(
                          hintText: localizations.filterByPhone,
                          hintStyle: Theme.of(context).textTheme.bodySmall,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(borderRadius),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerLowest,
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (_) => _applyFilters(),
                      ),
                    )
                  : Icon(
                      Icons.phone_outlined,
                      color: colorScheme.primary,
                      size: 24,
                    ),
              ),
            ),
          ),
        ),
        // State filter
        AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut,
          width: _expandedFilter == FilterType.state ? 200 : 60,
          child: GestureDetector(
            onTap: () => _toggleFilter(FilterType.state),
            child: Card(
              color: colorScheme.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                padding: _expandedFilter == FilterType.state
                  ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
                  : const EdgeInsets.all(12.0),
                child: _expandedFilter == FilterType.state
                  ? ClipRect(
                      child: SizedBox(
                        height: 36,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<DriverAccountState?>(
                            value: _selectedStateFilter,
                            isExpanded: true,
                            isDense: true,
                            menuMaxHeight: 200,
                            decoration: InputDecoration(
                              hintText: localizations.filterByState,
                              hintStyle: Theme.of(context).textTheme.bodySmall,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(borderRadius),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerLowest,
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                            items: [
                              DropdownMenuItem<DriverAccountState?>(
                                value: null,
                                child: Text(
                                  localizations.allStates,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              ...DriverAccountState.values.map((state) =>
                                DropdownMenuItem<DriverAccountState?>(
                                  value: state,
                                  child: Text(
                                    DriverAccountState.nameOf(state, localizations),
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ),
                            ],
                                                    onChanged: (value) {
                          _onUserInteraction();
                          setState(() {
                            _selectedStateFilter = value;
                          });
                          _applyFilters();
                        },
                          ),
                        ),
                      ),
                    )
                  : Icon(
                      Icons.filter_list_outlined,
                      color: colorScheme.primary,
                      size: 24,
                    ),
              ),
            ),
          ),
        ),

      ]
    );
  }
}