import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../api/bb_api.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  String? registrationResult;
  List<String> selectedGenres = [];
  bool _isSussces = false;
  final List<String> genres = [
    "acoustic",
    "afrobeat",
    "alt-rock",
    "alternative",
    "ambient",
    "anime",
    "black-metal",
    "bluegrass",
    "blues",
    "bossanova",
    "brazil",
    "breakbeat",
    "british",
    "cantopop",
    "chicago-house",
    "children",
    "chill",
    "classical",
    "club",
    "comedy",
    "country",
    "dance",
    "dancehall",
    "death-metal",
    "deep-house",
    "detroit-techno",
    "disco",
    "disney",
    "drum-and-bass",
    "dub",
    "dubstep",
    "edm",
    "electro",
    "electronic",
    "emo",
    "folk",
    "forro",
    "french",
    "funk",
    "garage",
    "german",
    "gospel",
    "goth",
    "grindcore",
    "groove",
    "grunge",
    "guitar",
    "happy",
    "hard-rock",
    "hardcore",
    "hardstyle",
    "heavy-metal",
    "hip-hop",
    "holidays",
    "honky-tonk",
    "house",
    "idm",
    "indian",
    "indie",
    "indie-pop",
    "industrial",
    "iranian",
    "j-dance",
    "j-idol",
    "j-pop",
    "j-rock",
    "jazz",
    "k-pop",
    "kids",
    "latin",
    "latino",
    "malay",
    "mandopop",
    "metal",
    "metal-misc",
    "metalcore",
    "minimal-techno",
    "movies",
    "mpb",
    "new-age",
    "new-release",
    "opera",
    "pagode",
    "party",
    "philippines-opm",
    "piano",
    "pop",
    "pop-film",
    "post-dubstep",
    "power-pop",
    "progressive-house",
    "psych-rock",
    "punk",
    "punk-rock",
    "r-n-b",
    "rainy-day",
    "reggae",
    "reggaeton",
    "road-trip",
    "rock",
    "rock-n-roll",
    "rockabilly",
    "romance",
    "sad",
    "salsa",
    "samba",
    "sertanejo",
    "show-tunes",
    "singer-songwriter",
    "ska",
    "sleep",
    "songwriter",
    "soul",
    "soundtracks",
    "spanish",
    "study",
    "summer",
    "swedish",
    "synth-pop",
    "tango",
    "techno",
    "trance",
    "trip-hop",
    "turkish",
    "work-out",
    "world-music"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextFormField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'About you'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: selectedGenres
                    .map((genre) => Chip(
                          side: BorderSide.none,
                          elevation: 0,
                          label: Text(genre),
                          deleteIcon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          onDeleted: () {
                            setState(() {
                              selectedGenres.remove(genre);
                            });
                          },
                          padding: const EdgeInsets.all(8),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(
              height: 20,
              child: Text(' Select up to 5 your favarite genres'),
            ),
            DropdownMenu(
              enableFilter: true,
              enableSearch: true,
              leadingIcon: const Icon(Icons.search),
              dropdownMenuEntries:
                  genres.map<DropdownMenuEntry<String>>((String genre) {
                return DropdownMenuEntry<String>(
                  leadingIcon: const Icon(Icons.music_note),
                  value: genre,
                  label: genre,
                );
              }).toList(),
              onSelected: (value) {
                if (value != null &&
                    !selectedGenres.contains(value) &&
                    selectedGenres.length < 5) {
                  setState(() {
                    selectedGenres.add(value);
                  });
                }
              },
            ),
            Consumer<MyAPIService>(
              builder: (context, value, child) => Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  child: const Text('Register'),
                  onPressed: () {
                    registerUser(value, context);
                    if (registrationResult ==
                        "Email verification have been sent to your email addres") {
                      setState(() {
                        _isSussces = true;
                      });
                    }
                  },
                ),
              ),
            ),
            if (registrationResult != null)
              Text(
                registrationResult!,
                style: const TextStyle(color: Colors.red),
              ),
            _isSussces
                ? ElevatedButton(onPressed: () {}, child: const Text('Log In'))
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }

  void registerUser(MyAPIService apiService, context) async {
    final result = await apiService.registerUser(
        usernameController.text, emailController.text, passwordController.text,
        bio: bioController.text, genres: selectedGenres);

    setState(() {
      registrationResult = result;
    });
  }
}
