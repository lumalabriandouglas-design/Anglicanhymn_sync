import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/hymn.dart';
import '../../../providers/hymn_provider.dart';

class PickHymnSheet extends StatefulWidget {
  const PickHymnSheet({super.key});

  @override
  State<PickHymnSheet> createState() => _PickHymnSheetState();
}

class _PickHymnSheetState extends State<PickHymnSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final hymns = context.watch<HymnProvider>();
    final q = _query.trim().toLowerCase();
    final results = q.isEmpty
        ? hymns.allHymns
        : hymns.allHymns.where((h) {
            return h.number.contains(q) ||
                h.title.toLowerCase().contains(q) ||
                h.titleEnglish.toLowerCase().contains(q);
          }).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search number or title',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final Hymn hymn = results[index];
                  return ListTile(
                    leading: Text(
                      hymn.number,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    title: Text(hymn.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: hymn.hasEnglishTitle
                        ? Text(hymn.titleEnglish, maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                    onTap: () => Navigator.pop(context, hymn),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
