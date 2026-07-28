import 'package:flutter/material.dart';
import '../widgets/player_deck.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
      body: const PlayerDeck(),
    );
  }
}