class TextSegment {
  String text;

  final String? name;
  final bool isHashtag;
  final bool isMention;
  final bool isUrl;

  bool get isText => !isHashtag && !isMention && !isUrl;

  TextSegment(this.text,
      [this.name,
      this.isHashtag = false,
      this.isMention = false,
      this.isUrl = false]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextSegment &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          name == other.name &&
          isHashtag == other.isHashtag &&
          isMention == other.isMention &&
          isUrl == other.isUrl;

  @override
  int get hashCode =>
      text.hashCode ^
      name.hashCode ^
      isHashtag.hashCode ^
      isMention.hashCode ^
      isUrl.hashCode;
}

/// Split the string into multiple instances of [TextSegment] for mentions and regular text.
///
/// Mentions are all words that start with @, e.g. @mention.
 
// This function is parsing text in PostWidget, 
// the same function for parsing text in PostScreen is in MentionsUtils
List<TextSegment> parseText(String? text) {
   final segments = <TextSegment>[];
  if (text == null || text.isEmpty) {
    return segments;
  }

  var expTextUserIdDisplayName =
      RegExp(r'([^@]*)@\[__(.+?)__\]\(__(.+?)__\)|(.+)');
  var matchesAll = expTextUserIdDisplayName.allMatches(text);

  matchesAll.forEach(
    (element) {
      final preText = element.group(1);
      final userIdText = element.group(2);
      final userNameText = element.group(3);
      final postText = element.group(4);

      if (preText != null) {
        segments.add(
          TextSegment(preText),
        );
      }
      if (userIdText != null && userNameText != null) {
        segments.add(
          TextSegment('@$userNameText', userIdText, false, true, false),
        );
      }
      if (postText != null) {
        segments.add(
          TextSegment(postText),
        );
      }
    },
  );
  return segments;
}
