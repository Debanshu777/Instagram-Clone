import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/feed_screen.dart';
import '../screens/add_post_screen.dart';

const webScreenSize = 600;
const homeScreenItems = [
  FeedScreen(),
  Text(
    "search",
  ),
  AddPostScreen(),
  Text(
    "notification",
  ),
  Text(
    "person",
  ),
];
