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
    setState(() {
      _nameFilterController.clear();
      _phoneFilterController.clear();
      _selectedStateFilter = null;
      _expandedFilter = null;
    });
    _applyFilters();
  }

  void _toggleFilter(FilterType? filterType) {
    setState(() {
      _expandedFilter = _expandedFilter == filterType ? null : filterType;
    });
  }

  @override
  void dispose() {
    _nameFilterController.dispose();
    _phoneFilterController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDrivers();
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
                  top: 140.0, bottom: 20.0, right: 20.0, left: 20.0,
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
                              spacing: 12.0,
                              children: [
                                // Filters always visible
                                _buildFiltersRow(localizations, colorScheme, borderRadius),
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
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.0,
                    children: [
                      Text(driver.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Row(
                          spacing: 8.0,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone_outlined),
                            Text(driver.phone)
                          ]
                      )
                    ]
                ),
                Spacer(),
                Icon(DriverAccountState.iconOf(driver.accountState)),
                Spacer()
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
        Expanded(
          flex: _expandedFilter == FilterType.name ? 3 : 1,
          child: GestureDetector(
            onTap: () => _toggleFilter(FilterType.name),
            child: Card(
              color: colorScheme.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Padding(
                padding: _expandedFilter == FilterType.name
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(12.0),
                child: _expandedFilter == FilterType.name
                  ? TextFormField(
                      controller: _nameFilterController,
                      decoration: InputDecoration(
                        hintText: localizations.filterByName,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                      ),
                      onChanged: (_) => _applyFilters(),
                    )
                  : Icon(
                      Icons.person_search_outlined,
                      color: colorScheme.primary,
                    ),
              ),
            ),
          ),
        ),
        // Phone filter
        Expanded(
          flex: _expandedFilter == FilterType.phone ? 3 : 1,
          child: GestureDetector(
            onTap: () => _toggleFilter(FilterType.phone),
            child: Card(
              color: colorScheme.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Padding(
                padding: _expandedFilter == FilterType.phone
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(12.0),
                child: _expandedFilter == FilterType.phone
                  ? TextFormField(
                      controller: _phoneFilterController,
                      decoration: InputDecoration(
                        hintText: localizations.filterByPhone,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => _applyFilters(),
                    )
                  : Icon(
                      Icons.phone_outlined,
                      color: colorScheme.primary,
                    ),
              ),
            ),
          ),
        ),
        // State filter
        Expanded(
          flex: _expandedFilter == FilterType.state ? 3 : 1,
          child: GestureDetector(
            onTap: () => _toggleFilter(FilterType.state),
            child: Card(
              color: colorScheme.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Padding(
                padding: _expandedFilter == FilterType.state
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(12.0),
                child: _expandedFilter == FilterType.state
                  ? DropdownButtonFormField<DriverAccountState?>(
                      value: _selectedStateFilter,
                      decoration: InputDecoration(
                        hintText: localizations.filterByState,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.only(left: 4.0),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLowest,
                      ),
                      items: [
                        DropdownMenuItem<DriverAccountState?>(
                          value: null,
                          child: Text(localizations.allStates),
                        ),
                        ...DriverAccountState.values.map((state) =>
                          DropdownMenuItem<DriverAccountState?>(
                            value: state,
                            child: Text(DriverAccountState.nameOf(state, localizations)),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStateFilter = value;
                        });
                        _applyFilters();
                      },
                    )
                  : Icon(
                      Icons.filter_list_outlined,
                      color: colorScheme.primary,
                    ),
              ),
            ),
          ),
        ),
        // Clear filters
        GestureDetector(
          onTap: _clearFilters,
          child: Card(
            color: colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                Icons.clear_outlined,
                color: colorScheme.error,
              )
            )
          )
        )
      ]
    );
  }
}