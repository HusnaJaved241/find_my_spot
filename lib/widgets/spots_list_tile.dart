import 'dart:io';

import 'package:find_my_spot/models/spot_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class SpotsListTile extends StatelessWidget {
  final Spot spot;

  const SpotsListTile({super.key, required this.spot});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMMM d, y').format(spot.createdAt);

    return InkWell(
      onTap: () => Navigator.pop(context, spot),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 10),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(spot.imagePaths.first),
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spot.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      spot.description,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  SharePlus.instance.share(
                    ShareParams(text: '${spot.latitude} - ${spot.longitude}'),
                  );
                  // Share.share('${spot.latitude} - ${spot.longitude}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
