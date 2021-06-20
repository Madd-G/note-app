import 'model/hiveDB.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart' as intl;

class Date {
  changeUpdatedDate(int noteKey) async {
    Box<Note> notes = Hive.box<Note>("NoteApp");
    Note note = Hive.box<Note>("NoteApp")
        .values
        .singleWhere((value) => value.key == noteKey);
    note.dateUpdated = DateTime.now();
    await notes.put(noteKey, note);
  }

  String getDateFormated(DateTime date) {
    return intl.DateFormat.yMMMMEEEEd().format(date);
  }
}
