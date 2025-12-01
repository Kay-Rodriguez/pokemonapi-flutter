import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(PokemonApp());
}

class PokemonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon & Public APIs',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [PokemonPage(), ArtInstitutePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.catching_pokemon), label: 'Pokémon'),
          BottomNavigationBarItem(icon: Icon(Icons.brush), label: 'Art Institute'),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class PokemonPage extends StatefulWidget {
  @override
  _PokemonPageState createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _pokemon;
  String? _error;

  // For list view
  List<Map<String, dynamic>> _pokemonList = [];
  bool _listLoading = false;

  Future<void> fetchPokemonByName(String name) async {
    if (name.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _pokemon = null;
    });

    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/${name.toLowerCase().trim()}');
    try {
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _pokemon = data;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Pokémon no encontrado (status ${res.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de red: $e';
        _loading = false;
      });
    }
  }

  Future<void> fetchPokemonList([int limit = 50]) async {
    setState(() {
      _listLoading = true;
    });
    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List results = data['results'];
        // Extract name and id from url
        final parsed = results.map<Map<String, dynamic>>((p) {
          final name = p['name'];
          final url = p['url'] as String;
          final segments = url.split('/');
          final idStr = segments.where((s) => s.isNotEmpty).last;
          final id = int.tryParse(idStr) ?? 0;
          final thumb = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';
          return {'name': name, 'url': url, 'id': id, 'thumb': thumb};
        }).toList();
        setState(() {
          _pokemonList = parsed;
          _listLoading = false;
        });
      } else {
        setState(() {
          _listLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _listLoading = false;
      });
    }
  }

  Widget _buildPokemonDetails() {
    if (_loading) return Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: TextStyle(color: Colors.red)));
    if (_pokemon == null) return Center(child: Text('Busca un Pokémon por nombre (p.ej. ditto).'));

    final name = _pokemon!['name'] ?? '';
    final height = _pokemon!['height'] ?? '';
    final weight = _pokemon!['weight'] ?? '';
    final types = (_pokemon!['types'] as List).map((t) => t['type']['name']).join(', ');
    final abilities = (_pokemon!['abilities'] as List).map((a) => a['ability']['name']).join(', ');
    // Try official artwork first, then sprites.front_default
    String? imageUrl;
    try {
      imageUrl = _pokemon!['sprites']?['other']?['official-artwork']?['front_default'] ?? _pokemon!['sprites']?['front_default'];
    } catch (e) {
      imageUrl = null;
    }

    final stats = (_pokemon!['stats'] as List)
        .map((s) => '${s['stat']['name']}: ${s['base_stat']}')
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: imageUrl != null
                ? Image.network(imageUrl, height: 200, fit: BoxFit.contain)
                : Icon(Icons.image_not_supported, size: 100),
          ),
          SizedBox(height: 12),
          Text(name.toString().toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Height: $height  •  Weight: $weight'),
          SizedBox(height: 8),
          Text('Types: $types'),
          SizedBox(height: 8),
          Text('Abilities: $abilities'),
          SizedBox(height: 12),
          Text('Stats', style: TextStyle(fontWeight: FontWeight.bold)),
          ...stats.map((s) => Text(s)).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pokémon - Lista y Buscar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: 'Nombre del Pokémon (p.ej. ditto)'),
                    onSubmitted: fetchPokemonByName,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => fetchPokemonByName(_controller.text),
                  child: Text('Buscar'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => fetchPokemonList(100),
                  child: Text('Cargar lista'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _pokemon != null || _loading || _error != null
                ? _buildPokemonDetails()
                : (_listLoading
                    ? Center(child: CircularProgressIndicator())
                    : _pokemonList.isEmpty
                        ? Center(child: Text('Pulsa "Cargar lista" o busca un Pokémon'))
                        : ListView.builder(
                            itemCount: _pokemonList.length,
                            itemBuilder: (context, index) {
                              final p = _pokemonList[index];
                              return ListTile(
                                leading: Image.network(p['thumb'], width: 56, height: 56, errorBuilder: (c, e, s) => Icon(Icons.image_not_supported)),
                                title: Text(p['name']),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PokemonDetailPage(name: p['name']))),
                              );
                            },
                          )),
          ),
        ],
      ),
    );
  }
}

