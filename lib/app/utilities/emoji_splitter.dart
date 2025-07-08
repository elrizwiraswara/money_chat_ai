({String emoji, String name}) splitEmoji(String? input) {
  if (input?.isEmpty ?? true) return (emoji: '❓', name: '');

  final firstChar = input!.split(' ').first;

  final emojiRegex = RegExp(
    r'^[\u203C-\u3299\u1F000-\u1FAFF\u1F600-\u1F64F\u1F300-\u1F5FF\u1F680-\u1F6FF\u2600-\u26FF\u2700-\u27BF\uFE00-\uFE0F\u1F900-\u1F9FF\u1F1E6-\u1F1FF\u1F004\u1F0CF]+$',
    unicode: true,
  );

  if (!emojiRegex.hasMatch(firstChar)) {
    return (emoji: firstChar, name: input.substring(firstChar.length + 1));
  } else {
    return (emoji: input.substring(0, 1).toUpperCase(), name: input);
  }
}
