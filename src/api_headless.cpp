#include "api_headless.h"
#include "dbasepool.h"
#include "json.hpp"
#include "misc.h"
#include "scidbase.h"
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

void HeadlessMainLoop(int argc, char *argv[]) {
  std::string line;
  while (std::getline(std::cin, line)) {
    if (line.empty())
      continue;

    json request;
    try {
      request = json::parse(line);
    } catch (const std::exception &e) {
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
      if (path.empty()) {
        HeadlessAPI::SendError(id, -32602, "Missing 'path' parameter");
        continue;
      }

      scidBaseT *dbase = DBasePool::getFreeSlot();
      if (!dbase) {
        HeadlessAPI::SendError(id, -32000, "No free database slots");
        continue;
      }

      errorT err = dbase->open(type, FMODE_ReadOnly, path.c_str());
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
    } else {
      HeadlessAPI::SendError(id, -32601, "Method not found");
    }
  }
}