class PokemonDetailPage extends StatefulWidget {
  final String name;
  const PokemonDetailPage({required this.name});
  @override
  _PokemonDetailPageState createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  bool _loading = true;
  Map<String, dynamic>? _pokemon;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.name}'));
      if (res.statusCode == 200) {
        setState(() {
          _pokemon = json.decode(res.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'No encontrado';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (_pokemon != null)
                      ...[
                        Center(
                          child: Image.network(
                            _pokemon!['sprites']?['other']?['official-artwork']?['front_default'] ?? _pokemon!['sprites']?['front_default'] ?? '',
                            height: 220,
                            fit: BoxFit.contain,
                            errorBuilder: (c, e, s) => Icon(Icons.image_not_supported, size: 100),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(_pokemon!['name'].toString().toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('Height: ${_pokemon!['height']}  •  Weight: ${_pokemon!['weight']}'),
                      ]
                  ]),
                ),
    );
  }
}

class ArtInstitutePage extends StatefulWidget {
  @override
  _ArtInstitutePageState createState() => _ArtInstitutePageState();
}

class _ArtInstitutePageState extends State<ArtInstitutePage> {
  bool _loading = false;
  Map<String, dynamic>? _artwork;
  String? _error;
  List<dynamic> _artworksList = [];
  bool _listLoading = false;

  Future<void> fetchRandomArtwork() async {
    setState(() {
      _loading = true;
      _error = null;
      _artwork = null;
    });

    try {
      // Fetch a first page of artworks and pick a random one
      final res = await http.get(Uri.parse('https://api.artic.edu/api/v1/artworks?page=1&limit=100'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List artworks = data['data'] ?? [];
        if (artworks.isEmpty) {
          setState(() {
            _error = 'No se encontraron obras.';
            _loading = false;
          });
          return;
        }
        final rnd = Random();
        final chosen = artworks[rnd.nextInt(artworks.length)];
        setState(() {
          _artwork = chosen;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Error API: ${res.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de red: $e';
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Optionally fetch list at start
    fetchArtworksList();
  }

  Future<void> fetchArtworksList() async {
    setState(() {
      _listLoading = true;
    });
    try {
      final res = await http.get(Uri.parse('https://api.artic.edu/api/v1/artworks?page=1&limit=50&fields=id,title,image_id,artist_title,date_display,thumbnail,medium_display'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          _artworksList = data['data'] ?? [];
          _listLoading = false;
        });
      } else {
        setState(() {
          _listLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _listLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    if (_artwork != null) {
      final imageId = _artwork!['image_id'];
      if (imageId != null) {
        imageUrl = 'https://www.artic.edu/iiif/2/$imageId/full/843,/0/default.jpg';
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Art Institute of Chicago - Obra aleatoria')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton(onPressed: fetchRandomArtwork, child: Text('Obra aleatoria')),
                SizedBox(width: 12),
                ElevatedButton(onPressed: fetchArtworksList, child: Text('Cargar lista')),
                SizedBox(width: 12),
                if (_loading) CircularProgressIndicator()
              ],
            ),
            SizedBox(height: 12),
            if (_error != null) Text(_error!, style: TextStyle(color: Colors.red)),
            Expanded(
              child: _artwork != null
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageUrl != null) Center(child: Image.network(imageUrl, fit: BoxFit.contain)),
                          SizedBox(height: 8),
                          Text(_artwork!['title'] ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Artist: ${_artwork!['artist_title'] ?? 'Unknown'}'),
                          SizedBox(height: 4),
                          Text('Date: ${_artwork!['date_display'] ?? 'Unknown'}'),
                          SizedBox(height: 8),
                          Text('Medium: ${_artwork!['medium_display'] ?? 'Unknown'}'),
                        ],
                      ),
                    )
                  : (_listLoading
                      ? Center(child: CircularProgressIndicator())
                      : (_artworksList.isEmpty
                          ? Center(child: Text('Pulsa "Cargar lista" o "Obra aleatoria" para comenzar'))
                          : GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.8),
                              itemCount: _artworksList.length,
                              itemBuilder: (context, index) {
                                final a = _artworksList[index];
                                final id = a['id'];
                                final imageId = a['image_id'];
                                final thumb = imageId != null ? 'https://www.artic.edu/iiif/2/$imageId/full/200,/0/default.jpg' : null;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _artwork = a;
                                    });
                                  },
                                  child: Card(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: thumb != null
                                              ? Image.network(thumb, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.image_not_supported))
                                              : Icon(Icons.image_not_supported),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(a['title'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ))),
            ),
          ],
        ),
      ),
    );
  }
}