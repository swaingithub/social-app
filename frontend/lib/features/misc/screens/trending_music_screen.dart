
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'package:jivvi/core/services/api_service.dart';

class TrendingMusicScreen extends StatefulWidget {
  const TrendingMusicScreen({super.key});

  @override
  State<TrendingMusicScreen> createState() => _TrendingMusicScreenState();
}

class _TrendingMusicScreenState extends State<TrendingMusicScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TextEditingController _searchController = TextEditingController();
  final ApiService _api = ApiService();
  List<dynamic> _tracks = [];
  String? _currentlyPlaying;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchTrendingMusic();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _searchMusic(_searchController.text);
      } else {
        _fetchTrendingMusic();
      }
    });
  }

  Future<void> _fetchTrendingMusic() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${_api.baseUrl}/spotify/trending'));

      if (response.statusCode == 200) {
        setState(() {
          _tracks = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchMusic(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${_api.baseUrl}/spotify/search?q=$query'));

      if (response.statusCode == 200) {
        setState(() {
          _tracks = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a song...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _fetchTrendingMusic();
                  },
                ),
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: _tracks.length,
                    itemBuilder: (context, index) {
                      final track = _tracks[index];
                      final isPlaying = _currentlyPlaying == track['previewUrl'];

                      return ListTile(
                        leading: track['albumArt'] != ''
                            ? Image.network(track['albumArt'])
                            : const Icon(Icons.music_note),
                        title: Text(track['title']),
                        subtitle: Text(track['artist']),
                        trailing: IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            if (track['previewUrl'] != null) {
                              if (isPlaying) {
                                _audioPlayer.pause();
                                setState(() {
                                  _currentlyPlaying = null;
                                });
                              } else {
                                _audioPlayer.play(UrlSource(track['previewUrl']));
                                setState(() {
                                  _currentlyPlaying = track['previewUrl'];
                                });
                              }
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).pop(track);
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
