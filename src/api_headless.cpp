#include "api_headless.h"
#include "dbasepool.h"
#include "external/json.hpp"
#include "misc.h"
#include "pgnparse.h"
#include "scidbase.h"
#include <csignal>
#include <cstdlib>
#include <iostream>
#include <string>
#include <vector>

using json = nlohmann::json;

// Manual declaration of search_index from searchindex.cpp to avoid Tcl/Tk
// pollution from tkscid.h
errorT search_index(const scidBaseT *base, HFilter &filter, int argc,
                    const char **argv, const Progress &progress);

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
      int handle = params.value("handle", 0);
      scidBaseT *dbase = DBasePool::getBase(handle);
      if (!dbase) {
        HeadlessAPI::SendError(id, -32602, "Invalid database handle");
        continue;
      }

      std::vector<std::string> args;
      // Use a temporary vector of strings to hold the arguments
      for (auto it = params.begin(); it != params.end(); ++it) {
        if (it.key() == "handle")
          continue;
        if (it.key() == "filter") {
          args.push_back("-filter");
          args.push_back(it.value().get<std::string>());
          continue;
        }
        args.push_back("-" + it.key());
        if (it.value().is_string()) {
          args.push_back(it.value().get<std::string>());
        } else {
          args.push_back(it.value().dump());
        }
      }

      std::vector<const char *> argv_vec;
      for (const auto &s : args)
        argv_vec.push_back(s.c_str());

      HFilter filter = dbase->getFilter("dbfilter");
      errorT err = search_index(dbase, filter, argv_vec.size(), argv_vec.data(),
                                Progress());
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
        for (auto gnum : filter) {
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
        filter->clear();
        for (auto gnum : keptGames) {
          filter->set(gnum, 1);
        }
      }

      json result;
      result["count"] = filter->size();

      json matches = json::array();
      int count = 0;
      for (auto gnum : filter) {
        matches.push_back(gnum + 1); // 1-based index for consistency
        if (++count >= 100)
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
