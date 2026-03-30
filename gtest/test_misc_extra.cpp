/*
 * Copyright (C) 2024 scidCommunity contributors
 *
 * Scid is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation.
 *
 * Scid is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Scid. If not, see <http://www.gnu.org/licenses/>.
 */

// Additional tests for misc.h/misc.cpp, covering functionality
// not already covered by test_str.cpp (strTrimRight, strCaseCompare,
// strStartHash).

#include "misc.h"
#include <gtest/gtest.h>
#include <cstring>

// ============================================================
// StrRange tests
// ============================================================

TEST(Test_StrRange, SingleValue) {
    StrRange r("42");
    EXPECT_TRUE(r.inRange(42));
    EXPECT_FALSE(r.inRange(41));
    EXPECT_FALSE(r.inRange(43));
}

TEST(Test_StrRange, RangeMinMax) {
    StrRange r("10 20");
    EXPECT_FALSE(r.inRange(9));
    EXPECT_TRUE(r.inRange(10));
    EXPECT_TRUE(r.inRange(15));
    EXPECT_TRUE(r.inRange(20));
    EXPECT_FALSE(r.inRange(21));
}

TEST(Test_StrRange, ReversedRange_AutoSwapped) {
    StrRange r("20 10");
    EXPECT_TRUE(r.inRange(15));
    EXPECT_TRUE(r.inRange(10));
    EXPECT_TRUE(r.inRange(20));
    EXPECT_FALSE(r.inRange(9));
}

TEST(Test_StrRange, Zero) {
    StrRange r("0");
    EXPECT_TRUE(r.inRange(0));
    EXPECT_FALSE(r.inRange(1));
    EXPECT_FALSE(r.inRange(-1));
}

TEST(Test_StrRange, NegativeValues) {
    StrRange r("-5 5");
    EXPECT_TRUE(r.inRange(-5));
    EXPECT_TRUE(r.inRange(0));
    EXPECT_TRUE(r.inRange(5));
    EXPECT_FALSE(r.inRange(-6));
    EXPECT_FALSE(r.inRange(6));
}

// ============================================================
// ECO code conversion tests
// ============================================================

TEST(Test_ECO, FromString_BasicCodes) {
    EXPECT_NE(ECO_None, eco_FromString("A00"));
    EXPECT_NE(ECO_None, eco_FromString("E99"));
    EXPECT_NE(ECO_None, eco_FromString("C41"));
}

TEST(Test_ECO, FromString_InvalidReturnsNone) {
    EXPECT_EQ(ECO_None, eco_FromString("F00")); // F is invalid
    EXPECT_EQ(ECO_None, eco_FromString(""));
    EXPECT_EQ(ECO_None, eco_FromString("1A0"));
    EXPECT_EQ(ECO_None, eco_FromString("A0X")); // X is not a digit
}

TEST(Test_ECO, FromString_CaseInsensitive) {
    EXPECT_EQ(eco_FromString("A41"), eco_FromString("a41"));
    EXPECT_EQ(eco_FromString("E99"), eco_FromString("e99"));
    EXPECT_EQ(eco_FromString("C00"), eco_FromString("c00"));
}

TEST(Test_ECO, FromString_PartialCode) {
    // "C1" should parse as C10
    ecoT partial = eco_FromString("C1");
    ecoT full    = eco_FromString("C10");
    EXPECT_EQ(partial, full);
}

TEST(Test_ECO, ToString_RoundTrip) {
    const char* testCodes[] = {"A00", "A41", "B92", "C41", "D85", "E97", nullptr};
    for (int i = 0; testCodes[i]; ++i) {
        ecoT code = eco_FromString(testCodes[i]);
        char buf[8] = {};
        eco_ToString(code, buf, false); // no extensions
        EXPECT_STREQ(testCodes[i], buf) << "Round-trip failed for " << testCodes[i];
    }
}

TEST(Test_ECO, ToString_ECO_None) {
    char buf[8] = "XYZ";
    eco_ToString(ECO_None, buf);
    EXPECT_STREQ("", buf);
}

TEST(Test_ECO, BasicCode_RemovesExtensions) {
    ecoT extended = eco_FromString("C41a2");
    ecoT basic    = eco_FromString("C41");
    EXPECT_EQ(basic, eco_BasicCode(extended));
}

