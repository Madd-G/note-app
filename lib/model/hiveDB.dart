import 'package:hive/hive.dart';

part 'hiveDB.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  DateTime dateCreated;

  @HiveField(1)
  String title;

  @HiveField(2)
  String notes;

  @HiveField(3)
  DateTime dateUpdated;

  @HiveField(4)
  NoteType noteType;

  @HiveField(5)
  int position;

  Note(this.dateCreated, this.title, this.notes, this.dateUpdated,
      this.noteType, this.position);
}

@HiveType(typeId: 1)
enum NoteType {
  @HiveField(0)
  Text,
}

const noteType = <NoteType, int>{
  NoteType.Text: 1,
};

@HiveType(typeId: 3)
class TextNote extends HiveObject {
  @HiveField(0)
  String text;

  @HiveField(1)
  int noteParent;

  TextNote(this.text, this.noteParent);
}
