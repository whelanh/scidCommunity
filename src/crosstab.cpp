//////////////////////////////////////////////////////////////////////
//
//  FILE:       crosstab.cpp
//              Crosstable class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    4.0
//
//  Notice:     Copyright (c) 2001 Shane Hudson.  All rights reserved.
//              Copyright (c) 2026 AI Modernized version.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#include "crosstab.h"

#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>

namespace {

constexpr std::array<uint, 51> kPerfEloDiff = {

    /*  50 -  59 */ 0,
    7,
    14,
    21,
    29,
    36,
    43,
    50,
    57,
    65,
    /*  60 -  69 */ 72,
    80,
    87,
    95,
    102,
    110,
    117,
    125,
    133,
    141,
    /*  70 -  79 */ 149,
    158,
    166,
    175,
    184,
    193,
    202,
    211,
    220,
    230,
    /*  80 -  89 */ 240,
    251,
    262,
    273,
    284,
    296,
    309,
    322,
    336,
    351,
    /*  90 -  99 */ 366,
    383,
    401,
    422,
    444,
    470,
    501,
    538,
    589,
    677,
    /*    100    */ 800

};

constexpr eloT kEloMargin = 350;

[[nodiscard]] int comparePlayerData(const playerDataT &p1,
                                    const playerDataT &p2,
                                    crosstableSortT option) {
  switch (option) {
  case CROSSTABLE_SortScore: {
    if (auto cmp = static_cast<int>(p2.score) - static_cast<int>(p1.score);
        cmp != 0)
      return cmp;
    if (auto cmp =
            static_cast<int>(p1.gameCount) - static_cast<int>(p2.gameCount);
        cmp != 0)
      return cmp;
    return static_cast<int>(p2.tiebreak) - static_cast<int>(p1.tiebreak);
  }
  case CROSSTABLE_SortName:
    return strCompare(p1.name.c_str(), p2.name.c_str());
  case CROSSTABLE_SortElo:
    return static_cast<int>(p2.elo) - static_cast<int>(p1.elo);
  case CROSSTABLE_SortCountry:
    return strCompare(p1.country.c_str(), p2.country.c_str());
  }
  return 0;
}

} // namespace

uint Crosstable::Performance(uint oppAvg, uint percentage) {
  percentage = std::min(percentage, 100u);
  if (percentage < 50) {
    return oppAvg - kPerfEloDiff[50 - percentage];
  }
  return oppAvg + kPerfEloDiff[percentage - 50];
}

int Crosstable::RatingChange(eloT player, uint oppAvg, uint percentage,
                             uint games) {
  const uint diff = (player > oppAvg) ? player - oppAvg : oppAvg - player;

  int i = 0;
  for (; i < 50 && diff > kPerfEloDiff[i]; ++i) {
  }

  uint expected = static_cast<uint>(i);
  if (player > oppAvg) {
    expected += 50;
  } else {
    expected = 50 - expected;
  }

  const int cutoff = (percentage > expected) ? 5 : -5;
  return ((static_cast<int>(percentage) - static_cast<int>(expected)) *
              static_cast<int>(games) +
          cutoff) /
         10;
}

uint Crosstable::FideCategory(eloT rating) {
  if (rating <= 2250) {
    return 0;
  }
  return 1 + ((rating - 2251) / 25);
}

eloT Crosstable::OpponentElo(eloT player, eloT opponent) {
  if (player == 0) {
    return opponent;
  }
  if (player > opponent && player - opponent > kEloMargin) {
    return player - kEloMargin;
  }
  if (opponent > player && opponent - player > kEloMargin) {
    return player + kEloMargin;
  }
  return opponent;
}

auto Crosstable::findPlayer(idNumberT id) const -> std::optional<std::size_t> {
  for (std::size_t i = 0; i < PlayerData.size(); ++i) {
    if (PlayerData[i]->id == id) {
      return i;
    }
  }
  return std::nullopt;
}

errorT Crosstable::AddPlayer(idNumberT id, const char *name, eloT elo,
                             const SpellChecker *SpellCheck) {
  if (auto idx = findPlayer(id)) {
    if (elo > PlayerData[*idx]->elo) {
      PlayerData[*idx]->elo = elo;
    }
    return OK;
  }

  if (PlayerData.size() >= CROSSTABLE_MaxPlayers) {
    return ERROR_Full;
  }

  auto pdata = std::make_unique<playerDataT>();
  pdata->id = id;
  pdata->name = name;
  pdata->elo = elo;

  if (SpellCheck != nullptr) {
    if (const auto *pInfo = SpellCheck->getPlayerInfo(name)) {
      pdata->title = pInfo->getTitle();
      pdata->country = pInfo->getLastCountry();
      pdata->birthdate = pInfo->getBirthdate();
      if (pdata->title == "w") {
        pdata->title = "w  ";
      }
    }
  }

  PlayerData.push_back(std::move(pdata));
  return OK;
}

