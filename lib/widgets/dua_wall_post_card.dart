import 'package:flutter/material.dart';
import '../models/reflection.dart';
import 'package:timeago/timeago.dart' as timeago;

class DuaWallPostCard extends StatelessWidget {
  final DuaWallPost post;
  final VoidCallback onPray;

  const DuaWallPostCard({
    Key? key,
    required this.post,
    required this.onPray,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: post.isOwnPost
            ? Border.all(color: Colors.teal.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getMoodColor(post.mood).withOpacity(0.1),
                ),
                child: Text(
                  _getMoodEmoji(post.mood),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.isOwnPost ? 'Your Reflection' : 'Anonymous',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      timeago.format(post.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            post.content,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${post.prayerCount} ${post.prayerCount == 1 ? 'prayer' : 'prayers'}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
              if (!post.isOwnPost)
                TextButton.icon(
                  onPressed: onPray,
                  icon: Icon(Icons.favorite_border, size: 18),
                  label: Text('I prayed for you'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.teal.withOpacity(0.3)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getMoodColor(String? mood) {
    switch (mood) {
      case 'peaceful': return Colors.blue;
      case 'grateful': return Colors.green;
      case 'content': return Colors.purple;
      case 'hopeful': return Colors.orange;
      case 'blessed': return Colors.amber;
      case 'calm': return Colors.teal;
      default: return Colors.grey;
    }
  }

  String _getMoodEmoji(String? mood) {
    switch (mood) {
      case 'peaceful': return '☮️';
      case 'grateful': return '🤲';
      case 'content': return '😌';
      case 'hopeful': return '🌟';
      case 'blessed': return '✨';
      case 'calm': return '🕊️';
      default: return '💭';
    }
  }
}// TODO Implement this library.