TEST(Test_ECO, BasicCode_AlreadyBasic) {
    ecoT basic = eco_FromString("D85");
    EXPECT_EQ(basic, eco_BasicCode(basic));
}

TEST(Test_ECO, BasicCode_ECO_None) {
    EXPECT_EQ(ECO_None, eco_BasicCode(ECO_None));
}

TEST(Test_ECO, LastSubCode_BasicCode) {
    ecoT basic = eco_FromString("B91");
    ecoT last  = eco_LastSubCode(basic);
    // last subcode should be larger than basic
    EXPECT_GT(last, basic);

    char buf[8] = {};
    eco_ToString(last, buf, true);
    // Should end with 'z4'
    std::string s(buf);
    EXPECT_EQ('z', s[3]);
    EXPECT_EQ('4', s[4]);
}

TEST(Test_ECO, LastSubCode_WithLetter) {
    ecoT withLetter = eco_FromString("B91a");
    ecoT last       = eco_LastSubCode(withLetter);

    char buf[8] = {};
    eco_ToString(last, buf, true);
    std::string s(buf);
    // Should end with 'a4'
    EXPECT_EQ('a', s[3]);
    EXPECT_EQ('4', s[4]);
}

TEST(Test_ECO, LastSubCode_ECO_None) {
    EXPECT_EQ(ECO_None, eco_LastSubCode(ECO_None));
}

TEST(Test_ECO, Reduce_MapsToSmallerSet) {
    ecoT a00   = eco_FromString("A00");
    ecoT a00a  = eco_FromString("A00a");
    ecoT a00a1 = eco_FromString("A00a1");
    ecoT a00a4 = eco_FromString("A00a4");
    ecoT a00b  = eco_FromString("A00b");

    // a00a, a00a1, a00a2, a00a3, a00a4 should all reduce to the same value
    EXPECT_EQ(eco_Reduce(a00a), eco_Reduce(a00a1));
    EXPECT_EQ(eco_Reduce(a00a), eco_Reduce(a00a4));
    // a00 and a00a should reduce to different values
    EXPECT_NE(eco_Reduce(a00), eco_Reduce(a00a));
    // a00a and a00b should reduce to different values
    EXPECT_NE(eco_Reduce(a00a), eco_Reduce(a00b));
}

// ============================================================
// strGetBoolean tests
// ============================================================

TEST(Test_MiscStr, GetBoolean_TrueValues) {
    EXPECT_TRUE(strGetBoolean("true"));
    EXPECT_TRUE(strGetBoolean("True"));
    EXPECT_TRUE(strGetBoolean("TRUE"));
    EXPECT_TRUE(strGetBoolean("yes"));
    EXPECT_TRUE(strGetBoolean("Yes"));
    EXPECT_TRUE(strGetBoolean("1"));
    EXPECT_TRUE(strGetBoolean("on"));
    EXPECT_TRUE(strGetBoolean("ja"));
    EXPECT_TRUE(strGetBoolean("si"));
    EXPECT_TRUE(strGetBoolean("oui"));
}

TEST(Test_MiscStr, GetBoolean_FalseValues) {
    EXPECT_FALSE(strGetBoolean("false"));
    EXPECT_FALSE(strGetBoolean("False"));
    EXPECT_FALSE(strGetBoolean("no"));
    EXPECT_FALSE(strGetBoolean("0"));
    EXPECT_FALSE(strGetBoolean("off"));
}

TEST(Test_MiscStr, GetBoolean_EmptyOrUnknown) {
    EXPECT_FALSE(strGetBoolean(""));
    EXPECT_FALSE(strGetBoolean("maybe"));
    EXPECT_FALSE(strGetBoolean("xyz"));
}

// ============================================================
// strGetResult tests
// ============================================================

TEST(Test_MiscStr, GetResult_WhiteWins) {
    EXPECT_EQ(RESULT_White, strGetResult("1-0"));
    EXPECT_EQ(RESULT_White, strGetResult("1"));
}

TEST(Test_MiscStr, GetResult_BlackWins) {
    EXPECT_EQ(RESULT_Black, strGetResult("0-1"));
    EXPECT_EQ(RESULT_Black, strGetResult("0"));
}

