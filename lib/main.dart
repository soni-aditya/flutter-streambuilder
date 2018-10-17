import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PhotoList(),
    );
  }
}

class PhotoList extends StatefulWidget {
  @override
  _PhotoListState createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
  StreamController<Photo> streamController;
  List<Photo> list = [];

  @override
  void initState() {
    super.initState();
    streamController = StreamController.broadcast();
    streamController.stream.listen((p) => setState(() => list.add(p)));
    load(streamController);
  }

  load(StreamController sController) async {
    String url = 'https://jsonplaceholder.typicode.com/photos';
    var client = http.Client();
    var request = http.Request('get', Uri.parse(url));
    var streamResponse = await client.send(request);
    //Subscribing to the stream response
    streamResponse.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .expand((e) => e)
        .map((map) => Photo.fromJson(map))
        .pipe(streamController);
  }

  @override
  void dispose() {
    super.dispose();
    streamController?.close();
    streamController = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Streams'),
      ),
      body: Center(
        child: ListView.builder(
            itemBuilder: (BuildContext context, int index) =>
                makeElement(index)),
      ),
    );
  }

  makeElement(int index) {
    if (index >= list.length) {
      return null;
    }
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Image.network(list[index].url),
          Text(list[index].title)
        ],
      ),
    );
  }
}

class Photo {
  String title;
  String url;

  Photo.fromJson(Map map)
      : title = map['title'],
        url = map['url'];
}