errorT Crosstable::AddResult(uint gameNumber, idNumberT white, idNumberT black,
                             resultT result, uint round, dateT date) {
  auto whiteIdx = findPlayer(white);
  auto blackIdx = findPlayer(black);

  if (!whiteIdx || !blackIdx) {
    return ERROR_NotFound;
  }

  if (*whiteIdx == *blackIdx) {
    return ERROR_Corrupt;
  }

  auto &pwhite = *PlayerData[*whiteIdx];
  auto &pblack = *PlayerData[*blackIdx];

  clashT whiteClash{result, gameNumber, static_cast<uint>(*blackIdx), WHITE,
                    round};
  clashT blackClash{RESULT_OPPOSITE[result], gameNumber,
                    static_cast<uint>(*whiteIdx), BLACK, round};

  pwhite.clashes[*blackIdx].push_back(whiteClash);
  pblack.clashes[*whiteIdx].push_back(blackClash);

  if (round > 0 && round < CROSSTABLE_MaxRounds) {
    pwhite.roundClash[round] = whiteClash;
    pblack.roundClash[round] = blackClash;
    MaxRound = std::max(MaxRound, round);
  }

  MaxClashes =
      std::max(MaxClashes, static_cast<uint>(pwhite.clashes[*blackIdx].size()));

  pwhite.gameCount++;
  pblack.gameCount++;

  if (result != RESULT_None && pblack.elo > 0) {
    pwhite.oppEloCount++;
    pwhite.oppEloTotal += OpponentElo(pwhite.elo, pblack.elo);
  }
  if (result != RESULT_None && pwhite.elo > 0) {
    pblack.oppEloCount++;
    pblack.oppEloTotal += OpponentElo(pblack.elo, pwhite.elo);
  }

  if (FirstDate == ZERO_DATE || (date != ZERO_DATE && date < FirstDate)) {
    FirstDate = date;
  }

  const uint scoreMultiplier = ThreeWin ? 6 : 2;
  const uint drawScore = ThreeWin ? 2 : 1;

  switch (result) {
  case RESULT_White:
    pwhite.n_won++;
    pblack.n_loss++;
    pwhite.score += scoreMultiplier;
    if (pblack.elo > 0)
      pwhite.oppEloScore += 2;
    break;
  case RESULT_Black:
    pwhite.n_loss++;
    pblack.n_won++;
    pblack.score += scoreMultiplier;
    if (pwhite.elo > 0)
      pblack.oppEloScore += 2;
    break;
  case RESULT_Draw:
    pwhite.n_draw++;
    pblack.n_draw++;
    pwhite.score += drawScore;
    pblack.score += drawScore;
    if (pblack.elo > 0)
      pwhite.oppEloScore++;
    if (pwhite.elo > 0)
      pblack.oppEloScore++;
    break;
  default:
    break;
  }

  ResultCount[result]++;
  GameCount++;
  return OK;
}

void Crosstable::Tiebreaks(crosstableModeT mode) {
  const auto playerCount = PlayerData.size();

  for (std::size_t player = 0; player < playerCount; ++player) {
    auto &pdata = *PlayerData[player];
    pdata.tiebreak = 0;
    pdata.tb_head = 0;

    if (mode == CROSSTABLE_Knockout) {
      continue;
    }

    uint tb = 0;
    for (std::size_t opp = 0; opp < playerCount; ++opp) {
      if (opp == player) {
        continue;
      }

      for (const auto &clash : pdata.clashes[opp]) {
        const uint oppScore = PlayerData[opp]->score;

        if (mode == CROSSTABLE_Swiss) {
          tb += oppScore;
        } else {
          if (clash.result == RESULT_White) {
            tb += oppScore * 2;
          } else if (clash.result == RESULT_Draw) {
            tb += oppScore;
          }
        }

        if (pdata.score == oppScore) {
          if (clash.result == RESULT_White) {
            pdata.tb_head += 2;
          } else if (clash.result == RESULT_Draw) {
            pdata.tb_head += 1;
          }
        }
      }
    }
    pdata.tiebreak = tb;
  }
}

