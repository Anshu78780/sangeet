import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../models/song.dart';
import '../services/suggestion_service.dart';
import '../player/player_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Timer? _suggestionDebounce;
  bool _isLoading = false;
  String? _error;
  String _activeQuery = '';
  List<String> _suggestions = const [];
  List<_SearchItem> _results = const [];

  static const _quickTerms = [
    'lofi',
    'arijit singh',
    'night drive',
    'edm remix',
    'phonk',
    'bollywood hits',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _suggestionDebounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _fetchResults(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      setState(() {
        _activeQuery = '';
        _results = const [];
        _error = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _activeQuery = normalized;
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse('https://vibra-server-v33i.onrender.com/search?q=${Uri.encodeQueryComponent(normalized)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        setState(() {
          _error = 'Failed to fetch results (${response.statusCode})';
          _isLoading = false;
        });
        return;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final songsRaw = (decoded['songs'] as List<dynamic>? ?? const []);

      final items = songsRaw
          .map((raw) => _SearchItem.fromJson(raw as Map<String, dynamic>))
          .where((item) => item.song.id.isNotEmpty)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _results = items;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Could not load search results. Try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSuggestions(String query) async {
    _suggestionDebounce?.cancel();
    _suggestionDebounce = Timer(const Duration(milliseconds: 260), () async {
      final suggestions = await SuggestionService.getSuggestions(query);
      if (!mounted || query.trim() != _searchController.text.trim()) {
        return;
      }
      setState(() {
        _suggestions = suggestions;
      });
    });
  }

  void _onSubmitted(String query) {
    _focusNode.unfocus();
    _fetchResults(query);
  }

  void _onSuggestionTap(String suggestion) {
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.collapsed(offset: suggestion.length);
    _fetchResults(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final playlist = _results.map((item) => item.song).toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1015),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF101722),
                Color(0xFF0D1015),
              ],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _onSubmitted,
                        onChanged: (value) {
                          _updateSuggestions(value);
                          if (value.trim().isEmpty) {
                            setState(() {
                              _activeQuery = '';
                              _results = const [];
                              _suggestions = const [];
                              _error = null;
                            });
                          }
                        },
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search songs, artists, moods',
                          hintStyle: GoogleFonts.outfit(color: Colors.white38),
                          prefixIcon: const Icon(Icons.search, color: Colors.white70),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _activeQuery = '';
                                      _results = const [];
                                      _suggestions = const [];
                                      _error = null;
                                    });
                                  },
                                  icon: const Icon(Icons.close, color: Colors.white70),
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFF1B222E),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_searchController.text.trim().isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickTerms
                        .map(
                          (term) => InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => _onSuggestionTap(term),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF19202A),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: const Color(0xFF243141)),
                              ),
                              child: Text(
                                term,
                                style: GoogleFonts.outfit(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              if (_suggestions.isNotEmpty && _activeQuery.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141B26),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: _suggestions
                        .map(
                          (s) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.north_west_rounded, color: Colors.white38),
                            title: Text(
                              s,
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                            ),
                            onTap: () => _onSuggestionTap(s),
                          ),
                        )
                        .toList(),
                  ),
                ),
              if (_activeQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
                  child: Row(
                    children: [
                      Text(
                        'Results for "$_activeQuery"',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFF1AE3B0)),
                      )
                    : _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              style: GoogleFonts.outfit(color: Colors.redAccent),
                            ),
                          )
                        : _activeQuery.isEmpty
                            ? Center(
                                child: Text(
                                  'Search tracks you love',
                                  style: GoogleFonts.outfit(color: Colors.white38),
                                ),
                              )
                            : _results.isEmpty
                                ? Center(
                                    child: Text(
                                      'No songs found',
                                      style: GoogleFonts.outfit(color: Colors.white54),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                                    itemCount: _results.length,
                                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                                    itemBuilder: (context, index) {
                                      final item = _results[index];
                                      final heroTag = 'search_album_art_${item.song.id}_$index';

                                      return Material(
                                        color: const Color(0xFF131A24),
                                        borderRadius: BorderRadius.circular(14),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(14),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PlayerScreen(
                                                  song: item.song,
                                                  heroTag: heroTag,
                                                  playlist: playlist,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              children: [
                                                Hero(
                                                  tag: heroTag,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: Image.network(
                                                      item.song.thumbnail,
                                                      width: 56,
                                                      height: 56,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) => Container(
                                                        width: 56,
                                                        height: 56,
                                                        color: const Color(0xFF263246),
                                                        child: const Icon(Icons.music_note, color: Colors.white54),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        item.song.title,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.outfit(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        item.song.artist,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: GoogleFonts.outfit(
                                                          color: Colors.white60,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  item.durationString,
                                                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchItem {
  final Song song;
  final String durationString;

  _SearchItem({required this.song, required this.durationString});

  factory _SearchItem.fromJson(Map<String, dynamic> json) {
    return _SearchItem(
      song: Song.fromJson(json),
      durationString: (json['duration_string'] as String?) ?? '--:--',
    );
  }
}