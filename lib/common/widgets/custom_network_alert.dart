import 'package:flutter/material.dart';
import 'package:network_checker/network_checker.dart';

// TODO("yapmDev": @Reminder)
// - Adjust text, styles etc
class CustomNetworkAlert extends StatelessWidget {
  final ConnectionStatus status;
  final bool useTopSafeArea;

  const CustomNetworkAlert({
    super.key,
    required this.status,
    this.useTopSafeArea = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: useTopSafeArea,
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.none,
        child: Container(
          margin: const EdgeInsets.all(12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: _backgroundColor(context),
          ),
          child: Row(
            children: [
              _icon(context),
              const SizedBox(width: 12),
              Expanded(child: _message(context)),
              if (_showRetryButton)
                IconButton(
                  onPressed: NetworkScope.of(context).forceRetry,
                  icon: Icon(Icons.refresh_outlined, color: _foregroundColor(context)),
                  tooltip: "Retry connection",
                )
            ]
          )
        )
      )
    );
  }

  Color _backgroundColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    switch (status) {
      case ConnectionStatus.checking:
        return colors.primaryContainer;
      case ConnectionStatus.noInternet:
        return colors.error;
      case ConnectionStatus.serverUnreachable:
      case ConnectionStatus.networkUnreachable:
        return colors.tertiaryContainer;
      case ConnectionStatus.serverError:
      case ConnectionStatus.clientError:
      case ConnectionStatus.unexpectedResponse:
      case ConnectionStatus.unknownFailure:
        return colors.secondaryContainer;
      default:
        return colors.surfaceContainerHighest;
    }
  }

  Color _foregroundColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    switch (status) {
      case ConnectionStatus.noInternet:
        return colors.onError;
      case ConnectionStatus.checking:
      case ConnectionStatus.serverUnreachable:
      case ConnectionStatus.networkUnreachable:
        return colors.onTertiaryContainer;
      default:
        return colors.onSecondaryContainer;
    }
  }

  Widget _icon(BuildContext context) {
    final color = _foregroundColor(context);
    switch (status) {
      case ConnectionStatus.checking:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(color)),
        );
      case ConnectionStatus.noInternet:
        return Icon(Icons.wifi_off_rounded, color: color);
      case ConnectionStatus.serverUnreachable:
        return Icon(Icons.cloud_off_rounded, color: color);
      case ConnectionStatus.networkUnreachable:
        return Icon(Icons.router_outlined, color: color);
      case ConnectionStatus.serverError:
        return Icon(Icons.error_outline_rounded, color: color);
      case ConnectionStatus.clientError:
        return Icon(Icons.lock_outline_rounded, color: color);
      case ConnectionStatus.unexpectedResponse:
      case ConnectionStatus.unknownFailure:
        return Icon(Icons.help_outline_rounded, color: color);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _message(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: _foregroundColor(context));
    final msg = switch (status) {
      ConnectionStatus.checking => "Verificando el estado de la red...",
      ConnectionStatus.noInternet => "Sin conexión a internet. Algunas funciones podrían no estar disponibles.",
      ConnectionStatus.serverUnreachable => "Nuestro servidor está teniendo problemas, le notificaremos "
          "enseguida.",
      ConnectionStatus.networkUnreachable => "Red inaccesible. Puede que un firewall o VPN esté bloqueando el acceso.",
      ConnectionStatus.serverError => "Ocurrió un error en el servidor. Intenta nuevamente más tarde.",
      ConnectionStatus.clientError => "Acceso denegado o no autorizado. Verifica tus credenciales.",
      ConnectionStatus.unexpectedResponse => "Respuesta inesperada del servidor.",
      ConnectionStatus.unknownFailure => "Ocurrió un error desconocido.",
      _ => "Se ha detectado un problema de conectividad.",
    };
    return Text(msg, style: textStyle);
  }

  bool get _showRetryButton {
    return switch (status) {
      ConnectionStatus.checking => false,
      _ => true,
    };
  }
}