crosstableModeT Crosstable::BestMode() const {
  const auto playerCount = PlayerData.size();

  if (playerCount <= 12) {
    return CROSSTABLE_AllPlayAll;
  }
  if (playerCount > 30) {
    return CROSSTABLE_Swiss;
  }
  if (playerCount > 0 && (GameCount / playerCount) < 5) {
    return CROSSTABLE_Swiss;
  }

  const uint completeAllPlayAll =
      static_cast<uint>((playerCount * (playerCount - 1)) / 2);
  if (GameCount < completeAllPlayAll / 2) {
    return CROSSTABLE_Swiss;
  }

  return CROSSTABLE_AllPlayAll;
}

eloT Crosstable::AvgRating() const {
  uint count = 0;
  uint total = 0;

  for (const auto &pdata : PlayerData) {
    if (pdata->elo > 0) {
      total += pdata->elo;
      ++count;
    }
  }

  return (count > 0) ? static_cast<eloT>(total / count) : 0;
}

std::string Crosstable::PrintTable(crosstableModeT mode, uint playerLimit,
                                   int currentGame) {
  std::string output;
  CurrentGame = currentGame;
  const auto playerCount = static_cast<uint>(PlayerData.size());

  if (playerLimit == 0 || playerLimit > playerCount) {
    playerLimit = playerCount;
  }
  if (playerLimit < 2) {
    return {};
  }

  if (mode == CROSSTABLE_Auto) {
    mode = BestMode();
  }

  Tiebreaks(mode);

  SortedIndex.resize(playerCount);
  InvertedIndex.resize(playerCount);

  for (uint i = 0; i < playerCount; ++i) {
    SortedIndex[i] = i;
  }

  std::ranges::sort(SortedIndex, [this](uint a, uint b) {
    return comparePlayerData(*PlayerData[a], *PlayerData[b], SortOption) < 0;
  });

  for (uint i = 0; i < playerCount; ++i) {
    InvertedIndex[SortedIndex[i]] = i;
  }

  PlayerNumWidth = (playerLimit > 99) ? 3 : 2;

  LongestNameLen = 0;
  for (const auto &pdata : PlayerData) {
    LongestNameLen =
        std::max(LongestNameLen, static_cast<uint>(pdata->name.length()));
  }

  PrintRatings = false;
  PrintTitles = false;
  PrintCountries = false;
  PrintAges = false;
  PrintTiebreaks = true;
  PrintTallies = true;

  for (auto &pdata : PlayerData) {
    if (pdata->elo > 0)
      PrintRatings = true;
    if (!pdata->title.empty())
      PrintTitles = true;
    if (!pdata->country.empty())
      PrintCountries = true;
    if (pdata->birthdate != ZERO_DATE) {
      PrintAges = true;
      int age = static_cast<int>(date_GetYear(FirstDate)) -
                static_cast<int>(date_GetYear(pdata->birthdate));
      if (date_GetMonth(pdata->birthdate) > date_GetMonth(FirstDate)) {
        --age;
      }
      pdata->ageInYears = age;
    }
  }

  if (!ShowElos)
    PrintRatings = false;
  if (!ShowTitles)
    PrintTitles = false;
  if (!ShowCountries)
    PrintCountries = false;
  if (!ShowTallies)
    PrintTallies = false;
  if (!ShowAges)
    PrintAges = false;
  if (!ShowTiebreaks)
    PrintTiebreaks = false;
  if (mode == CROSSTABLE_Knockout)
    PrintTiebreaks = false;

  StartTable = "";
  EndTable = "";
  StartRow = "";
  EndRow = "";
  NewLine = "\n";
  BlankRowLine = "\n";
  StartCol = "";
  EndCol = "";
  StartRightCol = "";
  EndRightCol = "";
  StartBoldCol = "";
  EndBoldCol = "";

  if (OutputFormat == CROSSTABLE_Hypertext) {
    NewLine = "<br>";
    BlankRowLine = "<br>";
  } else if (OutputFormat == CROSSTABLE_Html) {
    StartTable = "\n<p><table border=1 cellspacing=0 cellpadding=4>\n";
    EndTable = "</table></p>\n";
    StartRow = "<tr>";
    EndRow = "</tr>";
    NewLine = "\n";
    BlankRowLine = "<tr></tr>\n";
    StartCol = "<td>";
    EndCol = "</td>";
    StartRightCol = "<td align=right>";
    EndRightCol = "</td>";
    StartBoldCol = "<th>";
    EndBoldCol = "</th>";
  }

  LineWidth = LongestNameLen;
  if (PrintRatings)
    LineWidth += 16;
  if (PrintTitles)
    LineWidth += 4;
  if (PrintCountries)
    LineWidth += 4;
  if (PrintAges)
    LineWidth += 4;

  if (mode == CROSSTABLE_Swiss) {
    LineWidth += 16 + PlayerNumWidth;
    LineWidth += (PlayerNumWidth + (SwissColors ? 3 : 2)) * MaxRound;
    if (PrintTiebreaks)
      LineWidth += 5;
  } else if (mode == CROSSTABLE_AllPlayAll) {
    LineWidth += 16 + PlayerNumWidth;
    LineWidth += (playerLimit == 2) ? (MaxClashes + 1)
                                    : (playerLimit * (MaxClashes + 1));
    if (PrintTiebreaks)
      LineWidth += 7;
  } else {
    LineWidth = (LongestNameLen * 2) + 17 + MaxClashes;
    if (PrintRatings)
      LineWidth += 10;
    if (PrintTitles)
      LineWidth += 8;
    if (PrintCountries)
      LineWidth += 8;
    if (PrintAges)
      LineWidth += 8;
  }

  switch (mode) {
  case CROSSTABLE_AllPlayAll:
    PrintAllPlayAll(output, playerLimit);
    break;
  case CROSSTABLE_Knockout:
    PrintKnockout(output, playerLimit);
    break;
  case CROSSTABLE_Swiss:
  case CROSSTABLE_Auto:
    PrintSwiss(output, playerLimit);
    break;
  }

  if (GameCount > 1) {
    if (OutputFormat == CROSSTABLE_Hypertext) {
      char buf[128];
      std::snprintf(buf, sizeof(buf),
                    "<blue><run ::crosstab::setFilter 0>%u games</run></blue>: "
                    "+%u -%u =%u",
                    GameCount, ResultCount[RESULT_White],
                    ResultCount[RESULT_Black], ResultCount[RESULT_Draw]);
      output += buf;
    } else {
      char buf[64];
      std::snprintf(buf, sizeof(buf), "%u games: +%u -%u =%u", GameCount,
                    ResultCount[RESULT_White], ResultCount[RESULT_Black],
                    ResultCount[RESULT_Draw]);
      output += buf;
    }

    if (ResultCount[RESULT_None] > 0) {
      char buf[16];
      std::snprintf(buf, sizeof(buf), " *%u", ResultCount[RESULT_None]);
      output += buf;
    }
    output += NewLine;
  }
  return output;
}