TEST(Test_MiscStr, GetResult_Draw) {
    EXPECT_EQ(RESULT_Draw, strGetResult("1/2-1/2"));
    EXPECT_EQ(RESULT_Draw, strGetResult("1/2"));
    EXPECT_EQ(RESULT_Draw, strGetResult("="));
}

TEST(Test_MiscStr, GetResult_Unknown) {
    EXPECT_EQ(RESULT_None, strGetResult("*"));
    EXPECT_EQ(RESULT_None, strGetResult(""));
    EXPECT_EQ(RESULT_None, strGetResult("X"));
}

// ============================================================
// strGetFlag tests
// ============================================================

TEST(Test_MiscStr, GetFlag_Yes) {
    EXPECT_EQ(FLAG_YES, strGetFlag("T"));
    EXPECT_EQ(FLAG_YES, strGetFlag("t"));
    EXPECT_EQ(FLAG_YES, strGetFlag("Y"));
    EXPECT_EQ(FLAG_YES, strGetFlag("y"));
    EXPECT_EQ(FLAG_YES, strGetFlag("1"));
    EXPECT_EQ(FLAG_YES, strGetFlag("J"));
    EXPECT_EQ(FLAG_YES, strGetFlag("S"));
    EXPECT_EQ(FLAG_YES, strGetFlag("O"));
}

TEST(Test_MiscStr, GetFlag_No) {
    EXPECT_EQ(FLAG_NO, strGetFlag("F"));
    EXPECT_EQ(FLAG_NO, strGetFlag("f"));
    EXPECT_EQ(FLAG_NO, strGetFlag("N"));
    EXPECT_EQ(FLAG_NO, strGetFlag("n"));
    EXPECT_EQ(FLAG_NO, strGetFlag("0"));
}

TEST(Test_MiscStr, GetFlag_Both) {
    EXPECT_EQ(FLAG_BOTH, strGetFlag("B"));
    EXPECT_EQ(FLAG_BOTH, strGetFlag("b"));
    EXPECT_EQ(FLAG_BOTH, strGetFlag("2"));
}

TEST(Test_MiscStr, GetFlag_Empty) {
    EXPECT_EQ(FLAG_EMPTY, strGetFlag(""));
    EXPECT_EQ(FLAG_EMPTY, strGetFlag("X"));
    EXPECT_EQ(FLAG_EMPTY, strGetFlag("?"));
}

// ============================================================
// strGetSquare tests
// ============================================================

TEST(Test_MiscStr, GetSquare_ValidSquares) {
    EXPECT_NE(NULL_SQUARE, strGetSquare("a1"));
    EXPECT_NE(NULL_SQUARE, strGetSquare("h8"));
    EXPECT_NE(NULL_SQUARE, strGetSquare("e4"));
    EXPECT_NE(NULL_SQUARE, strGetSquare("d5"));
}

TEST(Test_MiscStr, GetSquare_InvalidSquares) {
    EXPECT_EQ(NULL_SQUARE, strGetSquare("i1")); // invalid file
    EXPECT_EQ(NULL_SQUARE, strGetSquare("a9")); // invalid rank
    EXPECT_EQ(NULL_SQUARE, strGetSquare("A1")); // uppercase file
    EXPECT_EQ(NULL_SQUARE, strGetSquare(""));
}

TEST(Test_MiscStr, GetSquare_A1IsSmallest) {
    squareT a1 = strGetSquare("a1");
    squareT h8 = strGetSquare("h8");
    EXPECT_LT(a1, h8);
}

// ============================================================
// strIsUnknownName tests
// ============================================================

TEST(Test_MiscStr, IsUnknownName_True) {
    EXPECT_TRUE(strIsUnknownName(""));
    EXPECT_TRUE(strIsUnknownName("?"));
    EXPECT_TRUE(strIsUnknownName("-"));
}

TEST(Test_MiscStr, IsUnknownName_False) {
    EXPECT_FALSE(strIsUnknownName("Kasparov"));
    EXPECT_FALSE(strIsUnknownName("??"));
    EXPECT_FALSE(strIsUnknownName("--"));
    EXPECT_FALSE(strIsUnknownName(" "));
}

// ============================================================
// strIsSurnameOnly tests
// ============================================================

TEST(Test_MiscStr, IsSurnameOnly_True) {
    EXPECT_TRUE(strIsSurnameOnly("Kasparov"));
    EXPECT_TRUE(strIsSurnameOnly("Smith"));
}

