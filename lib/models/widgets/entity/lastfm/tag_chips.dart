import 'package:flutter/material.dart';

import '../../../services/lastfm/common.dart';

class TagChips extends StatelessWidget {
  final LTopTags topTags;

  const TagChips({super.key, required this.topTags});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (final tag in topTags.tags)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Chip(label: Text(tag.name)),
              ),
          ],
        ),
      );
}