void Crosstable::PrintDashesLine(std::string &output) {
  if (OutputFormat == CROSSTABLE_Html) {
    return;
  }

  output.append(LineWidth, '-');
  output += NewLine;
}

void Crosstable::PrintPlayer(std::string &output, const playerDataT &pdata) {
  if (OutputFormat == CROSSTABLE_Hypertext) {
    output += "<pi ";
    output += pdata.name;
    output += ">";
  }

  output += StartCol;
  char buf[256];
  std::snprintf(buf, sizeof(buf), "%-*s ", (int)LongestNameLen,
                pdata.name.c_str());
  output += buf;
  output += EndCol;

  if (PrintRatings) {
    output += StartRightCol;
    if (pdata.elo > 0) {
      char b[16];
      std::snprintf(b, sizeof(b), "%4d ", pdata.elo);
      output += b;
    } else {
      output += (OutputFormat == CROSSTABLE_Html) ? "  -  " : "     ";
    }
    output += EndRightCol;
  }

  if (PrintTitles) {
    output += StartCol;
    if (OutputFormat == CROSSTABLE_Html && pdata.title.empty()) {
      output += " -  ";
    } else {
      char b[16];
      std::snprintf(b, sizeof(b), "%3s ", pdata.title.c_str());
      output += b;
    }
    output += EndCol;
  }

  if (PrintAges) {
    output += StartCol;
    if (pdata.ageInYears <= 0) {
      output += (OutputFormat == CROSSTABLE_Html) ? " -  " : "    ";
    } else {
      char b[16];
      std::snprintf(b, sizeof(b), "%3d ", pdata.ageInYears);
      output += b;
    }
    output += EndCol;
  }

  if (PrintCountries) {
    output += StartCol;
    if (OutputFormat == CROSSTABLE_Html && pdata.country.empty()) {
      output += " -  ";
    } else {
      char b[16];
      std::snprintf(b, sizeof(b), "%-3s ", pdata.country.c_str());
      output += b;
    }
    output += EndCol;
  }

  if (OutputFormat == CROSSTABLE_Hypertext) {
    output += "</pi>";
  }
}

