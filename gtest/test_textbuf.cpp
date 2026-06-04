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

#include "textbuf.h"
#include <gtest/gtest.h>
#include <cstring>

// ============================================================
// TextBuffer construction / initialization
// ============================================================

TEST(Test_TextBuffer, DefaultConstructor_InitializesState) {
    TextBuffer tb;
    EXPECT_EQ(1280000u, tb.GetBufferSize());
    EXPECT_EQ(0u, tb.GetByteCount());
    EXPECT_EQ(0u, tb.GetLineCount());
    EXPECT_EQ(0u, tb.GetColumn());
    EXPECT_NE(nullptr, tb.GetBuffer());
}

TEST(Test_TextBuffer, SetBufferSize_ResetsState) {
    TextBuffer tb;
    tb.PrintChar('A');
    tb.SetBufferSize(512);
    EXPECT_EQ(512u, tb.GetBufferSize());
    EXPECT_EQ(0u, tb.GetByteCount());
    EXPECT_EQ(0u, tb.GetLineCount());
}

TEST(Test_TextBuffer, Empty_ResetsCounters) {
    TextBuffer tb;
    tb.PrintChar('X');
    EXPECT_EQ(1u, tb.GetByteCount());
    tb.Empty();
    EXPECT_EQ(0u, tb.GetByteCount());
    EXPECT_EQ(0u, tb.GetLineCount());
    EXPECT_EQ(0u, tb.GetColumn());
}

// ============================================================
// Wrap column and indent
// ============================================================

TEST(Test_TextBuffer, SetGetWrapColumn) {
    TextBuffer tb;
    tb.SetWrapColumn(40);
    EXPECT_EQ(40u, tb.GetWrapColumn());
    tb.SetWrapColumn(120);
    EXPECT_EQ(120u, tb.GetWrapColumn());
}

TEST(Test_TextBuffer, SetGetIndent) {
    TextBuffer tb;
    tb.SetIndent(4);
    EXPECT_EQ(4u, tb.GetIndent());
    tb.SetIndent(0);
    EXPECT_EQ(0u, tb.GetIndent());
}

// ============================================================
// PrintChar tests
// ============================================================

TEST(Test_TextBuffer, PrintChar_SingleChar) {
    TextBuffer tb;
    EXPECT_EQ(OK, tb.PrintChar('A'));
    EXPECT_EQ(1u, tb.GetByteCount());
    EXPECT_EQ(1u, tb.GetColumn());
    std::string buf(tb.GetBuffer(), tb.GetByteCount());
    EXPECT_EQ("A", buf);
}

TEST(Test_TextBuffer, PrintChar_MultipleChars) {
    TextBuffer tb;
    tb.PrintChar('H');
    tb.PrintChar('i');
    EXPECT_EQ(2u, tb.GetByteCount());
    std::string buf(tb.GetBuffer(), tb.GetByteCount());
    EXPECT_EQ("Hi", buf);
}

TEST(Test_TextBuffer, PrintChar_WrapAtWrapColumn) {
    TextBuffer tb;
    tb.SetWrapColumn(5);
    // Fill up to column 4 (0-indexed, column becomes 4 after 4 chars)
    for (int i = 0; i < 4; ++i) tb.PrintChar('X');
    EXPECT_EQ(4u, tb.GetColumn());
    // Next char triggers wrap (column+1 >= WrapColumn=5)
    tb.PrintChar('Y');
    // A newline was inserted before Y, so we're now on a new line
    EXPECT_GT(tb.GetLineCount(), 0u);
}

// ============================================================
// PrintString tests
// ============================================================

TEST(Test_TextBuffer, PrintString_Simple) {
    TextBuffer tb;
    tb.SetWrapColumn(80);
    tb.PrintString("hello world");
    std::string buf(tb.GetBuffer());
    EXPECT_NE(std::string::npos, buf.find("hello"));
    EXPECT_NE(std::string::npos, buf.find("world"));
}

TEST(Test_TextBuffer, PrintString_Empty) {
    TextBuffer tb;
    EXPECT_EQ(OK, tb.PrintString(""));
    EXPECT_EQ(0u, tb.GetByteCount());
}

TEST(Test_TextBuffer, PrintString_WordWrapping) {
    TextBuffer tb;
    tb.SetWrapColumn(10);
    tb.PrintString("hello world");
    // Should have introduced at least one newline
    EXPECT_GT(tb.GetLineCount(), 0u);
}

