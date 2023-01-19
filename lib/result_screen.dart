import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String text;
  const ResultScreen({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Scanned Text Screen'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(30.0),
            child: const Text(
                "Our application has scanned the text as below: \nIf you have found text to be unclear, scan clearly moving the camera near to the image object."),
          ),
          Container(
            padding: const EdgeInsets.all(30.0),
            decoration: const BoxDecoration(
              color: Colors.red,
            ),
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(parent: ClampingScrollPhysics()),
              child: Text(
                text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
