//package com.example.photos.tokenizer
//
//
//import android.os.Build
//import androidx.annotation.RequiresApi
//import java.util.regex.Pattern
//
//class ClipTokenizer(
//    private val encoder: Map<String, Int>,
//    private val bpeRanks: Map<Pair<String, String>, Int>
//) {
//    companion object {
//        private val encodeRegex = Pattern.compile(
//            "\\[PAD\\]|\\[CLS\\]|\\[SEP\\]|\\[MASK\\]|[A-Za-z]+|\\[unused\\d+\\]|[^\\sA-Za-z]+",
//            Pattern.UNICODE_CHARACTER_CLASS
//        )
//    }
//
//    @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
//    fun encode(text: String): List<Int> {
//        // Tokenize text using larger tokens from vocab.json
//        return encodeRegex.matcher(text).results()
//            .mapNotNull { match ->
//                val token = match.group()
//                encoder[token]?.let { listOf(it) }
//                    ?: bpe(byteEncode(token))
//                        .mapNotNull { encoder[it] ?: encoder["[UNK]"] }
//            }
//            .toList()
//    }
//
//    private fun byteEncode(text: String): String {
//        // Convert characters to byte-encoded string
//        return text.codePoints()
//            .mapToObj { codePoint -> byteEncoder[codePoint] }
//            .joinToString("") { it ?: "" }
//    }
//
//    private fun bpe(token: String): List<String> {
//        if (token.length <= 1 || encoder.containsKey(token)) return listOf(token)
//        var word = token.split("").toMutableList()
//        var pairs = getPairs(word)
//        while (pairs.isNotEmpty()) {
//            val validPairs = pairs.filter { bpeRanks.containsKey(it) }
//            if (validPairs.isEmpty()) break
//            val pair = validPairs.minByOrNull { bpeRanks[it]!! }!!
//            word = mergePairInWord(word, pair.first, pair.second)
//            pairs = getPairs(word)
//        }
//        return word
//    }
//
//    private fun mergePairInWord(word: MutableList<String>, first: String, second: String): MutableList<String> {
//        val newWord = mutableListOf<String>()
//        var i = 0
//        while (i < word.size) {
//            val j = word.indexOfFirst(first, i)
//            if (j != -1) {
//                newWord.addAll(word.subList(i, j))
//                if (j < word.size - 1 && word[j + 1] == second) {
//                    newWord.add("$first$second")
//                    i = j + 2
//                } else {
//                    newWord.add(word[j])
//                    i = j + 1
//                }
//            } else {
//                newWord.addAll(word.subList(i, word.size))
//                break
//            }
//        }
//        return newWord
//    }
//
//    private fun getPairs(word: List<String>): Set<Pair<String, String>> {
//        return word.windowed(2, 1)
//            .map { it[0] to it[1] }
//            .toSet()
//    }
//}