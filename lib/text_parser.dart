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

  var userMentionsRegEx = RegExp(r'@\[__([^_]+)__]\(__([^_]+)__\)');
  var userMentionsMatches = userMentionsRegEx.allMatches(text);

  if (userMentionsMatches.isEmpty) {
    return [TextSegment(text)];
  }

  int lastUserMentionEnd = 0;

  userMentionsMatches.forEach(
    (match) {
      final userIdText = match.group(1);
      final userNameText = match.group(2);

      if (lastUserMentionEnd != match.start) {
        segments.add(
          TextSegment(text.substring(lastUserMentionEnd, match.start)),
        );
      }

      if (userIdText != null && userNameText != null) {
        segments.add(
          TextSegment('@$userNameText', userIdText, false, true, false),
        );
      }

      lastUserMentionEnd = match.end;
    },
  );

  if (lastUserMentionEnd != text.length) {
    segments.add(TextSegment(text.substring(lastUserMentionEnd, text.length)));
  }

  return segments;
}
