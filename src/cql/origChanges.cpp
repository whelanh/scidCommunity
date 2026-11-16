#include "common.h"
#include "error.h"
#include "game.h"
#include "position.h"

#include "bytebuf.h"
#include "textbuf.h"
#include "stored.h"
#include "util.h"

//changes game::writetopgn...

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Game::WritePGN():
//      Write a game in PGN to a textbuffer.  If stopLocation is
//      non-zero, it indicates a byte count at which the output should
//      stop, leaving the game at that position. If it is zero, the
//      entire game is printed and the game position prior to the
//      WritePGN() call is restored.  So a nonzero stopLocation is used
//      to move to a position in the game.
//
errorT
Game::WritePGN_CQL (TextBuffer * tb, uint stopLocation)
{
    char temp [255];
    char dateStr [20];
    const char * newline = "\n";
    tb->NewlinesToSpaces (false);
    if (IsHtmlFormat()) { newline = "<br>\n"; }
    if (IsLatexFormat()) {
        newline = "\\\\\n";
        tb->AddTranslation ('#', "\\#");
        tb->AddTranslation ('%', "\\%");
        tb->AddTranslation ('&', "\\&");
        tb->AddTranslation ('<', "$<$");
        tb->AddTranslation ('>', "$>$");
        tb->AddTranslation ('_', "\\_");
        // tb->AddTranslation ('[', "$[$");
        // tb->AddTranslation (']', "$]$");
    }
    if (IsColorFormat()) {
        newline = "<br>";
    }

    if (PgnStyle & PGN_STYLE_COLUMN) {
        PgnStyle |= PGN_STYLE_INDENT_COMMENTS;
        PgnStyle |= PGN_STYLE_INDENT_VARS;
    }


    date_DecodeToString (Date, dateStr);
    if (IsHtmlFormat()) { tb->PrintLine("<p><b>"); }
    if (IsLatexFormat()) { tb->PrintLine ("{\\bf"); }

    if (PgnStyle & PGN_STYLE_SHORT_HEADER) {
        // Print tags in short, 3-line format:

        //if (IsHtmlFormat()) { tb->PrintString ("<font size=+1>"); }
        if (IsLatexFormat()) { tb->PrintString ("$\\circ$ "); }
        tb->PrintString (WhiteStr);
        if (WhiteElo > 0) {
            sprintf (temp, "  (%u)", WhiteElo);
            tb->PrintString (temp);
        }
        switch (PgnFormat) {
        case PGN_FORMAT_HTML:
            tb->PrintString (" &nbsp;&nbsp; -- &nbsp;&nbsp; ");
            break;
        case PGN_FORMAT_Latex:
            tb->PrintString (newline);
            tb->PrintString ("$\\bullet$ ");
            break;
        default:
            tb->PrintString ("   --   ");
            break;
        }
        tb->PrintString (BlackStr);
        if (BlackElo > 0) {
            sprintf (temp, "  (%u)", BlackElo);
            tb->PrintString (temp);
        }
        //if (IsHtmlFormat()) { tb->PrintString ("</font>"); }
        tb->PrintString (newline);

        tb->PrintString (EventStr);
        if (!strEqual (RoundStr, "")  &&  !strEqual (RoundStr, "?")) {
            tb->PrintString (IsHtmlFormat() ? " &nbsp;(" : " (");
            tb->PrintString (RoundStr);
            tb->PrintString (")");
        }
        tb->PrintString (IsHtmlFormat() ? "&nbsp;&nbsp; " : "  ");
        if (IsLatexFormat()) { tb->PrintString (newline); }
        if (!strEqual (SiteStr, "")  &&  !strEqual (SiteStr, "?")) {
            tb->PrintString (SiteStr);
            tb->PrintString (newline);
        }

        // Remove ".??" or ".??.??" from end of dateStr, then print it:
        if (dateStr[4] == '.'  &&  dateStr[5] == '?') { dateStr[4] = 0; }
        if (dateStr[7] == '.'  &&  dateStr[8] == '?') { dateStr[7] = 0; }
        tb->PrintString (dateStr);

        // Print ECO code:
        tb->PrintString (IsHtmlFormat() ? " &nbsp; &nbsp; " : "  ");
        if (IsLatexFormat()) { tb->PrintString ("\\hfill "); }
        tb->PrintString (RESULT_LONGSTR[Result]);
        if (EcoCode != 0) {
            tb->PrintString (IsHtmlFormat() ? " &nbsp; &nbsp; " : "  ");
            if (IsLatexFormat()) { tb->PrintString ("\\hfill "); }
            ecoStringT ecoStr;
            eco_ToExtendedString (EcoCode, ecoStr);
            tb->PrintString (ecoStr);
        }
        tb->PrintString (newline);

        // Print FEN if non-standard start:
        if (NonStandardStart) {
            if (IsLatexFormat()) {
                tb->PrintString ("\n\\begin{diagram}\n");
                DString dstr;
                StartPos->DumpLatexBoard (&dstr);
                tb->PrintString (dstr.Data());
                tb->PrintString ("\n\\end{diagram}\n");
            } else if (IsHtmlFormat()) {
                DString dstr;
                StartPos->DumpHtmlBoard (&dstr, HtmlStyle, NULL);
                tb->PrintString (dstr.Data());
            } else {
                char fenStr [256];
                StartPos->PrintFEN (fenStr, FEN_ALL_FIELDS);
                sprintf (temp, "Position: %s%s", fenStr, newline);
                tb->PrintString (temp);
            }
        }

    } else {
        // Print tags in standard PGN format, one per line:
        // Note: we want no line-wrapping when printing PGN tags
        // so set it to a huge value for now:
        uint wrapColumn = tb->GetWrapColumn();
        tb->SetWrapColumn (99999);
        if (IsColorFormat()) { tb->PrintString ("<tag>"); }
        sprintf (temp, "[Event \"%s\"]%s", EventStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[Site \"%s\"]%s", SiteStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[Date \"%s\"]%s", dateStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[Round \"%s\"]%s", RoundStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[White \"%s\"]%s", WhiteStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[Black \"%s\"]%s", BlackStr, newline);
        tb->PrintString (temp);
        sprintf (temp, "[Result \"%s\"]%s", RESULT_LONGSTR[Result], newline);
        tb->PrintString (temp);

        // Print all tags, not just the standard seven, if applicable:
        if (PgnStyle & PGN_STYLE_TAGS) {
            if (WhiteElo > 0) {
                sprintf (temp, "[White%s \"%u\"]%s",
                         ratingTypeNames [WhiteRatingType], WhiteElo, newline);
                tb->PrintString (temp);
            }
            if (BlackElo > 0) {
                sprintf (temp, "[Black%s \"%u\"]%s",
                         ratingTypeNames [BlackRatingType], BlackElo, newline);
                tb->PrintString (temp);
            }
            if (EcoCode != 0) {
                ecoStringT ecoStr;
                eco_ToExtendedString (EcoCode, ecoStr);
                sprintf (temp, "[ECO \"%s\"]%s", ecoStr, newline);
                tb->PrintString (temp);
            }
            if (EventDate != ZERO_DATE) {
                char edateStr [20];
                date_DecodeToString (EventDate, edateStr);
                sprintf (temp, "[EventDate \"%s\"]%s", edateStr, newline);
                tb->PrintString (temp);
            }

            if (PgnStyle & PGN_STYLE_SCIDFLAGS  &&  *ScidFlags != 0) {
                sprintf (temp, "[ScidFlags \"%s\"]%s", ScidFlags, newline);
                tb->PrintString (temp);
            }

            // Now print other tags
            for (uint i=0; i < NumTags; i++) {
                sprintf (temp, "[%s \"%s\"]%s",
                         TagList[i].tag, TagList[i].value, newline);
                tb->PrintString (temp);
            }
        }
        // Finally, write the FEN tag if necessary:
        if (NonStandardStart) {
            char fenStr [256];
            StartPos->PrintFEN (fenStr, FEN_ALL_FIELDS);
            sprintf (temp, "[FEN \"%s\"]%s", fenStr, newline);
            tb->PrintString (temp);
        }
        if (IsColorFormat()) { tb->PrintString ("</tag>"); }
        // Now restore the linewrap column:
        tb->SetWrapColumn (wrapColumn);
    }
    if (IsHtmlFormat()) { tb->PrintLine("</b></p>"); }
    if (IsLatexFormat()) { 
        tb->PrintLine ("}\n\\begin{chess}{\\bf "); 
    } else {
        tb->PrintString (newline);
    }

    // Now print the move list. First, we note the current position and
    // move, so we can reconstruct the game state afterwards:
    moveT * oldCurrentMove = CurrentMove;
    if (stopLocation == 0) { SaveState(); }
    MoveToPly(0);
    PgnLastMovePos = PgnNextMovePos = 1;

    if (IsHtmlFormat()) { tb->PrintString ("<p>"); }
    NumMovesPrinted = 1;
    StopLocation = stopLocation;
    handleinitialcomment_CQL(tb);
    WriteMoveList (tb, StartPlyCount, oldCurrentMove, true, false);
    if (IsHtmlFormat()) { tb->PrintString ("<b>"); }
    if (IsLatexFormat()) { tb->PrintString ("\n}\\end{chess}\n{\\bf "); }
    if (IsColorFormat()) { tb->PrintString ("<tag>"); }
    tb->PrintWord (RESULT_LONGSTR [Result]);
    if (IsLatexFormat()) {
        tb->PrintString ("}\n\\begin{center} \\hrule \\end{center}");
    }
    if (IsHtmlFormat()) { tb->PrintString ("</b><hr></p>"); }
    if (IsColorFormat()) { tb->PrintString ("</tag>"); }
    tb->NewLine();

    // Now reset the current position and move:
    if (stopLocation == 0) { RestoreState(); }
    return OK;
}

void Game::handleinitialcomment_CQL(TextBuffer * tb){
  if(FirstMove->comment==NULL) return;
  tb->PrintString("{");
  tb->PrintString(" ");
  tb->PrintString(FirstMove->comment);
  tb->PrintLine("}");
}

errorT
Game::WriteToPGN_CQL(TextBuffer * tb){
  return WritePGN_CQL(tb,0);
}

void MFile::skipNonAscii(){
  uassert(Handle&&Location==0);
  int c;
  while(true){
    c=fgetc(Handle);
    uassert(c>0,"Unexpected end of file in skipNonAscii: possibly not valid PGN file");
    if(c>127)
      Location++;
    else{
      int u=ungetc(c,Handle);
      uassert(u>=0,"ungetc failed skipNonAscii: file problem reading PGN file");
      if(0&&Location)
	printf("skipNonAscii: skipped %d characters\n",(int)Location);
      return;
    }
  }
}