TEST(Test_TextBuffer, PrintString_WithNewlineConverted) {
    TextBuffer tb;
    tb.NewlinesToSpaces(true);
    tb.PrintString("line1\nline2");
    // Newlines should be converted to spaces (no actual line breaks)
    std::string buf(tb.GetBuffer());
    // line1 and line2 should both appear
    EXPECT_NE(std::string::npos, buf.find("line1"));
    EXPECT_NE(std::string::npos, buf.find("line2"));
}

// ============================================================
// PrintWord tests
// ============================================================

TEST(Test_TextBuffer, PrintWord_Basic) {
    TextBuffer tb;
    tb.SetWrapColumn(80);
    tb.PrintWord("hello");
    EXPECT_EQ(5u, tb.GetByteCount());
    EXPECT_STREQ("hello", tb.GetBuffer());
}

TEST(Test_TextBuffer, PrintWord_WrapWhenTooLong) {
    TextBuffer tb;
    tb.SetWrapColumn(6);
    tb.PrintWord("abcde"); // 5 chars, column=5
    tb.PrintWord("fg");    // 5+2=7 >= 6, triggers wrap first
    EXPECT_GT(tb.GetLineCount(), 0u);
}

// ============================================================
// PrintLine tests
// ============================================================

TEST(Test_TextBuffer, PrintLine_AddsNewline) {
    TextBuffer tb;
    tb.PrintLine("hello");
    EXPECT_EQ(1u, tb.GetLineCount());
    EXPECT_EQ(0u, tb.GetColumn()); // reset to 0 after newline
}

TEST(Test_TextBuffer, PrintLine_EmptyString) {
    TextBuffer tb;
    tb.PrintLine("");
    EXPECT_EQ(1u, tb.GetLineCount());
}

TEST(Test_TextBuffer, PrintLine_MultipleLines) {
    TextBuffer tb;
    tb.PrintLine("line1");
    tb.PrintLine("line2");
    tb.PrintLine("line3");
    EXPECT_EQ(3u, tb.GetLineCount());
    std::string buf(tb.GetBuffer());
    EXPECT_NE(std::string::npos, buf.find("line1"));
    EXPECT_NE(std::string::npos, buf.find("line2"));
    EXPECT_NE(std::string::npos, buf.find("line3"));
}

// ============================================================
// NewLine tests
// ============================================================

TEST(Test_TextBuffer, NewLine_IncrementsLineCount) {
    TextBuffer tb;
    EXPECT_EQ(0u, tb.GetLineCount());
    tb.NewLine();
    EXPECT_EQ(1u, tb.GetLineCount());
    tb.NewLine();
    EXPECT_EQ(2u, tb.GetLineCount());
}

TEST(Test_TextBuffer, NewLine_ResetsColumn) {
    TextBuffer tb;
    tb.PrintChar('A');
    EXPECT_EQ(1u, tb.GetColumn());
    tb.NewLine();
    EXPECT_EQ(0u, tb.GetColumn());
}

TEST(Test_TextBuffer, NewLine_WithIndent) {
    TextBuffer tb;
    tb.SetIndent(4);
    tb.NewLine();
    // After newline with indent=4, column should be 4
    EXPECT_EQ(4u, tb.GetColumn());
}

// ============================================================
// PrintInt tests
// ============================================================

TEST(Test_TextBuffer, PrintInt_Basic) {
    TextBuffer tb;
    tb.SetWrapColumn(80);
    tb.PrintInt(42);
    std::string buf(tb.GetBuffer());
    EXPECT_NE(std::string::npos, buf.find("42"));
}

TEST(Test_TextBuffer, PrintInt_Zero) {
    TextBuffer tb;
    tb.SetWrapColumn(80);
    tb.PrintInt(0);
    std::string buf(tb.GetBuffer());
    EXPECT_NE(std::string::npos, buf.find("0"));
}

TEST(Test_TextBuffer, PrintInt_WithSuffix) {
    TextBuffer tb;
    tb.SetWrapColumn(80);
    tb.PrintInt(5, ".");
    std::string buf(tb.GetBuffer());
    EXPECT_NE(std::string::npos, buf.find("5."));
}

// ============================================================
// PrintSpace tests
// ============================================================