void Crosstable::PrintPerformance(std::string &output,
                                  const playerDataT &pdata) {
  if (!PrintRatings) {
    return;
  }

  if (pdata.oppEloCount == 0) {
    if (PrintTallies) {
      output += StartRightCol;
      output +=
          (OutputFormat == CROSSTABLE_Html) ? "     -     " : "           ";
      output += EndRightCol;
    }
    return;
  }

  const int oppAvgRating =
      static_cast<int>(pdata.oppEloTotal / pdata.oppEloCount);
  int percentage =
      static_cast<int>(pdata.oppEloScore * 50 + pdata.oppEloCount / 2);
  percentage /= static_cast<int>(pdata.oppEloCount);

  const int performance = static_cast<int>(Performance(
      static_cast<uint>(oppAvgRating), static_cast<uint>(percentage)));

  if (performance > 0 && performance < 5000) {
    output += "   ";
    output += StartRightCol;
    if (pdata.elo > 0) {
      const int change =
          RatingChange(pdata.elo, static_cast<uint>(oppAvgRating),
                       static_cast<uint>(percentage), pdata.oppEloCount);
      char buf[32];
      std::snprintf(buf, sizeof(buf), "%4d %3d", performance, change);
      output += buf;
    } else {
      char buf[32];
      std::snprintf(buf, sizeof(buf), "%4d    ", performance);
      output += buf;
    }
    output += EndRightCol;
  }
}

void Crosstable::PrintAllPlayAll(std::string &output, uint playerLimit) {
  output += StartTable;

  output += StartRow;

  if (OutputFormat == CROSSTABLE_Hypertext) {
    output.append(PlayerNumWidth + 2, ' ');
    output += "<blue><run set ::crosstab(sort) name ; "
              "::crosstab::Refresh>Player</run></blue>";
    output.append(LongestNameLen - 6, ' ');
  } else if (OutputFormat == CROSSTABLE_Html) {
    output += "<th></th> <th>Player</th> ";
  } else {
    output.append(LongestNameLen + 2 + PlayerNumWidth, ' ');
  }

  if (PrintRatings) {
    if (OutputFormat == CROSSTABLE_Hypertext) {
      output += " <blue><run set ::crosstab(sort) rating ; "
                "::crosstab::Refresh>Rtng</run></blue>";
    } else {
      output += StartBoldCol;
      output += " Rtng";
      output += EndBoldCol;
    }
  }

  if (PrintTitles) {
    output += StartBoldCol;
    output += "  Ti";
    output += EndBoldCol;
  }

  if (PrintAges) {
    output += StartBoldCol;
    output += " Age";
    output += EndBoldCol;
  }

  if (PrintCountries) {
    if (OutputFormat == CROSSTABLE_Hypertext) {
      output += " <blue><run set ::crosstab(sort) country ; "
                "::crosstab::Refresh>Nat</run></blue>";
    } else {
      output += StartBoldCol;
      output += " Nat";
      output += EndBoldCol;
    }
  }
  if (PrintTiebreaks) {
    output += StartBoldCol;
    output += " (Tie) ";
    output += EndBoldCol;
  }

  for (uint player = 0; player < playerLimit; ++player) {
    std::string colHeader;
    if (APAColumnNums) {
      colHeader.resize(MaxClashes, ' ');
      uint pnum = player + 1;
      colHeader[MaxClashes - 1] = static_cast<char>('0' + (pnum % 10));
      if (MaxClashes >= 2 && pnum >= 10) {
        colHeader[MaxClashes - 2] = static_cast<char>('0' + ((pnum / 10) % 10));
      }
      if (MaxClashes >= 3 && pnum >= 100) {
        colHeader[MaxClashes - 3] =
            static_cast<char>('0' + ((pnum / 100) % 10));
      }
    } else {
      colHeader = PlayerData[SortedIndex[player]]->name;
      if (colHeader.length() < MaxClashes) {
        colHeader.resize(MaxClashes, ' ');
      } else {
        colHeader = colHeader.substr(0, MaxClashes);
      }
    }

    if (playerLimit == 2) {
      player = 1;
      colHeader = "12345678901234567890123456789012345678901234567890";
      colHeader = colHeader.substr(0, MaxClashes);
    }
  }

  if (PrintRatings) {
    output += "   ";
    output += StartBoldCol;
    output += "Perf Chg";
    output += EndBoldCol;
  }

  if (PrintTallies && OutputFormat == CROSSTABLE_Html) {
    output += "   ";
    output += StartBoldCol;
    output += "+/-/=";
    output += EndBoldCol;
  }

  output += EndRow;
  output += NewLine;

  PrintDashesLine(output);

  uint previousScore = 0;
  for (uint player = 0; player < playerLimit; ++player) {
    uint index = SortedIndex[player];
    const auto &pdata = *PlayerData[index];

    if (SeparateScoreGroups && SortOption == CROSSTABLE_SortScore) {
      if (player > 0 && pdata.score != previousScore) {
        output += BlankRowLine;
      }
    }
    previousScore = pdata.score;

    output += StartRow;
    output += StartRightCol;
    char buf[32];
    std::snprintf(buf, sizeof(buf), "%*u: ", (int)PlayerNumWidth, player + 1);
    output += buf;
    output += EndRightCol;

    PrintPlayer(output, pdata);

    output += StartRightCol;
    if (ThreeWin) {
      char b[16];
      std::snprintf(b, sizeof(b), " %2u%c%c  ", pdata.score / 2,
                    DecimalPointChar, (pdata.score & 1) ? '5' : '0');
      output += b;
    } else {
      char b[32];
      std::snprintf(b, sizeof(b), " %2u%c%c / %2u  ", pdata.score / 2,
                    DecimalPointChar, (pdata.score & 1) ? '5' : '0',
                    pdata.gameCount);
      output += b;
    }
    output += EndRightCol;

    if (PrintTiebreaks) {
      output += StartRightCol;
      char b[32];
      std::snprintf(b, sizeof(b), "%3u%c%02u ", pdata.tiebreak / 4,
                    DecimalPointChar, (pdata.tiebreak % 4) * 25);
      output += b;
      output += EndRightCol;
    }

    for (uint oppCount = 0; oppCount < playerLimit; ++oppCount) {
      if (playerLimit == 2 && oppCount == player) {
        continue;
      }
      uint opp = SortedIndex[oppCount];

      output += ' ';
      output += StartRightCol;

      const auto &clashes = pdata.clashes[opp];
      for (uint count = 0; count < MaxClashes; ++count) {
        if (count < clashes.size()) {
          const auto &clash = clashes[count];
          if (OutputFormat == CROSSTABLE_Hypertext) {
            if (CurrentGame == static_cast<int>(clash.gameNum)) {
              char b[64];
              std::snprintf(b, sizeof(b), "<green><g_%u>%c</g></green>",
                            clash.gameNum, RESULT_CHAR[clash.result]);
              output += b;
            } else {
              char b[64];
              std::snprintf(b, sizeof(b), "<blue><g_%u>%c</g></blue>",
                            clash.gameNum, RESULT_CHAR[clash.result]);
              output += b;
            }
          } else {
            if (RESULT_CHAR[clash.result] == '=') {
              output += "½";
            } else {
              output += RESULT_CHAR[clash.result];
            }
          }
        } else {
          output += '.';
        }
      }
      output += EndCol;
    }

    PrintPerformance(output, pdata);

    if (PrintTallies) {
      output += StartCol;
      char b[64];
      std::snprintf(b, sizeof(b), "  (+%u -%u =%u)", pdata.n_won, pdata.n_loss,
                    pdata.n_draw);
      output += b;
    }

    output += EndRow;
    output += NewLine;
  }

  PrintDashesLine(output);

  output += EndTable;
}

