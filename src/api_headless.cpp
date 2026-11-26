#include "api_headless.h"
#include "dbasepool.h"
#include "external/json.hpp"
#include "misc.h"
#include "pgnparse.h"
#include "position.h"
#include "scidbase.h"
#include "searchboard.h"
#include <csignal>
#include <cstdlib>
#include <iostream>
#include <set>
#include <string>
#include <utility>
#include <vector>

using json = nlohmann::json;

// Manual declaration of search_index from searchindex.cpp to avoid Tcl/Tk
// pollution from tkscid.h
errorT search_index(const scidBaseT *base, HFilter &filter, int argc,
                    const char **argv, const Progress &progress);
bool searchindex_isValidCriterion(std::string_view name);

// Headless implementation functions
namespace HeadlessAPI {
inline void SendError(const json &id, int code, const std::string &message) {
  json response;
  response["jsonrpc"] = "2.0";
  response["id"] = id;
  response["error"] = {{"code", code}, {"message", message}};
  std::cout << response.dump() << std::endl;
}

inline void SendResult(const json &id, const json &result) {
  json response;
  response["jsonrpc"] = "2.0";
  response["id"] = id;
  response["result"] = result;
  std::cout << response.dump() << std::endl;
}
} // namespace HeadlessAPI

static void cleanup_handler(int signum) {
  DBasePool::closeAll();
  std::exit(signum == SIGINT ? 130 : 143);
}

