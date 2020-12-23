// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:nm_delta/nm_delta.dart';
import 'package:nm_delta_notus/nm_delta_notus.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyr/zefyr.dart';

import './drawer.dart';

class EditorPage extends StatefulWidget {
  @override
  EditorPageState createState() => EditorPageState();
}

class EditorPageState extends State<EditorPage> {
  FocusNode _focusNode;
  NotusDocument _document;
  ZefyrController _controller;
  NoteMapNotusTranslator _noteMapNotusTranslator;
  StreamController<NoteMapDelta> _noteMapDeltas = StreamController<NoteMapDelta>();

  @override
  void initState() {
    super.initState();
    final logger = Logger();
    _focusNode = FocusNode();
    _document = NotusDocument();
    _controller = ZefyrController(_document);
    _noteMapNotusTranslator = NoteMapNotusTranslator('prototype-root-node-id');
    _document.changes.listen((change) {
      if (change.source == ChangeSource.local) {
        logger.d(jsonEncode(change.change));
        final result = _noteMapNotusTranslator.onNotusChange(change);
        if (result.hasNotus) {
          // Respond to [change] by automatically fixing the document
          logger.d(jsonEncode(result.notus));
          _document.compose(result.notus, ChangeSource.remote);
        }
        if (result.hasNoteMap) {
          // TODO: do something with NoteMapDelta result.noteMap.
          logger.d(jsonEncode(result.noteMap));
          _noteMapDeltas.add(result.noteMap);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = (_controller == null)
        ? Center(child: CircularProgressIndicator())
        : Column(children: <Widget>[
            ZefyrField(
              padding: EdgeInsets.all(16),
              controller: _controller,
              focusNode: _focusNode,
            ),
            StreamBuilder<NoteMapDelta>(
              stream: _noteMapDeltas.stream,
              builder: (BuildContext context, AsyncSnapshot<NoteMapDelta> snapshot) {
                return NoteMapDeltaInspector(snapshot);
              },
            ),
          ],
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('Note Maps (early development version)'),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.save),
              onPressed: () => _saveDocument(context),
            ),
          )
        ],
      ),
      drawer: NmDrawer(),
      body: body,
    );
  }

  void _saveDocument(BuildContext context) {
    // Notus documents can be easily serialized to JSON by passing to
    // `jsonEncode` directly:
    final contents = jsonEncode(_controller.document);
    // For this example we save our document to a temporary file.
    final file = File(Directory.systemTemp.path + '/quick_start.json');
    // And show a snack bar on success.
    file.writeAsString(contents).then((_) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Saved.')));
    });
  }
}

class NoteMapDeltaInspector extends StatelessWidget {
  final AsyncSnapshot<NoteMapDelta> noteMapDelta;
  NoteMapDeltaInspector(this.noteMapDelta);

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (noteMapDelta.hasError) {
      child = Text('(error: ${noteMapDelta.error})');
    } else {
      switch (noteMapDelta.connectionState) {
      case ConnectionState.none:
        child = Text('(none)');
        break;
      case ConnectionState.waiting:
        child = Text('(waiting)');
        break;
      case ConnectionState.active:
        child = Text('${jsonEncode(noteMapDelta.data)}');
        break;
      case ConnectionState.done:
        child = Text('(done)');
        break;
      }
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[child],
    );
  }
}
