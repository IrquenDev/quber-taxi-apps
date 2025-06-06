import 'package:flutter/material.dart';
import 'package:quber_taxi/common/models/travel.dart';
import 'package:quber_taxi/theme/dimensions.dart';

class TripCard extends StatelessWidget {

  final Travel travel;
  final void Function(Travel) onTravelSelected;

  const TripCard({super.key, required this.travel, required this.onTravelSelected});

  @override
  Widget build(BuildContext context) {
    final dimensions = Theme.of(context).extension<DimensionExtension>()!;
    return Card(
      elevation: dimensions.elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dimensions.borderRadius)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(dimensions.borderRadius))
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(dimensions.borderRadius))),
          tilePadding: dimensions.contentPadding,
          childrenPadding: dimensions.contentPadding,
          collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          backgroundColor: Theme.of(context).colorScheme.primaryFixed,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.0,
            children: [
              _buildIconLabelRow(context, Icons.my_location_outlined, "Desde: ", travel.originName),
              _buildIconLabelRow(context, Icons.location_on_outlined, "Hasta: ", travel.destinationName),
            ],
          ),
          children: [
            _buildInfoRow(Icons.straighten, 'Distancia Mínima: ${travel.minDistance} km'),
            _buildInfoRow(Icons.straighten, 'Distancia Máxima: ${travel.maxDistance} km'),
            _buildInfoRow(Icons.attach_money, 'Precio mínimo: ${travel.minPrice.toStringAsFixed(0)} CUP'),
            _buildInfoRow(Icons.money, 'Precio máximo: ${travel.maxPrice.toStringAsFixed(0)} CUP'),
            _buildInfoRow(Icons.people, '${travel.requiredSeats} personas'),
            _buildInfoRow(Icons.pets, travel.hasPets ? 'Con mascota' : 'Sin mascota'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => onTravelSelected.call(travel),
                child: const Text('Aceptar'),
              )
            )
          ]
        )
      )
    );
  }

  Widget _buildIconLabelRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      spacing: 8.0,
      children: [
        Icon(icon),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        spacing: 8.0,
        children: [Icon(icon), Expanded(child: Text(text))]
      )
    );
  }
}