void HeadlessMainLoop(int argc, char *argv[]) {
  // Set up signal handlers for clean shutdown
  std::signal(SIGTERM, cleanup_handler);
  std::signal(SIGINT, cleanup_handler);

  std::string line;
  while (std::getline(std::cin, line)) {
    if (line.empty())
      continue;

    json request = json::parse(line, nullptr, false);
    if (request.is_discarded()) {
      HeadlessAPI::SendError(nullptr, -32700, "Parse error");
      continue;
    }

    if (!request.contains("method")) {
      HeadlessAPI::SendError(request.value("id", json(nullptr)), -32600,
                             "Invalid Request");
      continue;
    }

    std::string method = request["method"];
    json id = request.value("id", json(nullptr));
    json params = request.value("params", json::object());

    if (method == "get_version") {
      HeadlessAPI::SendResult(id,
                              {{"version", "scidCommunity Headless API 1.0"}});
    } else if (method == "db_open") {
      std::string path = params.value("path", "");
      std::string type = params.value("type", "SCID5");
      bool readonly = params.value("readonly", false);
      if (path.empty()) {
        HeadlessAPI::SendError(id, -32602, "Missing 'path' parameter");
        continue;
      }

      scidBaseT *dbase = DBasePool::getFreeSlot();
      if (!dbase) {
        HeadlessAPI::SendError(id, -32000, "No free database slots");
        continue;
      }

      fileModeT mode = readonly ? FMODE_ReadOnly : FMODE_Both;
      errorT err = dbase->open(type, mode, path.c_str());
      if (err != OK) {
        HeadlessAPI::SendError(
            id, -32001, "Failed to open database: " + std::to_string(err));
        continue;
      }

      int handle = DBasePool::switchCurrent(dbase);
      HeadlessAPI::SendResult(id, {{"handle", handle}});
    } else if (method == "db_info") {
      int handle = params.value("handle", 0);
      scidBaseT *dbase = DBasePool::getBase(handle);
      if (!dbase) {
        HeadlessAPI::SendError(id, -32602, "Invalid database handle");
        continue;
      }

      json result;
      result["filename"] = dbase->getFileName();
      result["num_games"] = dbase->numGames();
      HeadlessAPI::SendResult(id, result);

    } else if (method == "db_create") {
      std::string path = params["path"];
      std::string type_str = params.value("type", "SCID5");
      auto dbase = DBasePool::getFreeSlot();
      if (!dbase) {
        HeadlessAPI::SendError(id, -32002, "No free database slots");
        return;
      }
      errorT err = dbase->open(type_str, FMODE_Create, path.c_str());
      if (err != OK && err != ERROR_NameDataLoss) {
        HeadlessAPI::SendError(
            id, -32001, "Failed to create database: " + std::to_string(err));
      } else {
        int handle = DBasePool::switchCurrent(dbase);
        HeadlessAPI::SendResult(id, {{"handle", handle}});
      }
    } else if (method == "db_close") {
      int handle = params["handle"];
      auto dbase = DBasePool::getBase(handle);
      if (!dbase) {
        HeadlessAPI::SendError(id, -32003, "Invalid database handle");
        return;
      }
      dbase->Close();
      HeadlessAPI::SendResult(id, {{"success", true}});
    } else if (method == "db_search") {
      if (!params.is_object()) {
        HeadlessAPI::SendError(id, -32602, "'params' must be an object");
        continue;
      }
      int handle = params.value("handle", 0);
      scidBaseT *dbase = DBasePool::getBase(handle);
      if (!dbase) {
        HeadlessAPI::SendError(id, -32602, "Invalid database handle");
        continue;
      }

      // Validate the position options before any search can change
      // "dbfilter": a rejected request must leave the current selection as it
      // was.
      const bool hasPosition = params.contains("fen");
      Position position;
      BoardSearchOptions boardOptions;
      std::string positionOp = "and";
      if (hasPosition) {
        if (!params["fen"].is_string()) {
          HeadlessAPI::SendError(id, -32602, "'fen' must be a string");
          continue;
        }
        const std::string fen = params["fen"].get<std::string>();
        if (fen.empty() || position.ReadFromFEN(fen.c_str()) != OK) {
          HeadlessAPI::SendError(id, -32602, "Invalid FEN");
          continue;
        }

        std::string matchType = "exact";
        if (params.contains("position_match")) {
          if (!params["position_match"].is_string()) {
            HeadlessAPI::SendError(id, -32602,
                                   "'position_match' must be a string");
            continue;
          }
          matchType = params["position_match"].get<std::string>();
        }
        if (matchType == "exact") {
          boardOptions.matchType = GAME_EXACT_MATCH_Exact;
        } else if (matchType == "pawns") {
          boardOptions.matchType = GAME_EXACT_MATCH_Pawns;
        } else if (matchType == "files") {
          boardOptions.matchType = GAME_EXACT_MATCH_Fyles;
          boardOptions.useIndexOptimizations = false;
        } else if (matchType == "material") {
          boardOptions.matchType = GAME_EXACT_MATCH_Material;
          boardOptions.useIndexOptimizations = false;
        } else {
          HeadlessAPI::SendError(id, -32602,
                                 "Invalid position_match: " + matchType);
          continue;
        }

        const char *boolKeys[] = {"position_ignore_colors",
                                  "position_in_variations"};
        bool badBool = false;
        for (auto key : boolKeys) {
          if (params.contains(key) && !params[key].is_boolean()) {
            HeadlessAPI::SendError(id, -32602,
                                   std::string("'") + key +
                                       "' must be a boolean");
            badBool = true;
            break;
          }
        }
        if (badBool)
          continue;
        boardOptions.ignoreColors =
            params.value("position_ignore_colors", false);
        boardOptions.searchInVariations =
            params.value("position_in_variations", false);

        if (params.contains("position_op")) {
          if (!params["position_op"].is_string()) {
            HeadlessAPI::SendError(id, -32602,
                                   "'position_op' must be a string");
            continue;
          }
          positionOp = params["position_op"].get<std::string>();
        }
        if (positionOp != "and" && positionOp != "or") {
          HeadlessAPI::SendError(id, -32602,
                                 "Invalid position_op: " + positionOp);
          continue;
        }
      } else if (params.contains("position_match") ||
                 params.contains("position_ignore_colors") ||
                 params.contains("position_in_variations") ||
                 params.contains("position_op")) {
        HeadlessAPI::SendError(id, -32602,
                               "The position options require 'fen'");
        continue;
      }

      std::string filterOpStr = "reset";
      if (params.contains("filter")) {
        if (!params["filter"].is_string()) {
          HeadlessAPI::SendError(id, -32602, "'filter' must be a string");
          continue;
        }
        filterOpStr = params["filter"].get<std::string>();
      }
      const filterOpT filterOp = strGetFilterOp(filterOpStr.c_str());

      std::vector<std::string> args;
      std::string unknownParam;
      bool hasUnknownParam = false;
      for (auto it = params.begin(); it != params.end(); ++it) {
        const std::string &key = it.key();
        if (key == "handle" || key == "filter" || key == "tags" ||
            key == "has_tags" || key == "fen" ||
            key == "position_match" || key == "position_ignore_colors" ||
            key == "position_in_variations" || key == "position_op")
          continue;
        // Reject unknown criteria instead of silently ignoring them: an
        // ignored criterion would return the whole database.
        if (!searchindex_isValidCriterion(key)) {
          unknownParam = key;
          hasUnknownParam = true;
          break;
        }
        args.push_back("-" + key);
        if (it.value().is_string()) {
          args.push_back(it.value().get<std::string>());
        } else {
          args.push_back(it.value().dump());
        }
      }
      if (hasUnknownParam) {
        HeadlessAPI::SendError(id, -32602,
                               "Unknown parameter: " + unknownParam);
        continue;
      }

      std::vector<const char *> argv_vec;
      for (const auto &s : args)
        argv_vec.push_back(s.c_str());

      // Compute the index and tag criteria in a temporary filter, so a
      // failure cannot leave "dbfilter" modified.
      const std::string indexFilterName = dbase->newFilter();
      struct DeleteFilter {
        scidBaseT *base;
        std::string name;
        DeleteFilter(scidBaseT *db, std::string filterName)
            : base(db), name(std::move(filterName)) {}
        ~DeleteFilter() { base->deleteFilter(name.c_str()); }
      } indexGuard(dbase, indexFilterName);
      HFilter indexMatches = dbase->getFilter(indexFilterName);
      errorT err = search_index(dbase, indexMatches, argv_vec.size(),
                                argv_vec.data(), Progress());
      if (err != OK) {
        HeadlessAPI::SendError(id, -32002,
                               "Search failed: " + std::to_string(err));
        continue;
      }

      // 4b. Optional: Filter by specific tags
      if (params.contains("tags") && params["tags"].is_object()) {
        auto requiredTags =
            params["tags"].get<std::map<std::string, std::string>>();

        std::vector<gamenumT> keptGames;
        for (auto gnum : indexMatches) {
          const IndexEntry *ie = dbase->getIndexEntry(gnum);
          auto gameView = dbase->getGame(*ie);

          bool allTagsMatch = true;
          // We need to verify that *all* required tags exist and match.
          // Strategy: decode all tags of the game into a map, then check.
          // Optimized: just iterate and check off what we find?
          // Simpler for now: map-to-map comparison.
          std::map<std::string, std::string> gameTags;
          gameView.decodeTags([&](std::string_view tag, std::string_view val) {
            gameTags[std::string(tag)] = std::string(val);
          });

          for (const auto &[reqTag, reqVal] : requiredTags) {
            auto it = gameTags.find(reqTag);
            if (it == gameTags.end()) {
              allTagsMatch = false;
              break;
            }

            // Let's implement simple substring
            // search for flexibility, as is common in Scid.
            if (it->second.find(reqVal) == std::string::npos) {
              allTagsMatch = false;
              break;
            }
          }

          if (allTagsMatch) {
            keptGames.push_back(gnum);
          }
        }

        // Update the filter
        indexMatches->clear();
        for (auto gnum : keptGames) {
          indexMatches->set(gnum, 1);
        }
      }

      // 4c. Optional: Filter by tag existence (has_tags)
      if (params.contains("has_tags") && params["has_tags"].is_array()) {
        auto requiredTagNames =
            params["has_tags"].get<std::vector<std::string>>();

        std::vector<gamenumT> keptGames;
        for (auto gnum : indexMatches) {
          const IndexEntry *ie = dbase->getIndexEntry(gnum);
          auto gameView = dbase->getGame(*ie);

          std::set<std::string> gameTags;
          gameView.decodeTags([&](std::string_view tag, std::string_view) {
            gameTags.insert(std::string(tag));
          });

          bool allTagsExist = true;
          for (const auto &reqTag : requiredTagNames) {
            if (gameTags.find(reqTag) == gameTags.end()) {
              allTagsExist = false;
              break;
            }
          }

          if (allTagsExist) {
            keptGames.push_back(gnum);
          }
        }

        indexMatches->clear();
        for (auto gnum : keptGames) {
          indexMatches->set(gnum, 1);
        }
      }

      // 4d. Optional: Filter by position (FEN)
      if (hasPosition) {
        // AND: intersect with the index result, so only those games are
        // searched. OR: search the other games, then add the matches.
        std::vector<gamenumT> candidates;
        const gamenumT numGames = dbase->numGames();
        if (positionOp == "and") {
          candidates.reserve(indexMatches->size());
          for (auto gnum : indexMatches)
            candidates.push_back(gnum);
        } else {
          candidates.reserve(numGames - indexMatches->size());
          for (gamenumT gnum = 0; gnum < numGames; ++gnum) {
            if (indexMatches.get(gnum) == 0)
              candidates.push_back(gnum);
          }
        }

        std::vector<Position> positions{position};
        BoardSearchResult search = boardSearch(*dbase, candidates, positions,
                                               boardOptions, Progress());
        if (search.status == BoardSearchStatus::Cancelled) {
          HeadlessAPI::SendError(id, -32000, "Search cancelled");
          continue;
        }
        if (search.readError) {
          HeadlessAPI::SendError(id, -32002, "Error reading game file.");
          continue;
        }

        for (size_t i = 0; i < candidates.size(); ++i) {
          const uint8_t ply = search.ply[i];
          if (positionOp == "and") {
            indexMatches->set(candidates[i], ply);
          } else if (ply != 0) {
            indexMatches->set(candidates[i], ply);
          }
        }
      }

      // 4e. Apply the filter operation once, against the selection that
      // existed before this request.
      HFilter filter = dbase->getFilter("dbfilter");
      switch (filterOp) {
      case FILTEROP_RESET:
        filter.copyFrom(indexMatches);
        break;
      case FILTEROP_AND:
        filter.andWith(indexMatches);
        break;
      case FILTEROP_OR:
        filter.orWith(indexMatches);
        break;
      }
      json result;
      result["count"] = filter->size();

      json matches = json::array();
      int count = 0;
      for (auto gnum : filter) {
        matches.push_back(gnum + 1); // 1-based index for consistency
        if (++count >= 10000)
          break;
      }
      result["matches"] = matches;
      HeadlessAPI::SendResult(id, result);

    } else if (method == "game_get") {
      int handle = params.value("handle", 0);
      int gnum_1based = params.value("id", 0);
      scidBaseT *dbase = DBasePool::getBase(handle);
      if (!dbase) {
        HeadlessAPI::SendError(id, -32602, "Invalid database handle");
        continue;
      }
      if (gnum_1based < 1 ||
          gnum_1based > static_cast<int>(dbase->numGames())) {
        HeadlessAPI::SendError(id, -32602, "Invalid game ID");
        continue;
      }

      gamenumT gnum = gnum_1based - 1;
      const IndexEntry *ie = dbase->getIndexEntry(gnum);
      TagRoster tags = dbase->tagRoster(gnum);

      char dateStr[16];
      date_DecodeToString(ie->GetDate(), dateStr);

      char ecoStr[16];
      eco_ToExtendedString(ie->GetEcoCode(), ecoStr);

      json result;
      json metadata;
      metadata["white"] = tags.white;
      metadata["black"] = tags.black;
      metadata["event"] = tags.event;
      metadata["site"] = tags.site;
      metadata["round"] = tags.round;
      metadata["date"] = std::string(dateStr);
      metadata["result"] = RESULT_STR[ie->GetResult()];
      metadata["welo"] = ie->GetWhiteElo();
      metadata["belo"] = ie->GetBlackElo();
      metadata["eco"] = std::string(ecoStr);

      result["metadata"] = metadata;

      Game g;
      if (dbase->getGame(*ie, g) == OK) {
        g.ResetPgnStyle();
        g.AddPgnStyle(PGN_STYLE_TAGS);
        g.AddPgnStyle(PGN_STYLE_COMMENTS);
        g.AddPgnStyle(PGN_STYLE_VARS);
        g.AddPgnStyle(PGN_STYLE_SYMBOLS);
        g.SetPgnFormat(PGN_FORMAT_Plain);
        std::pair<const char *, unsigned> pgn = g.WriteToPGN();
        result["pgn"] = std::string(pgn.first, pgn.second);
      }

      HeadlessAPI::SendResult(id, result);
    } else if (method == "game_delete") {
      int handle = params.value("handle", 0);
      scidBaseT *dbase = DBasePool::getBase(handle);
      if (!dbase) {
        HeadlessAPI::SendError(id, -32602, "Invalid database handle");
        continue;
      }
      gamenumT gnum = params.value("id", 0);
      if (gnum < 1 || gnum > dbase->numGames()) {
        HeadlessAPI::SendError(id, -32602, "Invalid game ID");
        continue;
      }
      errorT err =
          dbase->setFlag(true, IndexEntry::CharToFlagMask('D'), gnum - 1);
      if (err != OK) {
        HeadlessAPI::SendError(id, -32001,
                               "Failed to delete game: " + std::to_string(err));
      } else {
        HeadlessAPI::SendResult(id, {{"success", true}});
      }
    } else if (method == "db_compact") {
      int handle = params.value("handle", 0);
      scidBaseT *dbase = DBasePool::getBase(handle);
      if (!dbase) {
        HeadlessAPI::SendError(id, -32602, "Invalid database handle");
        continue;
      }
      errorT err = dbase->compact(Progress());
      if (err != OK) {
        HeadlessAPI::SendError(
            id, -32001, "Failed to compact database: " + std::to_string(err));
      } else {
        HeadlessAPI::SendResult(id, {{"success", true}});
      }
    } else if (method == "game_add") {
      int handle = params.value("handle", 0);
      scidBaseT *dbase = DBasePool::getBase(handle);
      if (!dbase) {
        HeadlessAPI::SendError(id, -32602, "Invalid database handle");
        continue;
      }
      gamenumT target_id = params.value("id", 0);
      gamenumT replaced_gnum = (target_id > 0) ? target_id - 1 : INVALID_GAMEID;

      std::string pgn = params.value("pgn", "");
      Game game;
      if (!pgn.empty()) {
        PgnParseLog log;
        if (!pgnParseGame(pgn.c_str(), pgn.length(), game, log)) {
          HeadlessAPI::SendError(id, -32005, "PGN parse error: " + log.log);
          continue;
        }
      } else if (replaced_gnum != INVALID_GAMEID) {
        if (replaced_gnum >= dbase->numGames()) {
          HeadlessAPI::SendError(id, -32602, "Invalid game ID");
          continue;
        }
        const IndexEntry *ie = dbase->getIndexEntry(replaced_gnum);
        dbase->getGame(*ie, game);
      }

      if (params.contains("tags")) {
        json tags = params["tags"];
        for (auto it = tags.begin(); it != tags.end(); ++it) {
          game.addTag(it.key(), it.value().get<std::string>());
        }
      }

      errorT err = dbase->saveGame(&game, replaced_gnum);
      if (err != OK) {
        HeadlessAPI::SendError(id, -32001,
                               "Failed to add game: " + std::to_string(err));
      } else {
        HeadlessAPI::SendResult(
            id, {{"success", true},
                 {"id", (target_id > 0) ? target_id : dbase->numGames()}});
      }
    } else {
      HeadlessAPI::SendError(id, -32601, "Method not found");
    }
  }
}