TEST(Test_TextBuffer, PrintSpace_IncreasesColumn) {
    TextBuffer tb;
    tb.SetWrapColumn(80);
    uint col = tb.GetColumn();
    tb.PrintChar('A'); // column = 1
    tb.PrintSpace();
    EXPECT_EQ(2u, tb.GetColumn());
}

TEST(Test_TextBuffer, PrintSpace_AtWrapColumn_Wraps) {
    TextBuffer tb;
    tb.SetWrapColumn(5);
    // Fill to column 4
    for (int i = 0; i < 4; ++i) tb.PrintChar('X');
    EXPECT_EQ(4u, tb.GetColumn());
    // PrintSpace at column 4: column+1=5 >= WrapColumn=5, should wrap
    tb.PrintSpace();
    EXPECT_GT(tb.GetLineCount(), 0u);
}

// ============================================================
// Translation table tests
// ============================================================

TEST(Test_TextBuffer, AddTranslation_ReplacesChar) {
    TextBuffer tb;
    tb.AddTranslation('A', "ALPHA");
    tb.PrintWord("A"); // PrintWord null-terminates the buffer
    std::string buf(tb.GetBuffer(), tb.GetByteCount());
    EXPECT_EQ("ALPHA", buf);
}

TEST(Test_TextBuffer, ClearTranslation_RemovesReplacement) {
    TextBuffer tb;
    tb.AddTranslation('A', "ALPHA");
    tb.ClearTranslation('A');
    tb.PrintWord("A");
    std::string buf(tb.GetBuffer(), tb.GetByteCount());
    EXPECT_EQ("A", buf);
}

TEST(Test_TextBuffer, PauseResumeTranslations) {
    {
        // With translations paused, 'A' should not be translated
        TextBuffer tb;
        tb.AddTranslation('A', "ALPHA");
        tb.PauseTranslations();
        tb.PrintWord("A");
        std::string buf(tb.GetBuffer(), tb.GetByteCount());
        EXPECT_EQ("A", buf);
    }
    {
        // With translations active, 'A' should be translated
        TextBuffer tb;
        tb.AddTranslation('A', "ALPHA");
        tb.PrintWord("A");
        std::string buf(tb.GetBuffer(), tb.GetByteCount());
        EXPECT_EQ("ALPHA", buf);
    }
}

TEST(Test_TextBuffer, ClearTranslations_DisablesAll) {
    TextBuffer tb;
    tb.AddTranslation('A', "ALPHA");
    tb.AddTranslation('B', "BETA");
    tb.ClearTranslations();
    tb.PrintWord("AB");
    std::string buf(tb.GetBuffer(), tb.GetByteCount());
    EXPECT_EQ("AB", buf);
}

// ============================================================
// Indent tests
// ============================================================

TEST(Test_TextBuffer, Indent_WhenLineNotEmpty_CallsNewLine) {
    TextBuffer tb;
    tb.SetIndent(4);
    tb.PrintChar('X'); // make line non-empty
    tb.Indent();       // should issue newline then indent
    EXPECT_GE(tb.GetLineCount(), 1u);
    EXPECT_EQ(4u, tb.GetColumn());
}

TEST(Test_TextBuffer, Indent_WhenLineEmpty_JustIndents) {
    TextBuffer tb;
    tb.SetIndent(3);
    // Line starts empty; Indent should just move to indent column
    tb.Indent();
    EXPECT_EQ(0u, tb.GetLineCount());
    EXPECT_EQ(3u, tb.GetColumn());
}

// ============================================================
// Buffer overflow detection
// ============================================================

TEST(Test_TextBuffer, BufferFull_ReturnsError) {
    TextBuffer tb;
    tb.SetBufferSize(4); // very small
    // Filling up 4 chars should eventually return ERROR_BufferFull
    errorT result = OK;
    for (int i = 0; i < 10; ++i) {
        result = tb.PrintChar('X');
        if (result != OK) break;
    }
    EXPECT_EQ(ERROR_BufferFull, result);
}

// ============================================================
// NewlinesToSpaces
// ============================================================

TEST(Test_TextBuffer, NewlinesToSpaces_ControlsConversion) {
    // Default is true (convert newlines to spaces)
    TextBuffer tb;
    tb.SetWrapColumn(1000); // large wrap to avoid auto-wrapping
    tb.NewlinesToSpaces(false);
    tb.PrintString("a\nb");
    // With ConvertNewlines=false, '\n' in PrintString triggers NewLine()
    EXPECT_GE(tb.GetLineCount(), 1u);
}
