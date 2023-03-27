import 'dart:convert';
import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:simple_audio/simple_audio.dart';

import '../states/files_controller.dart';
import 'consts.dart';

class Mp3File {
  final UniqueKey id;
  final String path;
  final Metadata data;

  Mp3File({required this.id, required this.path, required this.data});

  Mp3File copyWith({
    UniqueKey? id,
    String? path,
    Metadata? data,
  }) {
    return Mp3File(
      id: id ?? this.id,
      path: path ?? this.path,
      data: data ?? this.data,
    );
  }
}

Future<Mp3File> mp3FileFromPath(String path) async {
  final defaultArt = Picture(
    pictureType: PictureType.icon,
    mimeType: MimeType.png,
    bytes: base64Decode(kMp3FileDefaultArt),
  );
  Tag tag = const Tag(pictures: []);
  try {
    tag = await AudioTags.read(path) ?? tag;
    // ignore: empty_catches
  } catch (e) {}
  tag.pictures.add(defaultArt);
  return Mp3File(
    id: UniqueKey(),
    path: path,
    data: Metadata(
      title: tag.title ?? path.split("/").last,
      artist: tag.artist,
      album: tag.album,
      artBytes: tag.pictures.first.bytes,
    ),
  );
}

SnackBar showNewlyAddedMsg(int newlyAdded) {
  return showMsg(newlyAdded == 0
      ? "No new file found!"
      : "$newlyAdded new file${newlyAdded > 1 ? "s" : ""} added");
}

SnackBar showMsg(String msg) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(bottom: kBottomCollapsedSize),
    duration: const Duration(seconds: 2),
    content: Text(msg),
    action: SnackBarAction(
      label: 'Ok',
      onPressed: () {},
    ),
  );
}

Future<List<String>> findMP3Files(Directory dir, [recursive = true]) async {
  List<String> mp3Files = [];
  await Future.forEach(dir.listSync(), (entity) async {
    if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
      mp3Files.add(entity.path);
    } else if (recursive && entity is Directory) {
      List<String> subMp3Files = await findMP3Files(entity);
      mp3Files.addAll(subMp3Files);
    }
  });
  return mp3Files.reversed.toList();
}

Future<List<Mp3File>> loadFiles(
    {required String dirPath, required bool recursive}) async {
  final List<Mp3File> files = [];

  final dir = Directory(dirPath);

  final paths = await findMP3Files(dir, recursive);

  final newFiles = await Future.wait(
      paths.map((e) async => await mp3FileFromPath(e)).toList());
  for (var e in newFiles) {
    if (!files.any((el) => el.path == e.path)) {
      files.add(e);
    }
  }

  return files;
}

Future<void> loadAndAddFiles(BuildContext context,
    FilesController filesController, bool recursive) async {
  filesController.isSelecting.update((_) => true);
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
  if (selectedDirectory != null) {
    filesController.isLoading.update((_) => true);
    final newFiles =
        await loadFiles(dirPath: selectedDirectory, recursive: recursive);
    filesController.addFiles(newFiles);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(showNewlyAddedMsg(newFiles.length));
    }
    filesController.isLoading.update((_) => false);
  }
  filesController.isSelecting.update((_) => false);
}
