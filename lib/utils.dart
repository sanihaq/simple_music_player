import 'dart:convert';
import 'dart:io';

import 'package:audiotags/audiotags.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_audio/simple_audio.dart';

import 'consts.dart';

class Mp3File {
  final UniqueKey id;
  final String path;
  final Metadata data;

  Mp3File({required this.id, required this.path, required this.data});
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
  return mp3Files;
}

Future<Mp3File> mp3FileFromPath(String path) async {
  final defaultArt = Picture(
    pictureType: PictureType.Icon,
    mimeType: MimeType.Png,
    bytes: base64Decode(kMp3FileDefaultArt),
  );
  Tag tag = Tag(pictures: []);
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