void Crosstable::PrintSwiss(std::string &output, uint playerLimit) {
  static constexpr std::array<const char *, NUM_RESULT_TYPES> resultStr = {
      "*", "+", "-", "="};

  output += StartTable;

  output += StartRow;

  if (OutputFormat == CROSSTABLE_Hypertext) {
    output.append(PlayerNumWidth + 2, ' ');
    output += "<blue><run set ::crosstab(sort) name ; "
              "::crosstab::Refresh>Player</run></blue>";
    output.append(LongestNameLen - 6, ' ');
  } else if (OutputFormat == CROSSTABLE_Html) {
    output += "<th></th> <th>Player</th> ";
  } else {
    output.append(LongestNameLen + 2 + PlayerNumWidth, ' ');
  }

  if (PrintRatings) {
    if (OutputFormat == CROSSTABLE_Hypertext) {
      output += " <blue><run set ::crosstab(sort) rating ; "
                "::crosstab::Refresh>Rtng</run></blue>";
    } else {
      output += StartBoldCol;
      output += " Rtng";
      output += EndBoldCol;
    }
  }

  if (PrintTitles) {
    output += StartBoldCol;
    output += "  Ti";
    output += EndBoldCol;
  }

  if (PrintAges) {
    output += StartBoldCol;
    output += " Age";
    output += EndBoldCol;
  }

  if (PrintCountries) {
    if (OutputFormat == CROSSTABLE_Hypertext) {
      output += " <blue><run set ::crosstab(sort) country ; "
                "::crosstab::Refresh>Nat</run></blue>";
    } else {
      output += StartBoldCol;
      output += " Nat";
      output += EndBoldCol;
    }
  }

  std::string_view scoreHeader =
      (OutputFormat == CROSSTABLE_Hypertext)
          ? "<blue><run set ::crosstab(sort) score ; "
            "::crosstab::Refresh>Score</run></blue>"
          : "Score";

  if (ThreeWin) {
    output += "  ";
    output += StartBoldCol;
    output += scoreHeader;
    output += EndBoldCol;
    output += ' ';
  } else {
    output += "   ";
    output += StartBoldCol;
    output += ' ';
    output += scoreHeader;
    output += ' ';
    output += EndBoldCol;
    output += "   ";
  }

  if (PrintTiebreaks) {
    output += StartBoldCol;
    output += "(Tie)";
    output += EndBoldCol;
  }

  for (uint round = 1; round <= MaxRound; ++round) {
    if (OutputFormat == CROSSTABLE_Hypertext) {
      char rBuf[32];
      std::snprintf(rBuf, sizeof(rBuf), " %*u ", (int)PlayerNumWidth, round);
      std::string roundStr = rBuf;
      if (SwissColors) {
        roundStr = " " + roundStr;
      }
      output += StartBoldCol;
      output += "<blue><run ::crosstab::setFilter ";
      output += roundStr;
      output += '>';
      output += roundStr;
      output += "</run></blue>";
      output += EndBoldCol;
    } else {
      output += StartBoldCol;
      char rBuf[32];
      std::snprintf(rBuf, sizeof(rBuf), " %*u ", (int)PlayerNumWidth, round);
      if (SwissColors) {
        output += " ";
      }
      output += rBuf;
      output += EndBoldCol;
    }
  }

  if (PrintRatings) {
    output += "   ";
    output += StartBoldCol;
    output += "Perf Chg";
    output += EndBoldCol;
  }

  if (PrintTallies && OutputFormat == CROSSTABLE_Html) {
    output += "   ";
    output += StartBoldCol;
    output += "+/-/=";
    output += EndBoldCol;
  }

  output += EndRow;
  output += NewLine;

  PrintDashesLine(output);

  uint previousScore = 0;
  for (uint player = 0; player < playerLimit; ++player) {
    uint index = SortedIndex[player];
    const auto &pdata = *PlayerData[index];

    if (SeparateScoreGroups && SortOption == CROSSTABLE_SortScore) {
      if (player > 0 && pdata.score != previousScore) {
        output += BlankRowLine;
      }
    }
    previousScore = pdata.score;

    output += StartRow;
    output += StartRightCol;
    char buf[16];
    std::snprintf(buf, sizeof(buf), "%*u: ", (int)PlayerNumWidth, player + 1);
    output += buf;
    output += EndRightCol;

    PrintPlayer(output, pdata);

    output += StartRightCol;
    if (ThreeWin) {
      char b[16];
      std::snprintf(b, sizeof(b), " %2u%c%c  ", pdata.score / 2,
                    DecimalPointChar, (pdata.score & 1) ? '5' : '0');
      output += b;
    } else {
      char b[32];
      std::snprintf(b, sizeof(b), " %2u%c%c / %2u  ", pdata.score / 2,
                    DecimalPointChar, (pdata.score & 1) ? '5' : '0',
                    pdata.gameCount);
      output += b;
    }
    output += EndRightCol;

    if (PrintTiebreaks) {
      output += StartRightCol;
      char b[16];
      std::snprintf(b, sizeof(b), "%2u%c%c ", pdata.tiebreak / 2,
                    DecimalPointChar, (pdata.tiebreak & 1) ? '5' : '0');
      output += b;
      output += EndRightCol;
    }

    for (uint round = 1; round <= MaxRound; ++round) {
      output += ' ';
      output += StartRightCol;

      if (!pdata.roundClash[round]) {
        output.append(PlayerNumWidth + (SwissColors ? 2 : 1), '.');
      } else {
        const auto &clash = *pdata.roundClash[round];
        if (OutputFormat == CROSSTABLE_Hypertext) {
          char b[32];
          if (CurrentGame == static_cast<int>(clash.gameNum)) {
            std::snprintf(b, sizeof(b), "<green><g_%u>", clash.gameNum);
          } else {
            std::snprintf(b, sizeof(b), "<blue><g_%u>", clash.gameNum);
          }
          output += b;
        }

        if (SwissColors) {
          char b[64];
          std::snprintf(b, sizeof(b), "%*u%c%s", (int)PlayerNumWidth,
                        InvertedIndex[clash.opponent] + 1,
                        (clash.color == WHITE) ? 'w' : 'b',
                        resultStr[clash.result]);
          output += b;
        } else {
          char b[64];
          std::snprintf(b, sizeof(b), "%*u%s", (int)PlayerNumWidth,
                        InvertedIndex[clash.opponent] + 1,
                        resultStr[clash.result]);
          output += b;
        }

        if (OutputFormat == CROSSTABLE_Hypertext) {
          if (CurrentGame == static_cast<int>(clash.gameNum)) {
            output += "</g></green>";
          } else {
            output += "</g></blue>";
          }
        }
      }
      output += EndCol;
    }

    PrintPerformance(output, pdata);

    if (PrintTallies) {
      output += StartCol;
      char b[64];
      std::snprintf(b, sizeof(b), "  (+%u -%u =%u)", pdata.n_won, pdata.n_loss,
                    pdata.n_draw);
      output += b;
      output += EndCol;
    }

    output += EndRow;
    output += NewLine;
  }

  PrintDashesLine(output);

  output += EndTable;
}

