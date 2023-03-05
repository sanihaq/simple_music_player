import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:simple_music_player/controller.dart';
import 'package:simple_music_player/utils.dart';
import 'package:simple_audio/simple_audio.dart';
import 'dart:io';

void main() {
  SimpleAudio.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Solid(
      providers: [
        SolidProvider<PlayerController>(
          create: () => PlayerController(),
          dispose: (controller) => controller.dispose(),
        ),
      ],
      child: const FilesList(),
    );
  }
}

class FilesList extends StatefulWidget {
  const FilesList({super.key});

  @override
  State<FilesList> createState() => _FilesListState();
}

class _FilesListState extends State<FilesList> {
  late final PlayerController playerController;
  final List<String> files = [];

  Future<void> loadFiles(bool recursive) async {
    files.clear();
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      files.addAll(await findMP3Files(dir, recursive));
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    playerController = context.get<PlayerController>();
  }

  @override
  void dispose() {
    playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simple Player"),
        actions: [
          IconButton(
            onPressed: () async => await loadFiles(true),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: files.isEmpty
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async => await loadFiles(true),
                    child: const Text("load files.."),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  ElevatedButton(
                    onPressed: () async => await loadFiles(false),
                    child: const Text("load files only"),
                  ),
                ],
              ),
            )
          : Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (ctx, index) => ListTile(
                    title: Text(files[index].split("/").last),
                    onTap: () async {
                      final file = Mp3File(
                        id: UniqueKey(),
                        path: files[index],
                        data: Metadata(),
                      );
                      playerController.addFile(file);
                    },
                  ),
                ),
                const Player(),
              ],
            ),
    );
  }
}

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  _PlayerState createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();

    // player.playbackStateStream.listen((event) {
    //   setState(() => playbackState = event);

    //   if (playbackState == PlaybackState.done) {
    //     player.setMetadata(Metadata(
    //         title: "Title",
    //         artist: "Artist",
    //         album: "Album",
    //         artUri: "https://picsum.photos/200"));
    //     player.open(widget.path!);
    //   }
    // });

    // player.progressStateStream.listen((event) {
    //   setState(() {
    //     position = event.position.toDouble();
    //     duration = event.duration.toDouble();
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    // final playlist = ref.watch(playlistProvider);
    // if (file != null) {
    //   print(file.path);
    //   player.setMetadata(
    //     Metadata(
    //       title: "Title",
    //       artist: "Artist",
    //       album: "Album",
    //       // artUri: "https://picsum.photos/200",
    //     ),
    //   );
    //   player.stop();
    //   player.open(file.path);
    // }
    return GestureDetector(
      onTap: () {
        setState(() {
          _expanded = !_expanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.fastOutSlowIn,
        width: double.infinity,
        height: _expanded ? MediaQuery.of(context).size.height : 100.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _expanded
              ? null
              : const BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 5.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: SizedBox(),
        // child: playlist.when(
        //   loading: () => const CircularProgressIndicator(),
        //   error: (error, stackTrace) => Text(error.toString()),
        //   data: (files) {
        //     if (files.item1.isEmpty) return SizedBox();
        //     // print(files.item1.map((e) => e.path).toList());
        //     final file = files.item1[files.item2];
        //     return Text(file.path);
        //   },
        // ),
      ),
    );
  }
}
