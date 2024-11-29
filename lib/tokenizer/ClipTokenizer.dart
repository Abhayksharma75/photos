import 'ClipByteEncoder.dart';

class ClipTokenizer {
  final Map<String, int> encoder;
  final Map<StringPair, int> bpeRanks;

  ClipTokenizer(this.encoder, this.bpeRanks);

  static final RegExp encodeRegex = RegExp(
      r"\[PAD\]|\[CLS\]|\[SEP\]|\[MASK\]|[A-Za-z]+|\[unused\d+\]|[^\sA-Za-z]+",
      unicode: true);

  List<int> encode(String text) {
  // Tokenize text using larger tokens from vocab.json
  return encodeRegex.allMatches(text).expand((match) {
    final token = match.group(0)!;
    if (encoder.containsKey(token)) {
      return [encoder[token]!];
    }
    // Apply byte encoding and BPE if token is not directly found
    final byteEncoded = byteEncode(token);
    return bpe(byteEncoded)
        .map((t) => encoder[t] ?? encoder['[UNK]'] ?? -1) // Ensure no null values
        .where((value) => value != -1) // Filter out fallback if it remains unset
        .toList();
  }).toList();
}


  String byteEncode(String text) {
    // Convert characters to byte-encoded string
    return String.fromCharCodes(text.runes.map((codePoint) => byteEncoder[codePoint]!.codeUnitAt(0)));
  }

  List<String> bpe(String token) {
    if (token.length <= 1 || encoder.containsKey(token)) return [token];
    var word = token.split('').toList();
    var pairs = getPairs(word);
    while (pairs.isNotEmpty) {
      final validPairs = pairs.where((pair) => bpeRanks.containsKey(pair)).toList();
      if (validPairs.isEmpty) break;
      final pair = validPairs.reduce((a, b) => bpeRanks[a]! < bpeRanks[b]! ? a : b);
      word = mergePairInWord(word, pair.item1, pair.item2);
      pairs = getPairs(word);
    }
    return word;
  }

  List<String> mergePairInWord(List<String> word, String first, String second) {
    var newWord = <String>[];
    int i = 0;
    while (i < word.length) {
      final j = word.indexWhere((token) => token == first, i);
      if (j != -1) {
        newWord.addAll(word.sublist(i, j));
        if (j < word.length - 1 && word[j + 1] == second) {
          newWord.add(first + second);
          i = j + 2;
        } else {
          newWord.add(word[j]);
          i = j + 1;
        }
      } else {
        newWord.addAll(word.sublist(i));
        break;
      }
    }
    return newWord;
  }

  Set<StringPair> getPairs(List<String> word) {
    final pairs = <StringPair>{};
    for (int i = 0; i < word.length - 1; i++) {
      pairs.add(StringPair(word[i], word[i + 1]));
    }
    return pairs;
  }
}

class StringPair {
  final String item1;
  final String item2;

  StringPair(this.item1, this.item2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringPair && runtimeType == other.runtimeType &&
      item1 == other.item1 && item2 == other.item2;

  @override
  int get hashCode => item1.hashCode ^ item2.hashCode;
}
