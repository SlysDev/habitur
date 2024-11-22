import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitur/util_functions.dart';

enum ActivityType {
  habitCompletion,
  streakMilestone,
  newHabit,
}

enum ReactionType {
  like,
  celebrate,
  support,
  inspire,
  none
}

class Comment {
  final String id;
  final String userId;
  final String username;
  final String? profilePicture;
  final String text;
  final DateTime timestamp;
  final List<String> likes;

  Comment({
    String? id,
    required this.userId,
    required this.username,
    this.profilePicture,
    required this.text,
    DateTime? timestamp,
    List<String>? likes,
  })  : this.id = id ?? generateUniqueId(),
        this.timestamp = timestamp ?? DateTime.now(),
        this.likes = likes ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'profilePicture': profilePicture,
      'text': text,
      'timestamp': timestamp,
      'likes': likes,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String? ?? generateUniqueId(),
      userId: map['userId'] as String,
      username: map['username'] as String,
      profilePicture: map['profilePicture'] as String?,
      text: map['text'] as String,
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : (map['timestamp'] as DateTime? ?? DateTime.now()),
      likes: List<String>.from(map['likes'] ?? []),
    );
  }
}

class Reaction {
  final String userId;
  final String username;
  final ReactionType type;
  final DateTime timestamp;

  Reaction({
    required this.userId,
    required this.username,
    required this.type,
    DateTime? timestamp,
  }) : this.timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'type': type.toString().split('.').last,
      'timestamp': timestamp,
    };
  }

  factory Reaction.fromMap(Map<String, dynamic> map) {
    var timestamp = map['timestamp'];
    DateTime parsedTimestamp;
    
    if (timestamp is Timestamp) {
      parsedTimestamp = timestamp.toDate();
    } else if (timestamp is String) {
      parsedTimestamp = DateTime.parse(timestamp);
    } else if (timestamp is DateTime) {
      parsedTimestamp = timestamp;
    } else {
      parsedTimestamp = DateTime.now();
    }

    return Reaction(
      userId: map['userId'] as String,
      username: map['username'] as String? ?? 'Unknown User',
      type: ReactionType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ReactionType.like,
      ),
      timestamp: parsedTimestamp,
    );
  }
}

class ActivityEvent {
  final String id;
  final String userId;
  final String username;
  final String? profilePicture;
  final ActivityType type;
  final String habitId;
  final String habitTitle;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  final List<String> likes;
  final List<Comment> comments;
  final Map<ReactionType, List<Reaction>> reactions;
  final int likeCount;
  final bool hasLiked;
  final ReactionType? userReaction;

  ActivityEvent({
    String? id,
    required this.userId,
    required this.username,
    this.profilePicture,
    required this.type,
    required this.habitId,
    required this.habitTitle,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    List<String>? likes,
    List<Comment>? comments,
    Map<ReactionType, List<Reaction>>? reactions,
    int? likeCount,
    this.hasLiked = false,
    this.userReaction,
  })  : this.id = id ?? generateUniqueId(),
        this.timestamp = timestamp ?? DateTime.now(),
        this.metadata = metadata ?? {},
        this.likes = likes ?? [],
        this.comments = comments ?? [],
        this.reactions = reactions ?? {},
        this.likeCount = likeCount ?? likes?.length ?? 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'profilePicture': profilePicture,
      'type': type.toString().split('.').last,
      'habitId': habitId,
      'habitTitle': habitTitle,
      'timestamp': timestamp,
      'metadata': metadata,
      'likes': likes,
      'comments': comments.map((c) => c.toMap()).toList(),
      'reactions': {
        for (var entry in reactions.entries)
          entry.key.toString().split('.').last:
              entry.value.map((r) => r.toMap()).toList(),
      },
      'likeCount': likeCount,
    };
  }

  factory ActivityEvent.fromMap(Map<String, dynamic> map) {
    final timestamp = map['timestamp'] is Timestamp
        ? (map['timestamp'] as Timestamp).toDate()
        : (map['timestamp'] as DateTime? ?? DateTime.now());

    final likes = List<String>.from(map['likes'] ?? []);
    final comments = (map['comments'] as List?)
            ?.map((c) => Comment.fromMap(c as Map<String, dynamic>))
            .toList() ??
        [];

    final reactions = (map['reactions'] as Map?)?.map(
          (key, value) => MapEntry(
            ReactionType.values.firstWhere(
              (e) => e.toString().split('.').last == key,
              orElse: () => ReactionType.like,
            ),
            (value as List)
                .map((r) => Reaction.fromMap(r as Map<String, dynamic>))
                .toList(),
          ),
        ) ??
        {};

    return ActivityEvent(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String,
      username: map['username'] as String,
      profilePicture: map['profilePicture'] as String?,
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ActivityType.habitCompletion,
      ),
      habitId: map['habitId'] as String,
      habitTitle: map['habitTitle'] as String,
      timestamp: timestamp,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
      likes: likes,
      comments: comments,
      reactions: reactions,
      likeCount: map['likeCount'] as int? ?? likes.length,
      hasLiked: likes.contains(map['currentUserId'] as String? ?? ''),
      userReaction: map['userReaction'] != null
          ? ReactionType.values.firstWhere(
              (e) => e.toString().split('.').last == map['userReaction'],
              orElse: () => ReactionType.none,
            )
          : null,
    );
  }

  ActivityEvent copyWith({
    String? id,
    String? userId,
    String? username,
    String? profilePicture,
    ActivityType? type,
    String? habitId,
    String? habitTitle,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    List<String>? likes,
    List<Comment>? comments,
    Map<ReactionType, List<Reaction>>? reactions,
    int? likeCount,
    bool? hasLiked,
    ReactionType? userReaction,
  }) {
    return ActivityEvent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
      type: type ?? this.type,
      habitId: habitId ?? this.habitId,
      habitTitle: habitTitle ?? this.habitTitle,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      reactions: reactions ?? this.reactions,
      likeCount: likeCount ?? this.likeCount,
      hasLiked: hasLiked ?? this.hasLiked,
      userReaction: userReaction ?? this.userReaction,
    );
  }
}