void Crosstable::PrintKnockout(std::string &output, uint playerLimit) {

  for (uint round = 1; round <= MaxRound; ++round) {
    if (OutputFormat == CROSSTABLE_Hypertext) {
      output += "<blue><run ::crosstab::setFilter ";
      char b[16];
      std::snprintf(b, sizeof(b), "%u", round);
      output += b;
      output += '>';
      output += b;
      output += "</run></blue>:";
      output += NewLine;
    } else {
      char b[16];
      std::snprintf(b, sizeof(b), "%u:", round);
      output += b;
      output += NewLine;
    }

    output += StartTable;
    PrintDashesLine(output);

    for (auto &pd : PlayerData) {
      pd->printed = false;
    }

    for (uint player = 0; player < playerLimit; ++player) {
      uint index = SortedIndex[player];
      auto &pdata = *PlayerData[index];

      if (!pdata.roundClash[round] || pdata.printed) {
        continue;
      }

      uint opponent = pdata.roundClash[round]->opponent;

      // Skip if black first
      if (!pdata.clashes[opponent].empty() &&
          pdata.clashes[opponent][0].color == BLACK) {
        continue;
      }

      uint score = 0;
      uint nGames = 0;

      for (const auto &clash : pdata.clashes[opponent]) {
        if (clash.round == round) {
          score += RESULT_SCORE[clash.result];
          ++nGames;
        }
      }

      output += StartRow;
      PrintPlayer(output, pdata);

      output += StartCol;
      output += "  ";

      // Print results for this round
      std::size_t clashIdx = 0;
      for (uint count = 0; count < MaxClashes; ++count) {
        // Find next clash in this round
        while (clashIdx < pdata.clashes[opponent].size() &&
               pdata.clashes[opponent][clashIdx].round != round) {
          ++clashIdx;
        }

        if (clashIdx < pdata.clashes[opponent].size()) {
          const auto &clash = pdata.clashes[opponent][clashIdx];
          if (OutputFormat == CROSSTABLE_Hypertext) {
            char b[64];
            if (CurrentGame == static_cast<int>(clash.gameNum)) {
              std::snprintf(b, sizeof(b), "<green><g_%u>%c</g></green>",
                            clash.gameNum, RESULT_CHAR[clash.result]);
            } else {
              std::snprintf(b, sizeof(b), "<blue><g_%u>%c</g></blue>",
                            clash.gameNum, RESULT_CHAR[clash.result]);
            }
            output += b;
          } else {
            output += RESULT_CHAR[clash.result];
          }
          ++clashIdx;
        } else {
          output += ' ';
        }
      }

      output += ' ';
      output += EndCol;

      output += StartRightCol;
      char b[32];
      std::snprintf(b, sizeof(b), "%2u%c%c / %2u   ", score / 2,
                    DecimalPointChar, (score & 1) ? '5' : '0', nGames);
      output += b;
      output += EndRightCol;

      PrintPlayer(output, *PlayerData[opponent]);
      output += EndRow;
      output += NewLine;

      pdata.printed = true;
      PlayerData[opponent]->printed = true;
    }

    PrintDashesLine(output);
    output += EndTable;
    output += NewLine;
  }
}

//////////////////////////////////////////////////////////////////////
//  EOF: crosstab.cpp
//////////////////////////////////////////////////////////////////////