TEST(Test_MiscStr, IsSurnameOnly_False) {
    EXPECT_FALSE(strIsSurnameOnly("Kasparov, G")); // contains comma
    EXPECT_FALSE(strIsSurnameOnly("KASPAROV"));    // two caps
    EXPECT_FALSE(strIsSurnameOnly("Smith1"));       // digit
    // Empty string: the loop never runs so capcount stays 0 and the function
    // returns true. This is an edge case of the implementation; callers
    // should check for empty strings before calling strIsSurnameOnly.
    EXPECT_TRUE(strIsSurnameOnly(""));
}

// ============================================================
// strPlural tests
// ============================================================

TEST(Test_MiscStr, Plural_OneReturnsEmpty) {
    EXPECT_STREQ("", strPlural(1));
}

TEST(Test_MiscStr, Plural_OtherReturnsS) {
    EXPECT_STREQ("s", strPlural(0));
    EXPECT_STREQ("s", strPlural(2));
    EXPECT_STREQ("s", strPlural(100));
}

// ============================================================
// strTrimDate tests
// ============================================================

TEST(Test_MiscStr, TrimDate_FullDate_NoTrimming) {
    char s[] = "2020.05.15";
    strTrimDate(s);
    EXPECT_STREQ("2020.05.15", s);
}

TEST(Test_MiscStr, TrimDate_UnknownDay) {
    char s[] = "2020.05.??";
    strTrimDate(s);
    EXPECT_STREQ("2020.05", s);
}

TEST(Test_MiscStr, TrimDate_UnknownMonthAndDay) {
    char s[] = "2020.??.??";
    strTrimDate(s);
    EXPECT_STREQ("2020", s);
}

TEST(Test_MiscStr, TrimDate_UnknownMonthButKnownDay_NotTrimmed) {
    // Only trim day when day is "??" - month is only trimmed when day was also ??
    char s[] = "2020.??.15";
    strTrimDate(s);
    EXPECT_STREQ("2020.??.15", s);
}

// ============================================================
// strTrimMarkCodes tests
// ============================================================

TEST(Test_MiscStr, TrimMarkCodes_NoMarkCodes) {
    char s[] = "Hello world";
    strTrimMarkCodes(s);
    EXPECT_STREQ("Hello world", s);
}

TEST(Test_MiscStr, TrimMarkCodes_WithMarkCode) {
    char s[] = "Good move[%mark a1,b2,red]!";
    strTrimMarkCodes(s);
    EXPECT_STREQ("Good move!", s);
}

TEST(Test_MiscStr, TrimMarkCodes_OnlyMarkCode) {
    char s[] = "[%mark a1,b2,red]";
    strTrimMarkCodes(s);
    // Only spaces left (none in this case) → empty string
    EXPECT_STREQ("", s);
}

TEST(Test_MiscStr, TrimMarkCodes_MultipleMarkCodes) {
    char s[] = "text[%mark ...]middle[%arrow ...]end";
    strTrimMarkCodes(s);
    EXPECT_STREQ("textmiddleend", s);
}

// ============================================================
// strTrimMarkup tests
// ============================================================

TEST(Test_MiscStr, TrimMarkup_NoTags) {
    char s[] = "Plain text";
    strTrimMarkup(s);
    EXPECT_STREQ("Plain text", s);
}

TEST(Test_MiscStr, TrimMarkup_BoldTag) {
    char s[] = "<b>Bold</b> text";
    strTrimMarkup(s);
    EXPECT_STREQ("Bold text", s);
}

TEST(Test_MiscStr, TrimMarkup_MultipleNested) {
    char s[] = "<i><b>text</b></i>";
    strTrimMarkup(s);
    EXPECT_STREQ("text", s);
}

// ============================================================
// strGetIntegers / strGetUnsigneds tests
// ============================================================

TEST(Test_MiscStr, GetIntegers_Basic) {
    int results[3] = {};
    strGetIntegers("10 -5 42", results, 3);
    EXPECT_EQ(10, results[0]);
    EXPECT_EQ(-5, results[1]);
    EXPECT_EQ(42, results[2]);
}

