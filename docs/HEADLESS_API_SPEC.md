# scidCommunity Headless API Specification v1.0

This document defines the JSON-RPC 2.0 interface for the scidCommunity headless binary. The API allows for programmatic management of chess databases, including search, retrieval, and modification operations.

## Protocol Overview
- **Protocol**: JSON-RPC 2.0
- **Transport**: Standard Input (stdin) / Standard Output (stdout)
- **Invocation**: `./build/scidCommunity --headless`

---

## Method Summary

### System
- [`get_version`](#get_version): Retrieve API version information.

### Database Management
- [`db_open`](#db_open): Open an existing database.
- [`db_create`](#db_create): Create a new database.
- [`db_info`](#db_info): Retrieve database metadata and statistics.
- [`db_close`](#db_close): Close an open database handle.
- [`db_compact`](#db_compact): Physically remove deleted games and clean up index.

### Search & Retrieval
- [`db_search`](#db_search): Search for games based on header criteria.
- [`game_get`](#game_get): Retrieve full PGN and metadata for a specific game.

### Write Operations
- [`game_add`](#game_add): Add a new game to the database, or replace an existing one by ID.
- [`game_delete`](#game_delete): Mark a game for deletion.

---

## Method Details

### `get_version`
Returns the current API version.

**Request:**
```json
{"jsonrpc": "2.0", "method": "get_version", "id": 1}
```

**Response:**
```json
{"jsonrpc": "2.0", "id": 1, "result": {"version": "scidCommunity Headless API 1.0"}}
```

---

### `db_open`
Opens a Scid or PGN database.

**Parameters:**
- `path` (string, required): Full system path to the database (without extension for Scid types).
- `type` (string, optional): One of `"SCID5"`, `"SCID4"`, `"PGN"`. Defaults to `"SCID5"`.

**Response Result:**
- `handle` (int): A session-unique identifier for the database.

---

### `db_create`
Initializes a new database.

**Parameters:**
- `path` (string, required): Full system path for the new database.
- `type` (string, optional): One of `"SCID5"`, `"SCID4"`, `"MEMORY"`, `"PGN"`. Defaults to `"SCID5"`.

**Response Result:**
- `handle` (int): A session-unique identifier for the new database.

---

### `db_info`
Retrieves statistics about an open database.

**Parameters:**
- `handle` (int, required): The database handle.

**Response Result:**
- `filename` (string): Path to the database.
- `num_games` (int): Total number of games (including those marked for deletion).

---

### `db_search`
Searches the database index. Up to 100 results are returned per call.

**Parameters:**
- `handle` (int, required): Database handle.
- `white`, `black`, `event`, `site` (string, optional): Filter by substring.
- `filter` (string, optional): Filter name (e.g., `"all"`).
- `tags` (object, optional): Key-value pairs of tags to filter by. Evaluated after index search.
- `has_tags` (array of string, optional): List of tag names that must exist in the game (regardless of value). Useful for filtering games by the presence of non-standard tags like `"ICCF"` or `"WhiteTeam"`.

**Example with `has_tags`:**
```json
{"jsonrpc": "2.0", "method": "db_search", "id": 1, "params": {"handle": 1, "has_tags": ["ICCF"]}}
```

**Response Result:**
- `count` (int): Total matches found.
- `matches` (array of int): List of 1-based game IDs.

---

### `game_get`
Retrieves full game data.

**Parameters:**
- `handle` (int, required): Database handle.
- `id` (int, required): 1-based game index.

**Response Result:**
- `metadata` (object): Includes names, ELOs, ECO, Date, and Result.
- `pgn` (string): Full PGN move list including comments and variations.

---

### `game_add` (Create or Replace)
Adds a new game to the database, or replaces an existing one if an `id` is provided.

**Parameters:**
- `handle` (int, required): Database handle.
- `id` (int, optional): 1-based game ID to replace. If provided, existing data is preserved unless overwritten by `tags` or `pgn`.
- `pgn` (string, optional): PGN move text to parse.
- `tags` (object, optional): Key-value pairs for PGN tags.

**Response Result:**
- `success` (bool): `true` on success.
- `id` (int): The 1-based ID assigned to the new game.

---

### `game_delete`
Marks a game for deletion in the index.

**Parameters:**
- `handle` (int, required): Database handle.
- `id` (int, required): 1-based game index.

---

### `db_compact`
Physically removes games marked for deletion and cleans up unused name IDs.

**Parameters:**
- `handle` (int, required): Database handle.

---

## Error Codes

The API uses standard JSON-RPC 2.0 error codes and custom application codes:

| Code | Message | Description |
| :--- | :--- | :--- |
| `-32700` | Parse error | Invalid JSON sent by the client. |
| `-32601` | Method not found | The requested method does not exist. |
| `-32602` | Invalid params | Missing or malformed parameters. |
| `-32001` | Operation failed | Generic backend error (includes Scid error code). |
| `-32003` | Invalid handle | The database handle is not open. |
| `-32004` | Invalid game ID | The requested game index is out of bounds. |
