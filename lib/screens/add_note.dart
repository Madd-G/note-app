import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:note_app/model/hiveDB.dart';

class AddNote extends StatelessWidget {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
          "Notes",
          style: TextStyle(color: Color(0xFF383544)),
        ),
        backgroundColor: Color(0xFF1F1D2C),
        actions: [
          GestureDetector(
            onTap: () {
              createTextNote(context);
            },
            child: Container(
                margin: EdgeInsets.fromLTRB(0, 17, 20, 0),
                child: Text(
                  "Done",
                  style: TextStyle(
                      color: Color(0xFF9D9AA9),
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                )),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                title(),
                SizedBox(
                  height: 20,
                ),
                description(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  title() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: _titleController,
        validator: (value) {
          if (value.isEmpty) {
            return "Please fill the Note title";
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

  description() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      // height: 500,
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        maxLines: 30,
        controller: _descriptionController,
        validator: (value) {
          if (value.isEmpty) {
            return "Please fill the Note description";
          }
          return null;
        },
        style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF787888)),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 12.0),
          border: InputBorder.none,
          hintText: "Enter description",
          hintStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF9D9AA9)),
        ),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), color: Color(0xFF1F1D2C)),
    );
  }

  createTextNote(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      Box<Note> notes = Hive.box<Note>("NoteApp");
      reorderNotes(notes);
      int pk = await notes.add(Note(DateTime.now(), _titleController.text,
          _descriptionController.text, DateTime.now(), NoteType.Text, 0));
      Box<TextNote> tNotes = Hive.box<TextNote>("TextNotesItemsDB");
      await tNotes.add(TextNote("", pk));
      Navigator.of(context).pop();
    }
  }

  reorderNotes(Box<Note> notes) {
    for (Note noteOrder in notes.values) {
      noteOrder.position = noteOrder.position + 1;
      notes.put(noteOrder.key, noteOrder);
    }
  }
}