TEST(Test_MiscStr, GetIntegers_FewerThanRequested) {
    int results[3] = {99, 99, 99};
    strGetIntegers("10 20", results, 3);
    EXPECT_EQ(10, results[0]);
    EXPECT_EQ(20, results[1]);
    // third result: strGetInteger("") = 0
    EXPECT_EQ(0, results[2]);
}

TEST(Test_MiscStr, GetUnsigneds_Basic) {
    uint results[3] = {};
    strGetUnsigneds("1 2 3", results, 3);
    EXPECT_EQ(1u, results[0]);
    EXPECT_EQ(2u, results[1]);
    EXPECT_EQ(3u, results[2]);
}

// ============================================================
// strCompareRound tests
// ============================================================

TEST(Test_MiscStr, CompareRound_NumericOrder) {
    EXPECT_LT(strCompareRound("2", "10"), 0);
    EXPECT_GT(strCompareRound("10", "2"), 0);
    EXPECT_EQ(0, strCompareRound("5", "5"));
}

TEST(Test_MiscStr, CompareRound_SameNumber_ThenAlpha) {
    // Equal numbers fall back to string comparison
    EXPECT_EQ(0, strCompareRound("1", "1"));
    // "1a" vs "1b": numeric part same (1), string compare decides
    EXPECT_LT(strCompareRound("1a", "1b"), 0);
}

TEST(Test_MiscStr, CompareRound_NonNumericStrings) {
    // Non-numeric: strGetUnsigned returns 0 for both, falls back to alpha
    EXPECT_LT(strCompareRound("abc", "abd"), 0);
}

// ============================================================
// strGetFilterOp tests
// ============================================================

TEST(Test_MiscStr, GetFilterOp_AND) {
    EXPECT_EQ(FILTEROP_AND, strGetFilterOp("AND"));
    EXPECT_EQ(FILTEROP_AND, strGetFilterOp("and"));
    EXPECT_EQ(FILTEROP_AND, strGetFilterOp("0"));
    EXPECT_EQ(FILTEROP_AND, strGetFilterOp("A"));
    EXPECT_EQ(FILTEROP_AND, strGetFilterOp("a"));
}

TEST(Test_MiscStr, GetFilterOp_OR) {
    EXPECT_EQ(FILTEROP_OR, strGetFilterOp("OR"));
    EXPECT_EQ(FILTEROP_OR, strGetFilterOp("or"));
    EXPECT_EQ(FILTEROP_OR, strGetFilterOp("1"));
    EXPECT_EQ(FILTEROP_OR, strGetFilterOp("O"));
    EXPECT_EQ(FILTEROP_OR, strGetFilterOp("o"));
}

TEST(Test_MiscStr, GetFilterOp_RESET) {
    EXPECT_EQ(FILTEROP_RESET, strGetFilterOp("RESET"));
    EXPECT_EQ(FILTEROP_RESET, strGetFilterOp("reset"));
    EXPECT_EQ(FILTEROP_RESET, strGetFilterOp("2"));
    EXPECT_EQ(FILTEROP_RESET, strGetFilterOp("R"));
    EXPECT_EQ(FILTEROP_RESET, strGetFilterOp("r"));
}

TEST(Test_MiscStr, GetFilterOp_Default) {
    EXPECT_EQ(FILTEROP_RESET, strGetFilterOp("X")); // default
}

// ============================================================
// strIsPrefix / strIsCasePrefix / strIsAlphaPrefix tests
// ============================================================

TEST(Test_MiscStr, IsPrefix_Basic) {
    EXPECT_TRUE(strIsPrefix("Kas", "Kasparov"));
    EXPECT_TRUE(strIsPrefix("", "Kasparov"));
    EXPECT_TRUE(strIsPrefix("Kasparov", "Kasparov"));
    EXPECT_FALSE(strIsPrefix("Kasparov", "Kas"));
    EXPECT_FALSE(strIsPrefix("kas", "Kasparov")); // case-sensitive
}

TEST(Test_MiscStr, IsCasePrefix_Basic) {
    EXPECT_TRUE(strIsCasePrefix("kas", "Kasparov"));
    EXPECT_TRUE(strIsCasePrefix("KAS", "kasparov"));
    EXPECT_FALSE(strIsCasePrefix("Kasparov", "Kas"));
}

