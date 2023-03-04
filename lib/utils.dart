import 'dart:io';

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
