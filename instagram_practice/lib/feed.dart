import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Feed extends StatefulWidget {
  const Feed({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  final String imageUrl;

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(
          child: Image.network(
            widget.imageUrl,
            height: 400,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Row(
          children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
                icon: Icon(
                  CupertinoIcons.heart,
                  color: isFavorite ? Colors.pink : Colors.black,
                )),
            IconButton(
                icon: Icon(CupertinoIcons.chat_bubble), onPressed: () {}),
            Spacer(),
            IconButton(
              icon: Icon(CupertinoIcons.bookmark, color: Colors.black),
              onPressed: () {},
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("2 Likes", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("My cat is docile even when bathed. I put a duck on his"),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "FEBURARY 6",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