TEST(Test_MiscStr, IsAlphaPrefix_IgnoresSpaces) {
    EXPECT_TRUE(strIsAlphaPrefix("smith,j", "Smith, John"));
    EXPECT_TRUE(strIsAlphaPrefix("SMITH", "Smith, John"));
    EXPECT_FALSE(strIsAlphaPrefix("jones", "Smith, John"));
}

// ============================================================
// strContains / strAlphaContains tests
// ============================================================

TEST(Test_MiscStr, Contains_Basic) {
    EXPECT_TRUE(strContains("Hello World", "World"));
    EXPECT_TRUE(strContains("Hello World", ""));
    EXPECT_FALSE(strContains("Hello World", "world")); // case-sensitive
    EXPECT_FALSE(strContains("Hello", "HelloWorld"));
}

TEST(Test_MiscStr, AlphaContains_CaseInsensitiveIgnoresSpaces) {
    EXPECT_TRUE(strAlphaContains("Smith, John", "th,j"));
    EXPECT_TRUE(strAlphaContains("Smith, John", "SMITH"));
    EXPECT_FALSE(strAlphaContains("Smith, John", "xyz"));
}

// ============================================================
// strFirstWord / strNextWord tests
// ============================================================

TEST(Test_MiscStr, FirstWord_SkipsLeadingSpaces) {
    EXPECT_STREQ("hello world", strFirstWord("  hello world"));
    EXPECT_STREQ("hello", strFirstWord("hello"));
    EXPECT_STREQ("", strFirstWord("   "));
}

TEST(Test_MiscStr, NextWord_SkipsCurrentAndSpaces) {
    const char* s = "hello world test";
    const char* next = strNextWord(s);
    EXPECT_STREQ("world test", next);
    next = strNextWord(next);
    EXPECT_STREQ("test", next);
    next = strNextWord(next);
    EXPECT_STREQ("", next);
}

// ============================================================
// strPad tests
// ============================================================

TEST(Test_MiscStr, Pad_ExactWidth) {
    char buf[16] = {};
    strPad(buf, "hello", 5, ' ');
    EXPECT_STREQ("hello", buf);
}

TEST(Test_MiscStr, Pad_PadRight) {
    char buf[16] = {};
    strPad(buf, "hi", 5, '*');
    EXPECT_STREQ("hi***", buf);
}

TEST(Test_MiscStr, Pad_TruncateRight) {
    char buf[16] = {};
    strPad(buf, "hello world", 5, ' ');
    EXPECT_STREQ("hello", buf);
}

TEST(Test_MiscStr, Pad_NegativeWidth_JustCopy) {
    char buf[64] = {};
    uint n = strPad(buf, "hello", -1, ' ');
    EXPECT_STREQ("hello", buf);
    EXPECT_EQ(5u, n);
}

// ============================================================
// strFirstChar / strLastChar tests
// ============================================================

TEST(Test_MiscStr, FirstChar_Found) {
    const char* s = "hello.world.txt";
    const char* p = strFirstChar(s, '.');
    EXPECT_NE(nullptr, p);
    EXPECT_STREQ(".world.txt", p);
}

TEST(Test_MiscStr, FirstChar_NotFound) {
    EXPECT_EQ(nullptr, strFirstChar("hello", '.'));
}

TEST(Test_MiscStr, LastChar_Found) {
    const char* s = "hello.world.txt";
    const char* p = strLastChar(s, '.');
    EXPECT_NE(nullptr, p);
    EXPECT_STREQ(".txt", p);
}

TEST(Test_MiscStr, LastChar_NotFound) {
    EXPECT_EQ(nullptr, strLastChar("hello", '.'));
}

// ============================================================
// strStrip tests
// ============================================================

TEST(Test_MiscStr, Strip_RemovesAllOccurrences) {
    char s[] = "h.e.l.l.o";
    strStrip(s, '.');
    EXPECT_STREQ("hello", s);
}

TEST(Test_MiscStr, Strip_NoOccurrences) {
    char s[] = "hello";
    strStrip(s, '.');
    EXPECT_STREQ("hello", s);
}

TEST(Test_MiscStr, Strip_AllMatch) {
    char s[] = "...";
    strStrip(s, '.');
    EXPECT_STREQ("", s);
}

// ============================================================
// strTrimLeft tests
// ============================================================

