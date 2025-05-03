import 'package:find_my_spot/providers/spots_provider.dart';
import 'package:find_my_spot/widgets/spots_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpotScreen extends StatelessWidget {
  const SpotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SpotsProvider>(context, listen: false).fetchSpots();
    });
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorite Spots'), centerTitle: true),
      body: Consumer<SpotsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          final spots = provider.spots;
          if (spots.isEmpty) {
            return const Center(child: Text('No Spots saved yet!!!'));
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              return SpotsListTile(spot: spots[index]);
            },
            itemCount: spots.length,
          );
        },
      ),
    );
  }
}
