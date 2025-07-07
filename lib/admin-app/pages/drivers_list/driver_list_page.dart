import 'package:flutter/material.dart';
import 'package:flutter_fusion/flutter_fusion.dart';
import 'package:network_checker/network_checker.dart';
import 'package:quber_taxi/common/models/driver.dart';
import 'package:quber_taxi/common/services/account_service.dart';
import 'package:quber_taxi/common/services/driver_service.dart';
import 'package:quber_taxi/config/api_config.dart';
import 'package:quber_taxi/enums/driver_account_state.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class DriversListPage extends StatefulWidget {
  const DriversListPage({super.key});

  @override
  State<DriversListPage> createState() => _DriversListPageState();
}

class _DriversListPageState extends State<DriversListPage> {

  late Future _futureDrivers;
  final _accountService = AccountService();

  void _loadDrivers() => _futureDrivers = _accountService.findAllDrivers();

  Future<void> _refreshDrivers() async {
    final drivers = await _accountService.findAllDrivers();
    setState(() {
      _futureDrivers = Future.value(drivers);
    });
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
    return Scaffold(
        backgroundColor: colorScheme.surfaceContainer,
        body: Stack(
            children: [
              // "Appbar" Header
              Positioned(
                left: 0.0, right: 0.0, top: 0.0,
                child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(borderRadius))
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                              'Conductores',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.secondary
                              )
                          )
                      ),
                    )
                ),
              ),
              Positioned(
                  top: 140.0, bottom: 20.0, right: 20.0, left: 20.0,
                  child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                      child: Container(
                        color: colorScheme.surface,
                        child: FutureBuilder(
                            future: _futureDrivers,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              else if(snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                                return Center(child: Text("Aún no hay conductores"));
                              }
                              else {
                                final drivers = snapshot.data!;
                                return RefreshIndicator(
                                  onRefresh: _refreshDrivers,
                                  child: ListView.separated(
                                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                                      itemCount: drivers.length,
                                      itemBuilder: (context, index) => _buildDriverItem(drivers[index]),
                                      separatorBuilder: (_, __) => Divider()
                                  ),
                                );
                              }
                            }
                        ),
                      )
                  )
              )
            ]
        )
    );
  }

  Widget _buildDriverItem(Driver driver) {
    final isConnected = NetworkScope.statusOf(context) == ConnectionStatus.online;
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
                    child: Image.network('${ApiConfig().baseUrl}${driver.taxi.imageUrl}', fit: BoxFit.cover)
                )
            ),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8.0,
                children: [
                  Text(driver.name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text(driver.phone)
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
                  if(!isConnected) return;
                  final newState = driver.accountState != DriverAccountState.enabled
                      ? DriverAccountState.enabled
                      : DriverAccountState.disabled;
                  final response = await DriverService().changeState(driverId: driver.id, state: newState);
                  if(!mounted) return;
                  if(response.statusCode == 200) {
                    _refreshDrivers();
                  }
                  else {
                    showToast(context: context, message: "Algo salió mal, por favor inténtelo más tarde");
                  }
                },
                child: Text(
                    switch (driver.accountState) {
                      DriverAccountState.notConfirmed => "Confirmar Cuenta",
                      DriverAccountState.paymentRequired => "Confirmar Pago",
                      DriverAccountState.enabled => "Bloquear cuenta",
                      DriverAccountState.disabled => "Habilitar cuenta",
                    },
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primaryContainer
                    )
                )
            ),
          ),
        )
      ]
    );
  }
}