TEST(Test_MiscStr, TrimLeft_LeadingSpaces) {
    EXPECT_STREQ("hello", strTrimLeft("   hello"));
    EXPECT_STREQ("hello  ", strTrimLeft("  hello  "));
    EXPECT_STREQ("hello", strTrimLeft("hello"));
    EXPECT_STREQ("", strTrimLeft("   "));
}

TEST(Test_MiscStr, TrimLeft_CustomChars) {
    EXPECT_STREQ("hello", strTrimLeft("***hello", "*"));
}

// ============================================================
// strTrimSuffix tests
// ============================================================

TEST(Test_MiscStr, TrimSuffix_RemovesFromLastOccurrence) {
    char s[] = "file.tar.gz";
    uint n = strTrimSuffix(s, '.');
    EXPECT_STREQ("file.tar", s);
    EXPECT_EQ(3u, n); // returns count of chars from last '.' to end: '.', 'g', 'z'
}

TEST(Test_MiscStr, TrimSuffix_NoneFound) {
    char s[] = "filename";
    uint n = strTrimSuffix(s, '.');
    EXPECT_STREQ("filename", s);
    EXPECT_EQ(0u, n);
}

// ============================================================
// strDuplicate tests
// ============================================================

TEST(Test_MiscStr, Duplicate_Basic) {
    char* copy = strDuplicate("hello");
    EXPECT_STREQ("hello", copy);
    EXPECT_NE(nullptr, copy);
    delete[] copy;
}

TEST(Test_MiscStr, Duplicate_EmptyString) {
    char* copy = strDuplicate("");
    EXPECT_STREQ("", copy);
    EXPECT_NE(nullptr, copy);
    delete[] copy;
}

// ============================================================
// strUniqueExactMatch tests
// ============================================================

TEST(Test_MiscStr, UniqueExactMatch_ExactHit) {
    const char* table[] = {"repeat", "replace", "remove", nullptr};
    EXPECT_EQ(0, strUniqueExactMatch("repeat", table, true));
    EXPECT_EQ(1, strUniqueExactMatch("replace", table, true));
    EXPECT_EQ(2, strUniqueExactMatch("remove", table, true));
}

TEST(Test_MiscStr, UniqueExactMatch_NoMatch) {
    const char* table[] = {"repeat", "replace", nullptr};
    EXPECT_EQ(-1, strUniqueExactMatch("xyz", table, false));
    EXPECT_EQ(-1, strUniqueExactMatch("xyz", table, true));
}

TEST(Test_MiscStr, UniqueExactMatch_AmbiguousAbbrev) {
    const char* table[] = {"repeat", "replace", nullptr};
    // "rep" is a prefix of both - ambiguous
    EXPECT_EQ(-1, strUniqueExactMatch("rep", table, false));
}

TEST(Test_MiscStr, UniqueExactMatch_UniqueAbbrev) {
    const char* table[] = {"repeat", "replace", nullptr};
    // "repl" uniquely matches "replace"
    EXPECT_EQ(1, strUniqueExactMatch("repl", table, false));
    // "repea" uniquely matches "repeat"
    EXPECT_EQ(0, strUniqueExactMatch("repea", table, false));
}

TEST(Test_MiscStr, UniqueExactMatch_ExactRequired_NoAbbrev) {
    const char* table[] = {"repeat", "replace", nullptr};
    EXPECT_EQ(-1, strUniqueExactMatch("repl", table, true)); // exact=true, no abbrev
}

TEST(Test_MiscStr, UniqueExactMatch_NullInputs) {
    EXPECT_EQ(-1, strUniqueExactMatch(nullptr, nullptr, false));
}

// ============================================================
// strGetInteger / strGetUnsigned tests
// ============================================================

TEST(Test_MiscStr, GetInteger_Basic) {
    EXPECT_EQ(42, strGetInteger("42"));
    EXPECT_EQ(-7, strGetInteger("-7"));
    EXPECT_EQ(0, strGetInteger("0"));
    EXPECT_EQ(0, strGetInteger("abc"));
    EXPECT_EQ(123, strGetInteger("123abc")); // stops at non-digit
}

TEST(Test_MiscStr, GetUnsigned_Basic) {
    EXPECT_EQ(42u, strGetUnsigned("42"));
    EXPECT_EQ(0u, strGetUnsigned("0"));
    EXPECT_EQ(0u, strGetUnsigned("abc"));
}
