import 'package:flutter/material.dart';
import 'package:quber_taxi/enums/municipalities.dart';

class SearchDestinationPage extends StatefulWidget {
  const SearchDestinationPage({super.key});

  @override
  State<SearchDestinationPage> createState() => _SearchOriginPageState();
}

class _SearchOriginPageState extends State<SearchDestinationPage> {

  final _controller = TextEditingController();

  final List<String> _municipalityNames = Municipalities.values.map((mun)=> mun.name).toList();
  List<String> _suggestions = [];

  void _onTextChanged(String query) {
    final filteredNames = _municipalityNames.where((mun) => mun.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() => _suggestions = filteredNames);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: TextField(
              controller: _controller,
              onChanged: _onTextChanged,
              decoration: InputDecoration(
                  hintText: 'Escribe una ubicación...',
                  suffixIcon: _controller.text.isNotEmpty ?
                  IconButton(icon: const Icon(Icons.clear_outlined), onPressed: () {
                    _controller.clear();
                    setState(() => _suggestions = _municipalityNames);
                  }) : null
              )
          )
      ),
      body: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final item = _suggestions[index];
                      return ListTile(
                        title: Text(item),
                        onTap: () => Navigator.of(context).pop(item),
                      );
                    }
                )
            )
          ]
      ),
    );
  }
}