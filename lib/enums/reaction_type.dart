enum ReactionType {
  like, // 👍 For general appreciation
  love, // 😍 For strong positive reactions
  inspire, // 💪 For motivational content
  celebrate, // 🎉 For achievements and milestones
  support, // 🙌 For showing support
  proud, // 🦁 For pride in accomplishments
  fire, // 🔥 For impressive streaks/achievements
  none // No reaction
}

final Map<ReactionType, String> reactionIcons = {
  ReactionType.like: '👍',
  ReactionType.love: '😍',
  ReactionType.inspire: '💪',
  ReactionType.celebrate: '🎉',
  ReactionType.support: '🙌',
  ReactionType.proud: '🦁',
  ReactionType.fire: '🔥',
};
