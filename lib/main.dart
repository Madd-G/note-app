import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'model/hiveDB.dart';
import 'screens/add_note.dart';
import 'screens/edit_note.dart';
import 'package:note_app/date.dart';

void main() async {
  if (!kIsWeb) {
    await Hive.initFlutter();
  }
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(NoteTypeAdapter());
  Hive.registerAdapter(TextNoteAdapter());
  await Hive.openBox<Note>("NoteApp");
  await Hive.openBox<TextNote>("TextNotesItemsDB");
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainMenu(),
    // theme: ThemeData.light()
  ));
}

class MainMenu extends StatefulWidget {
  @override
  _MainMenuState createState() => _MainMenuState();
}

ThemeData _lightTheme = ThemeData(
    accentColor: Colors.white,
    brightness: Brightness.light,
    primaryColor: Colors.yellow,
    buttonTheme: ButtonThemeData(buttonColor: Colors.black),
    buttonColor: Colors.black);

ThemeData _darkTheme = ThemeData(
    accentColor: Color(0xFF1F1D2C),
    brightness: Brightness.dark,
    primaryColor: Color(0xFF1F1D2C),
    buttonTheme: ButtonThemeData(buttonColor: Colors.yellow));

bool _dark = false;

class _MainMenuState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _dark ? _lightTheme : _darkTheme,
      home: Scaffold(
        // backgroundColor: Color(0xFF1F1D2C),
        appBar: AppBar(
          title: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TypewriterAnimatedTextKit(
                  speed: Duration(milliseconds: 1000),
                  totalRepeatCount: 1,
                  text: ['All Note'],
                  textStyle: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: _dark ? Colors.black : Colors.white),
                ),
                Row(
                  children: [
                    Text(
                      "Dark",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      activeColor: Color(0xFF1F1D2C),
                      value: _dark,
                      onChanged: (state) {
                        setState(() {
                          _dark = state;
                        });
                      },
                    ),
                    Text("Light", style: TextStyle(fontWeight: FontWeight.bold))
                  ],
                )
              ],
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: getNotes(screenWidth),
        floatingActionButton: addNoteButton(),
      ),
    );
  }

  getNotes(double screenWidth) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Note>("NoteApp").listenable(),
      builder: (context, Box<Note> box, _) {
        if (box.values.isEmpty) {
          return Center(
            child: Text(
              "No Notes!",
              style: TextStyle(
                  fontSize: 30, color: _dark ? Colors.black : Colors.white),
            ),
          );
        }
        List<Note> notes = getNotesList();
        return Scrollbar(
          child: GridView.count(
            crossAxisCount: ((screenWidth < 600)
                ? 2
                : (screenWidth < 1200)
                    ? 3
                    : 4),
            children: <Widget>[
              for (Note note in notes) ...[
                getNoteInfo(note, context),
              ],
            ],
          ),
        );
      },
    );
  }

  getNotesList() {
    List<Note> notes = Hive.box<Note>("NoteApp").values.toList();
    notes.sort((a, b) {
      var aposition = a.position;
      var bposition = b.position;
      return aposition.compareTo(bposition);
    });
    return notes;
  }

  getNoteInfo(Note note, BuildContext context) {
    bool isWindows = Theme.of(context).platform == TargetPlatform.windows;
    return ListTile(
      dense: true,
      key: Key(note.key.toString()),
      onTap: () {
        if (note.noteType == NoteType.Text) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditNote(
                noteKey: note.key,
              ),
            ),
          );
        }
      },
      title: Flexible(
        child: Container(
          padding: EdgeInsets.all(15),
          margin: EdgeInsets.only(top: 4, bottom: 4),
          // height: 150,
          decoration: BoxDecoration(
              color: Color(0xFF373749),
              borderRadius: BorderRadius.circular(15)),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: isWindows ? 25 : 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                        note.notes,
                        style: TextStyle(
                            color: Color(0xFF787888),
                            fontSize:
                                (!isWindows) && (constraints.maxHeight < 250)
                                    ? 16
                                    : 22),
                        maxLines: (!isWindows) && (constraints.maxHeight < 200)
                            ? 4
                            : (!isWindows) && (constraints.maxHeight < 250)
                                ? 9
                                : (constraints.maxHeight <= 176)
                                    ? 3
                                    : (constraints.maxHeight < 200)
                                        ? 4
                                        : (constraints.maxHeight < 225)
                                            ? 5
                                            : (constraints.maxHeight < 250)
                                                ? 6
                                                : (constraints.maxHeight < 290)
                                                    ? 7
                                                    : (constraints.maxHeight <
                                                            300)
                                                        ? 8
                                                        : 9,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(
                    Date().getDateFormated(note.dateCreated),
                    style: TextStyle(color: Colors.white),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  addNoteButton() {
    return Builder(
      builder: (context) {
        return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => AddNote()));
          },
          backgroundColor: Color(0xFF706FC8),
        );
      },
    );
  }
}
