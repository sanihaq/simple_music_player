import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> files = [];

  Future<void> loadFiles(bool recursive) async {
    files = [];
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      files = await findMP3Files(dir, recursive);
      setState(() {});
    }
  }

  final SimpleAudio player = SimpleAudio(
    onSkipNext: (_) => debugPrint("Next"),
    onSkipPrevious: (_) => debugPrint("Prev"),
    onNetworkStreamError: (player) {
      debugPrint("Network Stream Error");
      player.stop();
    },
    onDecodeError: (player) {
      debugPrint("Decode Error");
      player.stop();
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (ctx, index) => ListTile(
                title: Text(files[index].split("/").last),
                onTap: () async {
                  await player.open(files[index]);
                },
              ),
            ),
    );
  }
}
