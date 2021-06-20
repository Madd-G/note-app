import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:note_app/model/hiveDB.dart';

class EditNote extends StatelessWidget {
  final int noteKey;

  EditNote({Key key, @required this.noteKey}) : super(key: key);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Note note = Hive.box<Note>("NoteApp")
        .values
        .singleWhere((value) => value.key == noteKey);
    _titleController.text = note.title;
    _noteController.text = note.notes;
    return Scaffold(
      backgroundColor: Color(0xFF1F1D2C),
      appBar: AppBar(
        elevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: Color(0xFF383544),
          ),
        ),
        title: Text(
          "Edit Note",
          style: TextStyle(
              color:
                  // Color(0xFF383544)
                  Color(0xFF383544)),
        ),
        backgroundColor: Color(0xFF1F1D2C),
        actions: [
          Row(
            children: <Widget>[
              Container(
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: GestureDetector(
                    onTap: () {
                      deleteNote(context);
                    },
                    child: Text(
                      "Delete",
                      style: TextStyle(
                          color: Colors.red,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.red),
                    ),
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(5, 5, 8, 5),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blue),
                    ),
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      updateNoteInfo(note, context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  title(),
                  notes(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  updateNoteInfo(Note note, context) async {
    if (_formKey.currentState.validate()) {
      note.title = _titleController.text;
      note.notes = _noteController.text;
      note.dateUpdated = DateTime.now();
      Box<Note> notes = Hive.box<Note>("NoteApp");
      await notes.put(noteKey, note);
      Navigator.of(context).pop();
    }
  }

  deleteNote(context) async {
    bool continueDelete = await alertConfirmDialog(context);
    if (continueDelete) {
      Box<Note> notes = Hive.box<Note>("NoteApp");
      await notes.delete(noteKey);
      Navigator.of(context).pop();
    }
  }

  Future<bool> alertConfirmDialog(context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Note"),
          content: Text("Are you sure you want to delete this Note?"),
          actions: <Widget>[
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        );
      },
    );
  }

  title() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: _titleController,
        validator: (value) {
          if (value.isEmpty) {
            return "Please fill the title";
          }
          return null;
        },
        style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.w500, color: Colors.white),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
            hintText: "Title",
            hintStyle: TextStyle(fontSize: 25.0, color: Color(0xFF9D9AA9)),
            border: InputBorder.none),
        autofocus: true,
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Color(0xFF1F1D2C)),
    );
  }

  notes() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: 30,
        controller: _noteController,
        validator: (value) {
          if (value.isEmpty) {
            return "Please fill the title";
          }
          return null;
        },
        style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF787888)),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
            hintText: "Note",
            hintStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9D9AA9)),
            border: InputBorder.none),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Color(0xFF1F1D2C)),
    );
  }
}
