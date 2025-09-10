
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TrendingMusicScreen extends StatefulWidget {
  const TrendingMusicScreen({super.key});

  @override
  State<TrendingMusicScreen> createState() => _TrendingMusicScreenState();
}

class _TrendingMusicScreenState extends State<TrendingMusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlaying;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Music'),
      ),
      body: ListView.builder(
        itemCount: 20, // Replace with actual music list
        itemBuilder: (context, index) {
          final songUrl = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-${index + 1}.mp3'; // Dummy URL
          final isPlaying = _currentlyPlaying == songUrl;

          return ListTile(
            leading: const Icon(Icons.music_note),
            title: Text('Song Title ${index + 1}'),
            subtitle: Text('Artist Name ${index + 1}'),
            trailing: IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (isPlaying) {
                  _audioPlayer.pause();
                  setState(() {
                    _currentlyPlaying = null;
                  });
                } else {
                  _audioPlayer.play(UrlSource(songUrl));
                  setState(() {
                    _currentlyPlaying = songUrl;
                  });
                }
              },
            ),
            onTap: () {
              Navigator.of(context).pop('Song Title ${index + 1}');
            },
          );
        },
      ),
    );
  }
}
