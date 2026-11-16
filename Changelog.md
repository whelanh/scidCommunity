# Changelog

scidCommunity is a free chess database and analysis program. This page records every published release, newest first, in plain language for players rather than programmers.

A scidCommunity version has three numbers and a build number, for example **5.1.4.68**. Every build is published with its own Windows, macOS and Linux downloads, so this list is long: most releases are small, and a release that changed nothing you can see still gets an entry so that the record is complete.

- **Who made it.** The names at the end of a line are the people whose pull requests delivered that change; the linked numbers are the pull requests themselves.
- **Where to read more.** A new feature links to its help page or document where one already exists.
- **Where work came from.** When code, pieces or themes were ported or adapted from another free-software project, that project is named and linked.
- **What is covered.** This page starts with the first scidCommunity release. The program's ancestry — Scid itself, up to version 5.1.0 — is not repeated here.

The latest downloads are on the [Releases page](https://github.com/whelanh/scidCommunity/releases).

---

## 5.1.4.68 — 16 November 2026

- Search > Moves finds games by a sequence of moves: type the moves in order, paste a line of notation, put ? where you do not care which move was played, and filter on the side to move or on a last move that mates. — thanks to @Triquetra ([#497](https://github.com/whelanh/scidCommunity/pull/497)).
- The review report gives a performance rating fitted on what the moves cost, instead of a rating estimated from accuracy and average centipawn loss. — thanks to @Triquetra ([#496](https://github.com/whelanh/scidCommunity/pull/496)).
- The unused batch Game Comment dialog has been removed; Game Review covers one game and the **Game List**'s batch annotation covers a selection. — thanks to @Triquetra ([#495](https://github.com/whelanh/scidCommunity/pull/495)).

## 5.1.4.67 — 15 November 2026

- The **Header Search**'s saved searches are called Presets everywhere, and the Save button that never worked has gone from the other search windows ([documentation](docs/header_search_layouts.md)). — thanks to @Triquetra ([#492](https://github.com/whelanh/scidCommunity/pull/492)).
- The Name Editor's Replace field accepts `*` as a wildcard, so one operation renames every matching name. — thanks to @whelanh ([#485](https://github.com/whelanh/scidCommunity/pull/485)).
- The **Tree Window**'s move statistics run in parallel, show a progress bar and can be cancelled, and a new Tree option reopens the last mask you used. — thanks to @whelanh ([#483](https://github.com/whelanh/scidCommunity/pull/483), [#484](https://github.com/whelanh/scidCommunity/pull/484), [#487](https://github.com/whelanh/scidCommunity/pull/487)).
- Analyze Positions reports on the **Engine Window**'s own search, so the report says what you watched on screen rather than what a second hidden engine found. — thanks to @whelanh ([#493](https://github.com/whelanh/scidCommunity/pull/493)).
- The Twin Checker's equal-length choice is back to its earlier behaviour, so the dialog reports the deletions it makes again. — thanks to @whelanh ([#481](https://github.com/whelanh/scidCommunity/pull/481)).

## 5.1.4.66 — 14 November 2026

- Re-importing a Chess.com or Lichess game whose moves or result have changed updates the copy already in the database instead of adding a second one. — thanks to @whelanh ([#478](https://github.com/whelanh/scidCommunity/pull/478)).
- The Twin Checker keeps the fuller game of a duplicated pair, and the newer one when both are the same length. — thanks to @whelanh ([#478](https://github.com/whelanh/scidCommunity/pull/478)).
- The **Engine Window** shows the live analysis at the top with earlier iterations below it, newest first, and a preference can hide that history. — thanks to @whelanh ([#477](https://github.com/whelanh/scidCommunity/pull/477)).
- A Play versus Engine game started after an engine crash now gets its engine on the first Play, and a second game in the same session opens its own window. — thanks to @Triquetra ([#476](https://github.com/whelanh/scidCommunity/pull/476)).
- Update checks work when the bundled download tool sits in a path containing spaces, so downloading an update no longer stalls. — thanks to @Hekkta ([#474](https://github.com/whelanh/scidCommunity/pull/474)).

## 5.1.4.65 — 13 November 2026

- ChessBase CTG opening books can be converted to OpenBook Rich from the Tools menu, with progress and a Cancel, and the converted book appears in the book selectors. — thanks to @whelanh ([#473](https://github.com/whelanh/scidCommunity/pull/473)).
- The engine options dialog is sized correctly on Hyprland, the engine list dialog has simpler buttons, and selecting text no longer tints the book panel.

## 5.1.4.64 — 12 November 2026

- The **Book Window** opens OpenBook Rich books, showing how often each move was played, its score, a win/draw/loss bar and ChessBase's move colors, with the columns sortable. — thanks to @whelanh ([#467](https://github.com/whelanh/scidCommunity/pull/467)).
- **Export as PGN** offers a line-ending choice, and a new **Preferences** page sets the order of the exported tags. — thanks to @whelanh ([#471](https://github.com/whelanh/scidCommunity/pull/471)).
- Review game and Calvar have left the Play > Training menu. — thanks to @Triquetra ([#466](https://github.com/whelanh/scidCommunity/pull/466)).
- The **Engine Window** keeps these multi-move blocks in order and at full length, and an EPD report keeps the deepest result even when a shallower line arrives later. — thanks to @whelanh ([#468](https://github.com/whelanh/scidCommunity/pull/468), [#469](https://github.com/whelanh/scidCommunity/pull/469)).

## 5.1.4.63 — 12 November 2026

- **Game Review** inside a variation now reviews the line the cursor is on — the main-line prefix and then that variation — instead of quietly reviewing the main line. — thanks to @Triquetra ([#459](https://github.com/whelanh/scidCommunity/pull/459)).
- Analyze Positions opens an **Engine Window** again so the search can be watched, and the report compares and writes plain moves, so a move the engine found is no longer reported as not found. — thanks to @whelanh ([#462](https://github.com/whelanh/scidCommunity/pull/462), [#464](https://github.com/whelanh/scidCommunity/pull/464)).
- When the engine shows several candidate moves, the output is again displayed as one block per depth, with the best line of each block picked out in color. — thanks to @whelanh ([#463](https://github.com/whelanh/scidCommunity/pull/463)).

## 5.1.4.62 — 11 November 2026

- Games can be published to a Lichess study — from the **Game List** or the current game — one chapter per game, with a choice of study and chapter options and a report of what was published. — thanks to @whelanh ([#456](https://github.com/whelanh/scidCommunity/pull/456)).
- **What's the Threat?** in the **Engine Window** works out what the opponent is threatening and writes the answer into the move comment, one sentence behind the reader's own ([documentation](docs/review-ui.md)). — thanks to @Triquetra ([#447](https://github.com/whelanh/scidCommunity/pull/447)).
- Brilliant and Great labels are confirmed by a second engine before they are written, so a sacrifice is not called brilliant on the strength of one search. — thanks to @Triquetra ([#448](https://github.com/whelanh/scidCommunity/pull/448)).
- Opening errors and tactical exercises are now options in Review Settings, with the length of the opening window, and all three settings are saved. — thanks to @whelanh ([#451](https://github.com/whelanh/scidCommunity/pull/451)).
- The **Analysis Window** has been retired: its menu entries are gone, and the engine chooser opens an **Engine Window** instead. — thanks to @whelanh ([#452](https://github.com/whelanh/scidCommunity/pull/452), [#453](https://github.com/whelanh/scidCommunity/pull/453)).

## 5.1.4.61 — 9 November 2026

- A further fix makes the Windows updater work for the users who still could not update.

## 5.1.4.60 — 9 November 2026

- Comments keep their color formatting when you edit the notation directly and save the game.

## 5.1.4.59 — 8 November 2026

- The Windows updater works again.

## 5.1.4.58 — 8 November 2026

- **Preferences** has a sound theme selector, with the Lichess sounds, a wooden set and a steel-drum set, and the choice is kept between sessions. — thanks to @whelanh ([#443](https://github.com/whelanh/scidCommunity/pull/443)).
- Choosing a theme can turn on move sounds only, and each sound now plays for its full length instead of being cut off by the next one. — thanks to @whelanh ([#443](https://github.com/whelanh/scidCommunity/pull/443)).

## 5.1.4.57 — 7 November 2026

- Repetition alerts are a banner that fades after a few seconds instead of a dialog that stops you, and **Preferences** offers Off, Banner or Pop-up dialog. — thanks to @whelanh ([#440](https://github.com/whelanh/scidCommunity/pull/440)).
- With Color Display switched off, the **PGN Window** still highlights and navigates moves, and comment line breaks are kept in the colored output. — thanks to @whelanh ([#439](https://github.com/whelanh/scidCommunity/pull/439)).
- Windows update downloads show their progress and file size, and no longer hang. — thanks to @whelanh ([#439](https://github.com/whelanh/scidCommunity/pull/439)).

## 5.1.4.56 — 6 November 2026

- The **Engine Window** has a **Play from here** button that plays the current position out against the engine already open in that window, with its own time and depth limits. — thanks to @whelanh ([#435](https://github.com/whelanh/scidCommunity/pull/435)).
- Tree training picks its replies from the move statistics alone, so it no longer needs an Analysis window open beside the tree. — thanks to @whelanh ([#435](https://github.com/whelanh/scidCommunity/pull/435)).
- Engine variations now name the engine that produced them, and a whole-game review records the engine in the Annotator tag. — thanks to @whelanh ([#434](https://github.com/whelanh/scidCommunity/pull/434)).

## 5.1.4.55 — 5 November 2026

- Comments are colored by what wrote them: green for the review's verdicts, blue for the coach's text, and your own comment color for anything you type. — thanks to @whelanh ([#432](https://github.com/whelanh/scidCommunity/pull/432)).
- The program checks once a day for a newer version, Help > Check for Updates asks on demand, and on Windows the update can be downloaded and installed from the dialog. — thanks to @whelanh ([#431](https://github.com/whelanh/scidCommunity/pull/431)).
- Games imported from Chess.com and Lichess can have their comments and variations stripped as they arrive; the option is off by default. — thanks to @whelanh ([#430](https://github.com/whelanh/scidCommunity/pull/430)).
- A review's progress appears in a docked pane with a read-only board, so you can follow a long review without it moving the board you are working on. — thanks to @hermes-david ([#424](https://github.com/whelanh/scidCommunity/pull/424)).
- The move comments written for a review name moves as a scoresheet does and give the fifty-move clock in moves. — thanks to @Triquetra ([#425](https://github.com/whelanh/scidCommunity/pull/425)).

## 5.1.4.54 — 4 November 2026

- Stray background errors no longer appear when a one-off engine request, such as a game summary or a threat check, closes its engine as the answer arrives. — thanks to @Triquetra ([#423](https://github.com/whelanh/scidCommunity/pull/423)).
- Game summaries and the coach's comments are translated into the supported languages. — thanks to @whelanh ([#421](https://github.com/whelanh/scidCommunity/pull/421)).

## 5.1.4.53 — 3 November 2026

- Game Review can add a written summary and a sentence of coaching beside the moves worth explaining, using the model chosen for Game Comment; the labels and evaluations are written first and never wait for the model ([documentation](docs/review-ui.md)). — thanks to @Triquetra ([#414](https://github.com/whelanh/scidCommunity/pull/414), [#417](https://github.com/whelanh/scidCommunity/pull/417)).
- The **Engine Window**'s review buttons are now icons in the toolbar's own style, with variants for the dark theme. — thanks to @whelanh ([#416](https://github.com/whelanh/scidCommunity/pull/416)).
- The endgame now begins at 26 points of material on the whole board, pawns included, so pawn-heavy positions are no longer called endings. — thanks to @Triquetra ([#413](https://github.com/whelanh/scidCommunity/pull/413)).
- Ctrl+1 to Ctrl+9 work on French keyboards. — thanks to @whelanh ([#419](https://github.com/whelanh/scidCommunity/pull/419)).

## 5.1.4.52 — 1 November 2026

- **Move Comment** explains the move you have selected — the one shown on the board — instead of the move after it, and it works on the last move of a game too. — thanks to @whelanh ([#411](https://github.com/whelanh/scidCommunity/pull/411)).
- The snap package accepts accented and other diacritical characters typed from a local keyboard.

## 5.1.4.51 — 31 October 2026

- A fresh installation no longer fails to start: the default window layout now loads correctly. — thanks to @whelanh ([#408](https://github.com/whelanh/scidCommunity/pull/408)).
- The Annotate dialog runs the same review pass as Game Review, on the engine of the pane it was opened from, and can annotate one game or a range as a batch ([documentation](docs/annotate-review-mode.md)). — thanks to @Triquetra ([#406](https://github.com/whelanh/scidCommunity/pull/406)).
- A game review ends with a report giving accuracy, average centipawn loss, a rating estimate, a tally of labels, the key moments and the split into opening, middlegame and endgame ([documentation](docs/review-ui.md)). — thanks to @Triquetra ([#405](https://github.com/whelanh/scidCommunity/pull/405)).

## 5.1.4.50 — 31 October 2026

- The **Engine Window** now carries **Game Review** and **Move Comment** buttons over one engine pass: Game Review searches the whole main line, showing its progress with a Cancel beside it, and Move Comment explains the single move played from the current position ([documentation](docs/review-ui.md)). — thanks to @Triquetra ([#383](https://github.com/whelanh/scidCommunity/pull/383), [#384](https://github.com/whelanh/scidCommunity/pull/384), [#388](https://github.com/whelanh/scidCommunity/pull/388), [#393](https://github.com/whelanh/scidCommunity/pull/393)) and @whelanh ([#385](https://github.com/whelanh/scidCommunity/pull/385), [#386](https://github.com/whelanh/scidCommunity/pull/386)).
- A review writes its verdict into the game with the mark the label implies (??, ?, ?!, !, !!) and an assessment symbol for the position, puts a diagram at mistakes and blunders, and adds the engine's better move as a variation where one existed. — thanks to @whelanh ([#396](https://github.com/whelanh/scidCommunity/pull/396), [#398](https://github.com/whelanh/scidCommunity/pull/398), [#399](https://github.com/whelanh/scidCommunity/pull/399), [#400](https://github.com/whelanh/scidCommunity/pull/400)).
- Opening moves are labelled Book rather than judged, and a finished review refreshes the game text so the new comments appear at once. — thanks to @whelanh ([#394](https://github.com/whelanh/scidCommunity/pull/394), [#395](https://github.com/whelanh/scidCommunity/pull/395)).
- Review Settings sets how many lines, how deep and how many variations a review writes, and engine presets can be duplicated and carry their own depth and time limits ([documentation](docs/engine-presets.md)). — thanks to @Triquetra ([#382](https://github.com/whelanh/scidCommunity/pull/382), [#387](https://github.com/whelanh/scidCommunity/pull/387)) and @hermes-david ([#390](https://github.com/whelanh/scidCommunity/pull/390)).
- Finish Game is available in the **Engine Window**, with no annotation options, and every review pass respects a time cap on top of the preset's own limits. — thanks to @whelanh ([#401](https://github.com/whelanh/scidCommunity/pull/401)) and @Triquetra ([#403](https://github.com/whelanh/scidCommunity/pull/403)).

## 5.1.4.49 — 27 October 2026

- Game Comment can use a model on your own machine: its settings offer a local server and any OpenAI-compatible endpoint beside Gemini and DeepSeek, and nothing leaves the machine until a model is chosen. — thanks to @Triquetra ([#369](https://github.com/whelanh/scidCommunity/pull/369)).
- Engine evaluations are turned into plain labels — best, excellent, good, inaccuracy, mistake, blunder — shown in the interface language. — thanks to @Triquetra ([#375](https://github.com/whelanh/scidCommunity/pull/375)).
- A database left locked when the program crashed opens normally again, instead of asking you to delete a leftover file by hand. — thanks to @Triquetra ([#372](https://github.com/whelanh/scidCommunity/pull/372)).
- Right-clicking a move in the notation pane offers Copy Position and Copy FEN, putting the current diagram or its standard notation on the clipboard. — thanks to @Triquetra ([#368](https://github.com/whelanh/scidCommunity/pull/368)).
- The Lichess Fresca piece set can now be chosen for the board.
- The **Game List** scrolls three rows per wheel notch, at a speed you can set from 1 to 10 in the preferences. — thanks to @Triquetra ([#367](https://github.com/whelanh/scidCommunity/pull/367)).

## 5.1.4.48 — 25 October 2026

- Translation updates only.

## 5.1.4.47 — 24 October 2026

- Custom board colors can be saved as named schemes and applied again later, and the built-in schemes now apply to the board straight away. — thanks to @whelanh ([#365](https://github.com/whelanh/scidCommunity/pull/365)).
- Tree training tells the end of a line apart from a move the database does not contain, and can show the recorded result of the game. — thanks to @whelanh ([#366](https://github.com/whelanh/scidCommunity/pull/366)).

## 5.1.4.46 — 23 October 2026

- The press-and-hold lift from the previous release has been removed; the Ctrl+Alt+0 null-move shortcut is unaffected.
- Re-importing a game that is already in the database but marked deleted restores that copy instead of adding a duplicate. — thanks to @whelanh ([#362](https://github.com/whelanh/scidCommunity/pull/362)).
- The Search Comments result list has a Copy button that copies the game number, players and move as tab-separated text for a spreadsheet. — thanks to @whelanh ([#359](https://github.com/whelanh/scidCommunity/pull/359)).

## 5.1.4.45 — 22 October 2026

- Search > Search Comments finds a word in the comments of the games in the current filter, including comments inside variations, and lists each hit with its game number, players, move and a snippet; double-clicking a hit loads the game and jumps to the position. — thanks to @whelanh ([#356](https://github.com/whelanh/scidCommunity/pull/356)).
- Comment searches run faster because games with no comments are skipped. — thanks to @whelanh ([#357](https://github.com/whelanh/scidCommunity/pull/357)).

## 5.1.4.44 — 21 October 2026

- Press-and-hold on a piece lifts it, and the lifted piece is mirrored on the **Presentation Board** so an audience can follow a piece being moved. — thanks to @whelanh ([#353](https://github.com/whelanh/scidCommunity/pull/353)).
- Ctrl+Alt+0, or Edit > Null Move, inserts a null move as it does in ChessBase. — thanks to @whelanh ([#352](https://github.com/whelanh/scidCommunity/pull/352)).
- Tree training now answers with a move in every problem, instead of only in problems where the side to move matched the one it started with. — thanks to @whelanh ([#351](https://github.com/whelanh/scidCommunity/pull/351)).

## 5.1.4.43 — 21 October 2026

- A new **Presentation Board** window shows only the board, for a projector or a second screen, and follows the main board, including its orientation and last-move highlight. — thanks to @whelanh ([#349](https://github.com/whelanh/scidCommunity/pull/349)).
- Ctrl+Shift+W opens and closes the **Presentation Board**, and Ctrl+Shift+F freezes it on the position you want the audience to keep looking at ([documentation](docs/presentation-board.md)). — thanks to @whelanh ([#349](https://github.com/whelanh/scidCommunity/pull/349)).

## 5.1.4.42 — 21 October 2026

- **Rapid Annotate** in the Tools menu, also on Ctrl+Shift+A, writes the evaluations and annotations collected from the engine's score graph into the current game. — thanks to @whelanh ([#346](https://github.com/whelanh/scidCommunity/pull/346)).
- An **Engine Window** whose remembered engine is no longer configured now opens with a configured engine instead of an empty window. — thanks to @whelanh ([#345](https://github.com/whelanh/scidCommunity/pull/345)).

## 5.1.4.41 — 20 October 2026

- Uploading a game to Lichess works for longer games again, and the variations are kept whenever the game fits Lichess's limit. — thanks to @whelanh ([#343](https://github.com/whelanh/scidCommunity/pull/343)).
- Comments and annotations are dropped from the copy sent to Lichess, which was making some uploads fail; the game in your database keeps them. — thanks to @whelanh ([#343](https://github.com/whelanh/scidCommunity/pull/343)).

## 5.1.4.40 — 18 October 2026

- Shift+clicking an empty square hides the arrows and square marks on the board without changing the game's comments; shift+clicking again brings them back. — thanks to @whelanh ([#341](https://github.com/whelanh/scidCommunity/pull/341)).
- The Lichess Opening Explorer results window can be made much narrower, remembers its size between lookups, scrolls its tables sideways and can be minimised. — thanks to @whelanh ([#340](https://github.com/whelanh/scidCommunity/pull/340)).

## 5.1.4.39 — 17 October 2026

- Arrow keys now navigate the game while the **Analysis Window** has focus. — thanks to @whelanh ([#338](https://github.com/whelanh/scidCommunity/pull/338)).
- Table Base lookups work on Windows when the program is installed in a folder whose path contains spaces. — thanks to @whelanh ([#337](https://github.com/whelanh/scidCommunity/pull/337)).

## 5.1.4.38 — 17 October 2026

- Picking a screen color no longer hides scidCommunity, so the eyedropper can sample colors from your own board. — thanks to @whelanh ([#336](https://github.com/whelanh/scidCommunity/pull/336)).
- Ctrl+Q quits the program again, after a review of every keyboard shortcut. — thanks to @whelanh ([#335](https://github.com/whelanh/scidCommunity/pull/335)).

## 5.1.4.37 — 16 October 2026

- The marker palette color and type are remembered across restarts instead of resetting to green squares. — thanks to @whelanh ([#334](https://github.com/whelanh/scidCommunity/pull/334)).
- The arrow keys and the spacebar now work while the focus is in a read-only pane such as the engine output or the **PGN Window**, so the game moves without clicking the moves list first. — thanks to @whelanh ([#334](https://github.com/whelanh/scidCommunity/pull/334)).
- Ctrl+X no longer reports an error when the focus is not in an editable field. — thanks to @whelanh ([#334](https://github.com/whelanh/scidCommunity/pull/334)).

## 5.1.4.36 — 13 October 2026

- Users can add features of their own with plugin files kept in a plugins folder beside their settings; a plugin that fails to load is skipped and a warning is shown once the app has started. — thanks to @kayvee42 ([#333](https://github.com/whelanh/scidCommunity/pull/333)).
- On macOS, tooltips stay on screen instead of taking the keyboard focus and vanishing. — thanks to @kayvee42 ([#332](https://github.com/whelanh/scidCommunity/pull/332)).
- The Lucas Chess button is disabled on macOS, where those engines have no macOS builds, and its tooltip says why. — thanks to @kayvee42 ([#329](https://github.com/whelanh/scidCommunity/pull/329)) and @whelanh ([#330](https://github.com/whelanh/scidCommunity/pull/330)).

## 5.1.4.35 — 13 October 2026

- The Header Search window has a vertical scroll bar, so every field stays reachable on a short screen.
- The buttons under the notation pane are now small icons instead of wide text labels, so none of them is cut off when the pane is narrow. — thanks to @kayvee42 ([#327](https://github.com/whelanh/scidCommunity/pull/327)).
- Tooltips grow to fit their text, so a longer message is no longer clipped.
- On macOS, **Preferences** opens completely instead of stopping after the Internationalization page. — thanks to @kayvee42 ([#325](https://github.com/whelanh/scidCommunity/pull/325)).

## 5.1.4.34 — 12 October 2026

- Right-click menus work again on macOS builds that use the newer toolkit. — thanks to @kayvee42 ([#323](https://github.com/whelanh/scidCommunity/pull/323)).
- A Table Base lookup that gets an unexpected answer now shows what came back, instead of the misleading "Unable to evaluate this position". — thanks to @whelanh ([#324](https://github.com/whelanh/scidCommunity/pull/324)).
- The game clock in Play versus Engine was fixed.

## 5.1.4.33 — 11 October 2026

- On macOS, settings, engines and data now live in a scidCommunity folder of their own instead of the folder shared with Scid, and existing files are copied across on first launch. — thanks to @kayvee42 ([#321](https://github.com/whelanh/scidCommunity/pull/321)).
- Languages whose help pages had names differing only in capitalisation no longer lose one set on macOS and Windows, so the right language's help opens. — thanks to @kayvee42 ([#322](https://github.com/whelanh/scidCommunity/pull/322)).
- An engine is no longer lost from the engine list while the settings are moved to the new macOS folder.

## 5.1.4.32 — 11 October 2026

- Table Base lookups no longer fail with an unsupported-address error when the download tool is missing, and each fallback reports what actually went wrong. — thanks to @whelanh ([#317](https://github.com/whelanh/scidCommunity/pull/317)).

## 5.1.4.31 — 10 October 2026

- A new Moves preference sets how many moves of each engine line are shown; the limit applies to live engine output, stored evaluations and the **Analysis Window**. — thanks to @whelanh ([#315](https://github.com/whelanh/scidCommunity/pull/315)).
- Pressing the spacebar plays the engine's best move on the main board and in the **Engine Window** and **Analysis Window**, using the first line when several are shown. — thanks to @whelanh ([#314](https://github.com/whelanh/scidCommunity/pull/314)).

## 5.1.4.30 — 9 October 2026

- Right-clicking the board marks a square or draws an arrow, and modifier keys choose among red, yellow, blue, cyan and orange, while a plain right-click uses the color in the marker palette ([documentation](docs/board-color-shortcuts.md)). — thanks to @whelanh ([#311](https://github.com/whelanh/scidCommunity/pull/311)).
- Holding the right button and dragging draws the arrow to the square you release over, so a line can be aimed before it is drawn. — thanks to @whelanh ([#311](https://github.com/whelanh/scidCommunity/pull/311)).

## 5.1.4.29 — 8 October 2026

- Annotated squares can now be drawn as colored square outlines, including the square markers in games imported from ChessBase, and they also appear on the 3D board. — thanks to @whelanh ([#309](https://github.com/whelanh/scidCommunity/pull/309)).
- Square markers are now the default marker style, and the Lichess-style marker choices offer squares in place of circles. — thanks to @whelanh ([#309](https://github.com/whelanh/scidCommunity/pull/309)).

## 5.1.4.28 — 2 October 2026

- Downloading games from Lichess works again.

## 5.1.4.27 — 1 October 2026

- The color picker for the board colors works on KDE and other Linux desktops again.

## 5.1.4.26 — 27 September 2026

- The color picker now works on Windows.

## 5.1.4.25 — 27 September 2026

- The light and dark square colors can be picked straight off the screen with an eyedropper, and a message appears if the pick fails. — thanks to @whelanh ([#299](https://github.com/whelanh/scidCommunity/pull/299)).

## 5.1.4.24 — 25 September 2026

- Engine variation arrows can now be shown separately from the last-move arrow, and further suggested moves use progressively lighter gray arrows, with the first two standing out. — thanks to @whelanh ([#297](https://github.com/whelanh/scidCommunity/pull/297)).
- The move-highlighting settings in **Preferences** are grouped more clearly. — thanks to @whelanh ([#297](https://github.com/whelanh/scidCommunity/pull/297)).

## 5.1.4.23 — 24 September 2026

- RTF exports can include a board diagram for positions marked with a diagram annotation, and imported RTF files skip embedded pictures instead of reading them as moves. — thanks to @whelanh ([#295](https://github.com/whelanh/scidCommunity/pull/295)).
- Opening a Lichess tournament works again.

## 5.1.4.22 — 24 September 2026

- Chess.com downloads identify themselves like a browser request and reject error pages, so a failed download no longer adds junk to your games. — thanks to @whelanh ([#294](https://github.com/whelanh/scidCommunity/pull/294)).
- Dock tabs appear correctly in windows that use a grid layout, and are not added when the window they belong to is unavailable. — thanks to @whelanh ([#294](https://github.com/whelanh/scidCommunity/pull/294)).

## 5.1.4.21 — 23 September 2026

- HTML exports now embed the board and piece images they use, so an exported file can be opened on its own. — thanks to @whelanh ([#293](https://github.com/whelanh/scidCommunity/pull/293)).
- Batch commentary lets you choose a model for the provider you picked, reports how many commentaries were written, and ends its summary with accuracy percentages. — thanks to @whelanh ([#293](https://github.com/whelanh/scidCommunity/pull/293)).
- Commentary now names the player who made the annotated move, and a failed run stops and says what went wrong. — thanks to @whelanh ([#293](https://github.com/whelanh/scidCommunity/pull/293)).

## 5.1.4.20 — 23 September 2026

- Comments in the **Comment Editor** can be formatted with bold, italic, underline, fonts, sizes and colors, and the formatting is kept when the game is shown again. — thanks to @whelanh ([#290](https://github.com/whelanh/scidCommunity/pull/290)).
- Exported HTML keeps that comment formatting ([help page](help/Export.html)). — thanks to @whelanh ([#290](https://github.com/whelanh/scidCommunity/pull/290)).
- A Try Variation editing mode lets you try out a variation on the board. — thanks to @whelanh ([#290](https://github.com/whelanh/scidCommunity/pull/290)).
- Games can be exported to RTF, one game or all filtered games, and imported back from an RTF file, with comment formatting preserved. — thanks to @whelanh ([#291](https://github.com/whelanh/scidCommunity/pull/291)).

## 5.1.4.19 — 22 September 2026

- Training in the **Tree Window** now keeps your own moves apart from the ones played for you, so you can go back to an earlier position and carry on. — thanks to @whelanh ([#289](https://github.com/whelanh/scidCommunity/pull/289)).

## 5.1.4.18 — 22 September 2026

- Training works again in the **Tree Window**, picking the opponent's moves from database statistics and applying them in correct notation, so you can practice your openings against a large database ([help page](help/Tree.html#Training)). — thanks to @whelanh ([#288](https://github.com/whelanh/scidCommunity/pull/288)).

## 5.1.4.17 — 19 September 2026

- Under **Options**, the player-name setup adopted from [Scid vs. PC](https://scidvspc.sourceforge.net/) lets you list your names, with wildcards, so the board turns to your side whenever a game with one of those names is loaded or imported ([help page](help/Options.html#MyPlayerNames)). — thanks to @whelanh ([#284](https://github.com/whelanh/scidCommunity/pull/284)).

## 5.1.4.16 — 10 September 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.4.15 — 10 September 2026

- A "Comments, not annotations" choice removes the written comments from a game while keeping its annotation symbols. — thanks to @whelanh ([#275](https://github.com/whelanh/scidCommunity/pull/275)).

## 5.1.4.14 — 9 September 2026

- Importing PGN files, Lichess games or Chess.com games now skips games already in the database, including duplicates inside the same file, and reports how many were imported and how many skipped. — thanks to @whelanh ([#274](https://github.com/whelanh/scidCommunity/pull/274)).
- Lichess and Chess.com imports can be sent to the database you choose, including the clipbase. — thanks to @whelanh ([#274](https://github.com/whelanh/scidCommunity/pull/274)).
- The **Auto Comment** button is gone from the **Engine Window**, and **Game Comment** verdicts now handle signed scores, checkmates and mate scores from the side to move. — thanks to @whelanh ([#271](https://github.com/whelanh/scidCommunity/pull/271)).

## 5.1.4.13 — 9 September 2026

- The AI settings for game commentary now offer the models each provider actually publishes, instead of asking you to type a name. — thanks to @whelanh ([#270](https://github.com/whelanh/scidCommunity/pull/270)).
- Commentary judges positions from the side to move, with stricter verdicts. — thanks to @whelanh ([#270](https://github.com/whelanh/scidCommunity/pull/270)).

## 5.1.4.12 — 8 September 2026

- The **Game List** right-click menu can strip comments, variations or both from all selected games at once, after asking for confirmation ([help page](help/Menus.html#Edit)). — thanks to @whelanh ([#268](https://github.com/whelanh/scidCommunity/pull/268)).
- The **Edit** menu can likewise remove all comments, annotations and variations from the current game in one step. — thanks to @whelanh ([#268](https://github.com/whelanh/scidCommunity/pull/268)).

## 5.1.4.11 — 7 September 2026

- Batch annotating a set of games with an engine now works on Windows. — thanks to @whelanh ([#266](https://github.com/whelanh/scidCommunity/pull/266)).
- The current move is readable again in the **PGN Window** when a light theme is used.

## 5.1.4.10 — 6 September 2026

- The **Book Window** can compare up to three opening books side by side, each chosen separately, with moves sorted alphabetically and identical moves lined up across books. — thanks to @whelanh ([#263](https://github.com/whelanh/scidCommunity/pull/263)).
- Moves that appear only in the opposing book can be shown as well. — thanks to @whelanh ([#263](https://github.com/whelanh/scidCommunity/pull/263)).

## 5.1.4.09 — 4 September 2026

- The time analysis graph can now plot engine evaluations alongside your remaining clock time, and it refreshes when the game text changes. — thanks to @whelanh ([#260](https://github.com/whelanh/scidCommunity/pull/260)).

## 5.1.4.08 — 2 September 2026

- Loading a saved mask, and loading a game from the database, work again. — thanks to @whelanh ([#255](https://github.com/whelanh/scidCommunity/pull/255)).

## 5.1.4.07 — 2 September 2026

- Importing your games from Lichess and Chess.com works again.

## 5.1.4.06 — 29 August 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.4.05 — 28 August 2026

- 3D piece sets and board textures from [Uwe Klimmek's scid tree](https://codeberg.org/scid/scid) are now included, drawn at the right scale for each board size. — thanks to @whelanh ([#251](https://github.com/whelanh/scidCommunity/pull/251)).

## 5.1.4.04 — 27 August 2026

- On Omarchy Quattro desktops, scidCommunity can follow the desktop theme automatically, with a toggle in the **Options** menu; choosing a theme by hand turns the automatic following off, and your choice is remembered between sessions. — thanks to @whelanh ([#249](https://github.com/whelanh/scidCommunity/pull/249)).

## 5.1.4.03 — 27 August 2026

- Choosing an annotation in the **Tree Window** now fills a new **Game List** with the games that carry a symbol at that move.
- Playing against an engine now shows the live score and best line only while coaching is switched on. — thanks to @whelanh ([#248](https://github.com/whelanh/scidCommunity/pull/248)).

## 5.1.4.02 — 24 August 2026

- Right-clicking a move in the **Tree Window** can now find the games in which that move was played with a chosen evaluation symbol, with an "any annotation" choice, and you are warned if the position has changed since the tree was built. — thanks to @whelanh ([#245](https://github.com/whelanh/scidCommunity/pull/245)).

## 5.1.4.01 — 24 August 2026

- On Windows, your settings, data, logs and engines now live in the standard application data folder, and existing files are moved there automatically when needed. — thanks to @whelanh ([#243](https://github.com/whelanh/scidCommunity/pull/243)).
- Text in alerts and formatted messages stays readable in dark themes, and the colors follow when you change theme. — thanks to @whelanh ([#244](https://github.com/whelanh/scidCommunity/pull/244)).

## 5.1.4.00 — 23 August 2026

- The report that analyzes the positions in an EPD file now has a **Time(s)** column showing how long the engine took to find the reported best move, and positions that were never solved are marked. — thanks to @whelanh ([#240](https://github.com/whelanh/scidCommunity/pull/240)).
- On macOS, the drag-and-drop error is gone. — thanks to @whelanh ([#239](https://github.com/whelanh/scidCommunity/pull/239)).
- The **Lichess Eval** button in the **PGN Window** has moved to a new position.

## 5.1.3.99 — 17 August 2026

- Engine output in the **Analysis Window** is grouped into depth blocks, with a dashed line where the depth increases, and the current block updates in place as new lines arrive. — thanks to @whelanh ([#238](https://github.com/whelanh/scidCommunity/pull/238)).

## 5.1.3.98 — 15 August 2026

- Games fetched from ICCF and LSS now carry up-to-date PGN header information.

## 5.1.3.97 — 13 August 2026

- Refreshing the ICCF or LSS game list clears the marks on moves you already sent, so you can see what is still waiting.

## 5.1.3.96 — 12 August 2026

- The ICCF and LSS game lists can be sorted by clicking a column heading, and they start out ordered by the time you have left to move. — thanks to @whelanh ([#233](https://github.com/whelanh/scidCommunity/pull/233)).
- Games with less than ten days left show in orange and games with less than two days in red, so urgent games stand out. — thanks to @whelanh ([#233](https://github.com/whelanh/scidCommunity/pull/233)).

## 5.1.3.95 — 11 August 2026

- Correspondence chess on the ICCF server is supported in the same way, with its own **Play** menu entry, saved connection settings, game lists, move sending, draw offers, resignations and messages. — thanks to @whelanh ([#232](https://github.com/whelanh/scidCommunity/pull/232)).
- Loading one of your online games now jumps straight to the latest move, and international characters in game data are handled correctly.

## 5.1.3.94 — 11 August 2026

- Games on the Lechenicher SchachServer can now be played from scidCommunity: sign in from the **Play** menu, bring your games into a database, send moves and messages, offer or accept draws and resign. — thanks to @whelanh ([#230](https://github.com/whelanh/scidCommunity/pull/230)).

## 5.1.3.93 — 3 August 2026

- Clicking a line in the **Lichess Eval** results plays that move on the board, and an open results window refreshes itself when the position changes. — thanks to @whelanh ([#228](https://github.com/whelanh/scidCommunity/pull/228)).

## 5.1.3.92 — 2 August 2026

- An **Annotations** option in the **Tree Window** reads the evaluation symbols from the games in the current filter, shows how often each one appears at a move, and can fill them in automatically. — thanks to @whelanh ([#226](https://github.com/whelanh/scidCommunity/pull/226)).

## 5.1.3.91 — 1 August 2026

- The **Tree Window** statistics now show the average game length in moves, for each move and in the totals row. — thanks to @whelanh ([#223](https://github.com/whelanh/scidCommunity/pull/223)).

## 5.1.3.90 — 30 July 2026

- On Windows, clicking a variation in the variations popup now selects and opens it, and the popup closes only when focus really leaves it. — thanks to @whelanh ([#222](https://github.com/whelanh/scidCommunity/pull/222)).

## 5.1.3.89 — 30 July 2026

- The **Windows** menu no longer offers to open or hide the main board, and the entry is gone from every language. — thanks to @whelanh ([#220](https://github.com/whelanh/scidCommunity/pull/220)).
- The variations popup no longer closes itself when focus shifts inside it, so choosing a variation with the keyboard stops breaking off. — thanks to @whelanh ([#221](https://github.com/whelanh/scidCommunity/pull/221)).

## 5.1.3.88 — 29 July 2026

- The variations window stays visible, appears in the right place and can no longer be resized, and picking a variation with the mouse or keyboard works reliably. — thanks to @whelanh ([#219](https://github.com/whelanh/scidCommunity/pull/219)).
- The German menu label for the board window now reads "Schachbrett" instead of "Planke".

## 5.1.3.87 — 28 July 2026

- Search windows open as ordinary, independent windows, so tiling window managers can place them properly. — thanks to @whelanh ([#218](https://github.com/whelanh/scidCommunity/pull/218)).

## 5.1.3.86 — 27 July 2026

- The stored evaluations pane in the **Engine Window** keeps the height you drag it to.
- Installing an engine now finishes even when its optional companion configuration and support files cannot be downloaded. — thanks to @whelanh ([#217](https://github.com/whelanh/scidCommunity/pull/217)).

## 5.1.3.85 — 24 July 2026

- Repeating positions are still detected as draws when moves are added automatically rather than by hand.

## 5.1.3.84 — 23 July 2026

- Undocked windows now carry a tab that docks them again, and right-clicking that tab offers **Dock** and **Close**. — thanks to @whelanh ([#215](https://github.com/whelanh/scidCommunity/pull/215)).
- The main window can now be undocked like the other windows. — thanks to @whelanh ([#214](https://github.com/whelanh/scidCommunity/pull/214)).
- A game is now ended as a draw when the same position occurs three times during analysis or autoplay. — thanks to @whelanh ([#214](https://github.com/whelanh/scidCommunity/pull/214)).

## 5.1.3.83 — 21 July 2026

- The main board now has its own menu entries, so its commands can be reached from the menu bar. — thanks to @whelanh ([#212](https://github.com/whelanh/scidCommunity/pull/212)).

## 5.1.3.82 — 19 July 2026

- A 3D piece set from [Uwe Klimmek's scid project](https://codeberg.org/scid/scid) is now included for the 3D board. — thanks to @whelanh ([#210](https://github.com/whelanh/scidCommunity/pull/210)).
- An undocked board is now kept when the current layout is saved as the default.

## 5.1.3.81 — 19 July 2026

- Databases, PGN files and position files can be dragged from the file manager onto the board or the **PGN Window** to open them. — thanks to @whelanh ([#207](https://github.com/whelanh/scidCommunity/pull/207)).
- Opening an EPD file now closes the current game first, so the game and the position file no longer interfere.

## 5.1.3.80 — 18 July 2026

- Starting a new game against an engine now sets the correct side to move and board orientation. — thanks to @whelanh ([#206](https://github.com/whelanh/scidCommunity/pull/206)).
- The coach bases its blunder comments on the analysis made during your turn, so the warnings match the move you played. — thanks to @whelanh ([#206](https://github.com/whelanh/scidCommunity/pull/206)).
- The message shown when a resigned game is saved is now translated.

## 5.1.3.79 — 17 July 2026

- Menu text is now legible on Windows, and the engine's own blunders are reported when you play against it. — thanks to @whelanh ([#205](https://github.com/whelanh/scidCommunity/pull/205)).

## 5.1.3.78 — 17 July 2026

- A whole EPD record, position and fields together, can now be copied and pasted, so positions can be moved between files. — thanks to @whelanh ([#204](https://github.com/whelanh/scidCommunity/pull/204)).

## 5.1.3.77 — 17 July 2026

- Records can be deleted from an EPD file, and a position added from the board now carries its best move and evaluation when an engine is available. — thanks to @whelanh ([#203](https://github.com/whelanh/scidCommunity/pull/203)).
- In **Play versus Engine**, blunder checks no longer carry over from one game to the next, and the **Add score to all moves** option now follows the chosen language. — thanks to @whelanh ([#202](https://github.com/whelanh/scidCommunity/pull/202)).

## 5.1.3.76 — 16 July 2026

- The program now starts faster, becoming usable while databases, spell-check data and player photos load in the background. — thanks to @whelanh ([#201](https://github.com/whelanh/scidCommunity/pull/201)).

## 5.1.3.75 — 16 July 2026

- Problems with the EPD window on Windows have been fixed.

## 5.1.3.74 — 16 July 2026

- Playing against an engine has been refined following user testing.
- Several engine names have been corrected, a problem seen on Windows has been fixed, and the Alouette engine no longer appears in the engine list.

## 5.1.3.73 — 15 July 2026

- Files whose names contain accented or non-Latin characters can now be opened correctly. — thanks to @whelanh ([#199](https://github.com/whelanh/scidCommunity/pull/199)).
- The Lucas Chess installer now finds engine programs on Windows and downloads engine files that are kept in subfolders. — thanks to @whelanh ([#198](https://github.com/whelanh/scidCommunity/pull/198)).

## 5.1.3.72 — 15 July 2026

- You can now let the program choose your color at random when setting up a game against an engine, and coaching can add a score to every move. — thanks to @whelanh ([#197](https://github.com/whelanh/scidCommunity/pull/197)).
- Coaching feedback on blunders and on taking moves back has been improved. — thanks to @whelanh ([#197](https://github.com/whelanh/scidCommunity/pull/197)).
- Installing engines from the Lucas Chess collection now works on Windows.

## 5.1.3.71 — 14 July 2026

- **Tactical Game** and **Serious Game** are replaced by a single **Play versus Engine** entry, with engine choice, coaching, clocks and opening books set up in one place. — thanks to @whelanh ([#196](https://github.com/whelanh/scidCommunity/pull/196)).
- The engines offered by the [Lucas Chess collection](https://github.com/lukasmonk/lucaschessR6) can be browsed and installed from the engine list, with the engine files downloaded for you. — thanks to @whelanh ([#195](https://github.com/whelanh/scidCommunity/pull/195)).
- The coach now judges your blunders correctly and keeps its analysis panel up to date while you play. — thanks to @whelanh ([#196](https://github.com/whelanh/scidCommunity/pull/196)).

## 5.1.3.70 — 12 July 2026

- A further problem with the text report produced from an EPD file has been fixed.

## 5.1.3.69 — 11 July 2026

- Analysis in the EPD window now reads the best-move and avoid-move instructions of each position, so results no longer reflect moves left over from an earlier position; comma- and space-separated move lists are both understood. — thanks to @whelanh ([#193](https://github.com/whelanh/scidCommunity/pull/193)).

## 5.1.3.68 — 11 July 2026

- The translated Tip of the Day text has been restored. — thanks to @whelanh ([#191](https://github.com/whelanh/scidCommunity/pull/191)).

## 5.1.3.67 — 10 July 2026

- Automatic analysis of the positions in an EPD file has been improved.

## 5.1.3.66 — 10 July 2026

- A dedicated **EPD Window** opens position files for browsing, editing and saving, with movement between positions, random selection of a position, and stripping or sorting of the fields in each one ([help page](help/EPD.html)). — thanks to @whelanh ([#189](https://github.com/whelanh/scidCommunity/pull/189)).
- The positions in an EPD file can be analyzed by an engine, with the results written back into the file and summarized as best-move statistics. — thanks to @whelanh ([#189](https://github.com/whelanh/scidCommunity/pull/189)).

## 5.1.3.65 — 9 July 2026

- Translated help pages are now included for more languages. — thanks to @whelanh ([#187](https://github.com/whelanh/scidCommunity/pull/187)).

## 5.1.3.64 — 8 July 2026

- Polish help pages are now loaded automatically when Polish is chosen as the language, so translated help appears as soon as it is needed. — thanks to @whelanh ([#186](https://github.com/whelanh/scidCommunity/pull/186)).
- Many Polish labels, menu entries, dialog buttons and tooltips have been reworded for clarity. — thanks to @whelanh ([#186](https://github.com/whelanh/scidCommunity/pull/186)).

## 5.1.3.63 — 6 July 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.3.62 — 6 July 2026

- Best-move arrows are drawn correctly when the engine is started from the evaluation bar, and several arrows appear when the engine reports several main lines. — thanks to @whelanh ([#184](https://github.com/whelanh/scidCommunity/pull/184)).

## 5.1.3.61 — 5 July 2026

- A further error in the numerical values the engine reports has been fixed.

## 5.1.3.60 — 5 July 2026

- A problem with the results reported by the engine has been fixed.

## 5.1.3.59 — 28 June 2026

- The Tip of the Day is now translated into many more languages. — thanks to @whelanh ([#181](https://github.com/whelanh/scidCommunity/pull/181)).

## 5.1.3.58 — 26 June 2026

- Translation updates only.

## 5.1.3.57 — 23 June 2026

- Several analysis sessions can now be open at once, each in its own **Analysis Window** with its own engine, and a warning appears when finishing a game would take over the second engine. — thanks to @whelanh ([#177](https://github.com/whelanh/scidCommunity/pull/177)).
- Isometric piece sets are now drawn larger, so the pieces are easier to tell apart. — thanks to @whelanh ([#173](https://github.com/whelanh/scidCommunity/pull/173)).
- New isometric plastic, wood and ModernWood Staunton piece sets are included.

## 5.1.3.56 — 16 June 2026

- Small problems with the new 3D board have been fixed.

## 5.1.3.55 — 16 June 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.3.54 — 16 June 2026

- A 3D board view can be opened from the menu or with Ctrl+3: drag to turn the view, use the wheel to zoom, reset or flip the board, and move pieces by dragging them. — thanks to @whelanh ([#170](https://github.com/whelanh/scidCommunity/pull/170)).

## 5.1.3.53 — 13 June 2026

- Engine settings chosen for a serious game are now saved with the engine you picked, instead of being lost when the dialogs close. — thanks to @whelanh ([#169](https://github.com/whelanh/scidCommunity/pull/169)).

## 5.1.3.52 — 13 June 2026

- Lichess puzzles can be solved from a new **Play** menu entry, with the daily puzzle, a choice of difficulty, theme and color, hints, full solutions and feedback on each attempt. — thanks to @whelanh ([#165](https://github.com/whelanh/scidCommunity/pull/165)).

## 5.1.3.51 — 11 June 2026

- Local evaluations are cached again in the **Engine Window**, so returning to a position reuses earlier results instead of asking the engine to search it again. — thanks to @whelanh ([#164](https://github.com/whelanh/scidCommunity/pull/164)).

## 5.1.3.50 — 11 June 2026

- Engine tournaments can now be played with reversed colors, and games end automatically by draw or resignation under configurable rules. — thanks to @whelanh ([#163](https://github.com/whelanh/scidCommunity/pull/163)).

## 5.1.3.49 — 10 June 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.3.48 — 9 June 2026

- A new **PGN Viewer** shows the game on an interactive board with variation navigation, autoplay and an engine score graph, and **Open in PGN Viewer** in the **Game List** opens it. — thanks to @whelanh ([#155](https://github.com/whelanh/scidCommunity/pull/155)).
- The separate game browser window has been removed, and right-clicking a game now offers just **Load Game** and **Merge Game**. — thanks to @whelanh ([#156](https://github.com/whelanh/scidCommunity/pull/156)).
- Scrolling the mouse wheel in the **PGN Viewer** now moves through the game, and its move display has been corrected. — thanks to @whelanh ([#158](https://github.com/whelanh/scidCommunity/pull/158), [#159](https://github.com/whelanh/scidCommunity/pull/159)).
- Engines are now managed in a configuration dialog where they can be added, edited and deleted, sorted by name, rating or last use, and installed engines are found automatically. — thanks to @whelanh ([#153](https://github.com/whelanh/scidCommunity/pull/153)).

## 5.1.3.47 — 8 June 2026

- The main toolbar now works correctly on Windows.

## 5.1.3.46 — 8 June 2026

- More Windows-specific problems have been fixed.

## 5.1.3.45 — 7 June 2026

- A problem that only affected Windows users has been fixed.

## 5.1.3.44 — 7 June 2026

- Engines can now play tournaments against each other, several games at a time, with opening books, configurable time controls and settings that are saved and reloaded; the **Play Tournament** command runs them without opening a separate window for every engine. — thanks to @whelanh ([#151](https://github.com/whelanh/scidCommunity/pull/151)).
- A new **Tablebase Window** shows Lichess endgame tablebase results for the current position, listing winning, drawing and losing moves that can be clicked, and it follows the board as you step through a game, including Chess960 positions. — thanks to @whelanh ([#150](https://github.com/whelanh/scidCommunity/pull/150)).
- Switching between interface themes is faster.

## 5.1.3.43 — 6 June 2026

- The light and dark interface themes now load their shared buttons, scroll bars and entry fields again, so both themes can be selected ([Uwe Klimmek's theme collection](https://codeberg.org/scid/ttk-themes)).

## 5.1.3.42 — 6 June 2026

- The Neo-Wood piece set is now included.
- Several problems with the recently imported board display features were fixed. — thanks to @whelanh ([#145](https://github.com/whelanh/scidCommunity/pull/145)).

## 5.1.3.41 — 5 June 2026

- Thirteen color themes, six dark and seven light, and a matching set of dark toolbar icons from [Uwe Klimmek's theme collection](https://codeberg.org/scid/ttk-themes) are now bundled. — thanks to @whelanh ([#143](https://github.com/whelanh/scidCommunity/pull/143)).

## 5.1.3.40 — 5 June 2026

- Board display work from [Uwe Klimmek's scid tree](https://codeberg.org/scid/scid) is now included, with the material difference shown in the player name bars instead of a side panel. — thanks to @whelanh ([#142](https://github.com/whelanh/scidCommunity/pull/142)).
- A compact toolbar below the board toggles flipping the board, material, the evaluation bar, coordinates, markers, autoplay, player information, and game navigation. — thanks to @whelanh ([#142](https://github.com/whelanh/scidCommunity/pull/142)).
- The main toolbar commands are now icons in the menu bar, and the result next to the kings marks how the game ended. — thanks to @whelanh ([#142](https://github.com/whelanh/scidCommunity/pull/142)).

## 5.1.3.39 — 3 June 2026

- The mouse wheel now scrolls correctly in the Windows version. — thanks to @tyson-mc ([#141](https://github.com/whelanh/scidCommunity/pull/141)).

## 5.1.3.38 — 26 May 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.3.37 — 26 May 2026

- Move sounds now follow the interface language where a matching sound set exists, with a set of German sounds included and the default sounds used when a language has none. — thanks to @whelanh ([#139](https://github.com/whelanh/scidCommunity/pull/139)).

## 5.1.3.36 — 22 May 2026

- The move depth setting for the **Tree Window** now uses plies, and your choice of it is saved correctly.

## 5.1.3.35 — 21 May 2026

- The menu option for annotation symbols is now worded more clearly in 17 languages, so it no longer reads as if it referred to engine evaluations. — thanks to @whelanh ([#137](https://github.com/whelanh/scidCommunity/pull/137)).

## 5.1.3.34 — 18 May 2026

- A Delete Game menu command now turns the delete flag on or off for the current game, and is unavailable when no game is loaded or the database is read-only. — thanks to @whelanh ([#134](https://github.com/whelanh/scidCommunity/pull/134)).

## 5.1.3.33 — 17 May 2026

- Ctrl+X now deletes the games selected in the **Game List** without going through a menu. — thanks to @whelanh ([#133](https://github.com/whelanh/scidCommunity/pull/133)).
- The games you have selected stay selected when the **Game List** is refreshed or reloaded. — thanks to @whelanh ([#133](https://github.com/whelanh/scidCommunity/pull/133)).

## 5.1.3.32 — 13 May 2026

- Pressing Ctrl+S to save a game now places the Save/Replace dialog where it is visible and usable. — thanks to @whelanh ([#130](https://github.com/whelanh/scidCommunity/pull/130)).

## 5.1.3.31 — 12 May 2026

- The Top Games and Recent Games tables in the Opening Explorer can be sorted by clicking a column heading, with ratings compared as numbers. — thanks to @whelanh ([#127](https://github.com/whelanh/scidCommunity/pull/127)).
- Repeated Opening Explorer lookups reuse one clipbase window instead of opening a new one each time. — thanks to @whelanh ([#128](https://github.com/whelanh/scidCommunity/pull/128)).

## 5.1.3.30 — 12 May 2026

- Double-clicking a move in the Opening Explorer plays it on the board and refreshes the explorer for the new position. — thanks to @whelanh ([#126](https://github.com/whelanh/scidCommunity/pull/126)).
- Games imported from Lichess are saved and loaded again automatically, with the **Game List** opened for them. — thanks to @whelanh ([#126](https://github.com/whelanh/scidCommunity/pull/126)).
- The Opening Explorer detects Chess960 games in Lichess and player databases.

## 5.1.3.29 — 11 May 2026

- The Opening Explorer now asks for a Lichess API token before contacting Lichess, explains why one is needed, and no longer describes the token as optional.

## 5.1.3.28 — 11 May 2026

- The Lichess Opening Explorer can now be opened from the main menu and from the **PGN Window**. — thanks to @whelanh ([#124](https://github.com/whelanh/scidCommunity/pull/124)).

## 5.1.3.27 — 9 May 2026

- A new Berlin piece set is available.
- The piece and board style lists are now sorted alphabetically.

## 5.1.3.26 — 8 May 2026

- Bulgarian can now be selected as the interface language. — thanks to @whelanh ([#121](https://github.com/whelanh/scidCommunity/pull/121)).

## 5.1.3.25 — 7 May 2026

- Translation updates only.

## 5.1.3.24 — 7 May 2026

- The background and main text colors of the FICS console can now be chosen in **Preferences**. — thanks to @whelanh ([#119](https://github.com/whelanh/scidCommunity/pull/119)).

## 5.1.3.23 — 6 May 2026

- Custom **Game List** layouts can now be saved, renamed, and deleted, with your own layouts listed in a submenu alongside the default ones. — thanks to @whelanh ([#117](https://github.com/whelanh/scidCommunity/pull/117)).

## 5.1.3.22 — 1 May 2026

- Translation updates only.

## 5.1.3.21 — 1 May 2026

- Long text in the comment information bar is no longer clipped. — thanks to @medwatt ([#115](https://github.com/whelanh/scidCommunity/pull/115)).
- Translation corrections and text encoding fixes were applied across several languages.

## 5.1.3.20 — 30 April 2026

- Translation updates only.

## 5.1.3.19 — 30 April 2026

- The Relative Filter Graph can now show a win percentage graph. — thanks to @whelanh ([#112](https://github.com/whelanh/scidCommunity/pull/112)).

## 5.1.3.18 — 29 April 2026

- Batch annotation now offers the same options and produces the same kind of output as annotating from the **Analysis Window**. — thanks to @whelanh ([#111](https://github.com/whelanh/scidCommunity/pull/111)).
- Selecting several games at once in the **Game List** is easier to do accurately. — thanks to @whelanh ([#110](https://github.com/whelanh/scidCommunity/pull/110)).

## 5.1.3.17 — 28 April 2026

- Batch annotation now shows simpler progress and completion messages, and reports problems rather than continuing silently. — thanks to @whelanh ([#107](https://github.com/whelanh/scidCommunity/pull/107)).
- The choices you make for a batch annotation run can now be saved and reused. — thanks to @whelanh ([#106](https://github.com/whelanh/scidCommunity/pull/106)).

## 5.1.3.16 — 27 April 2026

- Further refinements were made to batch annotation.

## 5.1.3.15 — 27 April 2026

- Annotations can now be added to a whole set of games in one batch instead of one game at a time. — thanks to @whelanh ([#104](https://github.com/whelanh/scidCommunity/pull/104)).
- Several small display problems in dark themes were corrected. — thanks to @whelanh ([#104](https://github.com/whelanh/scidCommunity/pull/104)).

## 5.1.3.14 — 25 April 2026

- The evaluation bar now displays correctly while the **Engine Window** is open. — thanks to @whelanh ([#102](https://github.com/whelanh/scidCommunity/pull/102)).

## 5.1.3.13 — 23 April 2026

- Links in an Opening Report now work when a different database was chosen as the reference. — thanks to @whelanh ([#99](https://github.com/whelanh/scidCommunity/pull/99)).
- Report pop-up windows now stay with the window that opened them. — thanks to @whelanh ([#99](https://github.com/whelanh/scidCommunity/pull/99)).

## 5.1.3.12 — 23 April 2026

- Opening Reports can be generated against a reference database that you choose, and the report states when that reference differs from the current database. — thanks to @whelanh ([#98](https://github.com/whelanh/scidCommunity/pull/98)).
- Annotation settings such as using the analysis book, which side to annotate, and variation length are now saved between sessions. — thanks to @whelanh ([#98](https://github.com/whelanh/scidCommunity/pull/98)).

## 5.1.3.11 — 22 April 2026

- Hindi, Ukrainian, and Bengali can now be selected as interface languages. — thanks to @whelanh ([#95](https://github.com/whelanh/scidCommunity/pull/95)).
- Untranslated text now falls back to the default language instead of producing an error. — thanks to @whelanh ([#95](https://github.com/whelanh/scidCommunity/pull/95)).

## 5.1.3.10 — 22 April 2026

- The rating columns in the FICS Players tab now carry the correct labels. — thanks to @whelanh ([#94](https://github.com/whelanh/scidCommunity/pull/94)).

## 5.1.3.09 — 21 April 2026

- When opening a game from disk, double-clicking a folder and using the up arrow now navigate as expected. — thanks to @whelanh ([#92](https://github.com/whelanh/scidCommunity/pull/92)).
- The best move reported by the Lichess tablebase lookup in the **Engine Window** is now given in ordinary chess notation. — thanks to @whelanh ([#92](https://github.com/whelanh/scidCommunity/pull/92)).

## 5.1.3.08 — 19 April 2026

- Swahili can now be selected as the interface language. — thanks to @whelanh ([#91](https://github.com/whelanh/scidCommunity/pull/91)).

## 5.1.3.07 — 17 April 2026

- The program no longer crashes when no database is open.

## 5.1.3.06 — 17 April 2026

- Load Next Game in the **Game List** now follows the sort order you have applied rather than the order of games in the database.

## 5.1.3.05 — 16 April 2026

- The Relative Filter Graph now reports values with an extra digit of precision.
- Portuguese translations were improved.

## 5.1.3.04 — 11 April 2026

- The Relative Filter Graph was revised and its labels were corrected in translation.

## 5.1.3.03 — 10 April 2026

- The Relative Filter Graph now draws correctly, and several interface strings were corrected in translation.

## 5.1.3.02 — 10 April 2026

- Translation updates only.

## 5.1.3.01 — 10 April 2026

- Translation updates only.

## 5.1.2.99 — 10 April 2026

- Menus display correctly in Arabic and Hebrew.

## 5.1.2.98 — 10 April 2026

- Arabic and Hebrew are now available as interface languages ([help page](help/Menus.html#Options)).
- Piece letters are translated correctly in languages whose piece letters are ordinary letters, such as French, where the king is R.

## 5.1.2.97 — 9 April 2026

- The **Game List** keeps the order you chose when a database is loaded again.
- The **Game List** displays correctly when a database holds only a few games.

## 5.1.2.96 — 8 April 2026

- Entering clock times for a game is now quick from the keyboard: Return submits a time, the editor moves to the next move and leaves the cursor in the minutes field.

## 5.1.2.95 — 7 April 2026

- Mouse wheel scrolling works again in the windows where it had stopped.

## 5.1.2.94 — 7 April 2026

- Dark themes no longer crash the program.
- The **Material Search** window no longer refers to a save button that is not there. — thanks to @AtharvShirgurkar ([#85](https://github.com/whelanh/scidCommunity/pull/85)).

## 5.1.2.93 — 7 April 2026

- Theme files are now evaluated in a restricted interpreter, so an untrusted theme cannot run commands of its own.

## 5.1.2.92 — 6 April 2026

- Double-clicking a game no longer scrolls the **Game List**, so the list stays where you left it.
- Classifying games by ECO code is fast enough now that the progress bar has been removed.

## 5.1.2.91 — 6 April 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.90 — 6 April 2026

- Building the **Tree Window**, finding twin games and applying filters are faster on large databases.
- Selecting games in the **Game List** was corrected.

## 5.1.2.89 — 5 April 2026

- Selecting several games in the **Game List** works reliably again.

## 5.1.2.88 — 4 April 2026

- A Ctrl + click or Shift + click selection in the **Game List** now stays selected while you work elsewhere in the list.
- Progress windows carry the scidCommunity name instead of Scid.

## 5.1.2.87 — 4 April 2026

- In the **Game List**, Ctrl + click and Shift + click select single games and ranges, so you can export or delete a chosen set of games.
- Buttons in the **Engine Window** are easier to see.

## 5.1.2.86 — 3 April 2026

- The time comments the program writes for serious games now follow the Lichess format, so the clock times are understood when the game is shared there.
- The axis labels in the **Time Analysis** graphs are now correct.

## 5.1.2.85 — 31 March 2026

- Looking up an informant value now returns the right symbol.

## 5.1.2.84 — 30 March 2026

- The **Preferences** list of informant values now shows each value's default score beside the symbol.
- A new **Sand Evening** theme is available ([help page](help/Menus.html#Options)).
- Spanish text no longer shows garbled characters, and several other translations were updated.

## 5.1.2.83 — 28 March 2026

- A star cannot appear in a file name on Windows, so parentheses in a photo file name now act as the wildcard instead.

## 5.1.2.82 — 28 March 2026

- Photo file names may now contain wildcards, so a single image can stand in for many players, such as every game against one engine.

## 5.1.2.81 — 28 March 2026

- Player photos are matched to names more reliably, so differences in spacing, capitals and accents no longer stop a photo from being found.
- A helper for creating your own player photo file is included.

## 5.1.2.80 — 26 March 2026

- The **Opening Report** was updated and improved.

## 5.1.2.79 — 26 March 2026

- Move evaluation symbols can now be shown on the board at the last move, separately from the annotation symbols.
- The **Opening Report** gives correct results again.

## 5.1.2.78 — 25 March 2026

- The **Header Search** window has a new **Invert Search** button that returns the games which do not match the criteria you entered.

## 5.1.2.77 — 25 March 2026

- Further corrections to reading older mask files and to their dash-prefixed comments.

## 5.1.2.76 — 25 March 2026

- Older mask files are read more reliably, and comment lines in a mask file may now begin with a dash.

## 5.1.2.75 — 24 March 2026

- Mask files stored in a folder whose path contains spaces now load correctly.

## 5.1.2.74 — 24 March 2026

- Loading of mask files was corrected.

## 5.1.2.73 — 24 March 2026

- On Linux, large database files are now held in memory in a way that makes reading them faster.
- Loading a mask file that is damaged no longer risks a crash.

## 5.1.2.72 — 23 March 2026

- Memory handling was hardened, so crashes caused by memory errors are less likely.

## 5.1.2.71 — 23 March 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.70 — 23 March 2026

- Security-related updates were applied.

## 5.1.2.69 — 23 March 2026

- Loading a game now takes the **Game List** to that game and highlights it.

## 5.1.2.68 — 21 March 2026

- **Time Analysis** now works for games whose clock times are written as clock comments in the game text.
- The warning shown when a database is already in use has been expanded, and it is translated.

## 5.1.2.67 — 20 March 2026

- A left mouse click in the **Database Switcher** now selects the database under the cursor as expected.

## 5.1.2.66 — 20 March 2026

- The new time analysis and database compression messages now appear in your chosen language.

## 5.1.2.65 — 19 March 2026

- Theme files you add are now picked up automatically at startup, and two sample themes, Catppuccin Mocha and Dracula, are included. — thanks to @AtharvShirgurkar ([#57](https://github.com/whelanh/scidCommunity/pull/57)).

## 5.1.2.64 — 19 March 2026

- Minor refinements to the **Time Analysis** window.

## 5.1.2.63 — 18 March 2026

- A new **Tools/Time Analysis** window graphs the time left on the clock and the time spent on each move for games that record clock times.
- The **Comment Editor** has a new time entry panel: type hours, minutes and seconds, or a total number of minutes, and insert the clock time into the comment.
- Compacting a database now warns you when damage to it is found, instead of carrying on silently.

## 5.1.2.62 — 15 March 2026

- **Tactical Game** now lets you play as White, Black, or a random side, and the opponent strength slider reaches down to 700 Elo instead of stopping at 1200 ([help page](help/Menus.html#Play)).
- Phalanx is no longer included in the Windows version.

## 5.1.2.61 — 14 March 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.60 — 14 March 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.59 — 14 March 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.58 — 14 March 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.57 — 14 March 2026

- One more Windows fix went into the Phalanx engine.

## 5.1.2.56 — 14 March 2026

- A further Windows fix went into the Phalanx engine.

## 5.1.2.55 — 14 March 2026

- Windows fixes for the Phalanx engine continued.

## 5.1.2.54 — 14 March 2026

- Another Windows fix went into the built-in Phalanx engine.

## 5.1.2.53 — 14 March 2026

- The built-in Phalanx engine now runs in the Windows version.
- The Portuguese translation was updated.

## 5.1.2.52 — 13 March 2026

- The board navigation buttons step through the game correctly again.

## 5.1.2.51 — 12 March 2026

- The Auto Comment and Game Comment buttons now live in the **Engine Window** rather than the **PGN Window** and the **Analysis Window**.
- The instructions sent for Auto Comment now include a checklist the model is asked to check its comment against.
- Portuguese piece letters are now recognized.

## 5.1.2.50 — 12 March 2026

- Engine results in the **Engine Window** are held in memory again, so a position you revisit shows its lines without a fresh search.

## 5.1.2.49 — 11 March 2026

- The engine score chart redraws when you choose a different game in the **Game List**.

## 5.1.2.48 — 11 March 2026

- The engine score chart in the **Engine Window** now shows each side's game accuracy, calculated the way Lichess does it.

## 5.1.2.47 — 10 March 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.46 — 10 March 2026

- Move sounds on the Windows version were reworked.

## 5.1.2.45 — 10 March 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.44 — 9 March 2026

- Clicking a point on the engine score chart moves the board to that position in the game.

## 5.1.2.43 — 9 March 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.42 — 9 March 2026

- The **Engine Window** score graph was fixed for the Windows version.

## 5.1.2.41 — 9 March 2026

- The **Engine Window** now has a score graph of the current game.
- Sound choices are kept when you save your options.

## 5.1.2.40 — 8 March 2026

- If you switch the engine arrows off, they now stay off.
- More move sounds are available to choose from.

## 5.1.2.39 — 7 March 2026

- Auto Comment now uses the **Tree Window** statistics for the position when it writes a comment.
- Position setup and switching between databases were brought in line with the latest [Scid](https://scid.sourceforge.net/) release.

## 5.1.2.38 — 5 March 2026

- Auto Comment writes in the language the program is set to.

## 5.1.2.37 — 5 March 2026

- Auto Comment now sends the game's moves with its request, so a comment can take the whole game into account.

## 5.1.2.36 — 4 March 2026

- Auto Comment's instructions to the AI model were revised to produce more useful comments.

## 5.1.2.35 — 3 March 2026

- A new Auto Comment button in the **PGN Window** asks an AI model to write a comment for the move you are on.
- The Auto Comment dialog explains its choices and offers more of them, including the thresholds used for annotations.

## 5.1.2.34 — 28 February 2026

- Stored engine evaluations now load in the Windows version.

## 5.1.2.33 — 27 February 2026

- A new panel in the **Engine Window** lists the positions you have stored.

## 5.1.2.32 — 26 February 2026

- A new Lichess Eval button fetches the evaluations Lichess has stored for the current position.

## 5.1.2.31 — 24 February 2026

- Move sounds work in the Snap and Flatpak versions.

## 5.1.2.30 — 22 February 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.29 — 22 February 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.28 — 22 February 2026

- A leftover sound debugging window no longer appears while move sounds play.

## 5.1.2.27 — 22 February 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.26 — 22 February 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.25 — 22 February 2026

- Translation updates only.

## 5.1.2.24 — 21 February 2026

- Move sounds and spoken move announcements play again.
- Buttons in the engine configuration dialog now carry their correct labels.

## 5.1.2.23 — 17 February 2026

- Tips of the Day call the program scidCommunity, and a tip that no longer applied was removed.
- Searches through the headless API return up to 10,000 games and can ask for games that carry particular tags, such as ICCF ([documentation](docs/HEADLESS_API_SPEC.md)).

## 5.1.2.22 — 11 February 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.21 — 11 February 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.20 — 9 February 2026

- A headless API lets other programs open a Scid database, search it including by tag, read games and add new ones ([documentation](docs/HEADLESS_API_SPEC.md)).
- A database opened through the API is locked while it is in use, so two programs cannot damage the same file at once.

## 5.1.2.19 — 8 February 2026

- Lichess table base lookups now describe partial 8-piece coverage more accurately.

## 5.1.2.18 — 5 February 2026

- The **Tree Window** has a %Win column again, showing each move's win rate for the side to move, and its color coding is back ([help page](help/Tree.html)).
- Column headers in the **Tree Window** no longer run into each other in translated versions of the program.

## 5.1.2.17 — 4 February 2026

- Translation updates only.

## 5.1.2.16 — 4 February 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.15 — 4 February 2026

- The **Tree Window** now shows up to four half-move sequences, with the depth available in **Options/Preferences/Moves**.

## 5.1.2.14 — 3 February 2026

- The **Tree Window** can now show more than one move sequence at a time.

## 5.1.2.13 — 3 February 2026

- HTML exports now open automatically in your web browser, for a single game as well as for a whole filtered list.
- Diagrams now appear in HTML exports as they should, and the chessboard squares keep their colors when you print the export or save it as PDF ([help page](help/Export.html)).

## 5.1.2.12 — 3 February 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.11 — 3 February 2026

- Games dated before the year 1000 can now be imported, and PGN dates with one to four digit years are accepted.

## 5.1.2.10 — 2 February 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.2.09 — 1 February 2026

- Game export options were simplified and the outdated LaTeX export was removed, leaving HTML export and its diagrams ([help page](help/Export.html)).
- Databases whose names contain accented or non-Latin characters are now handled correctly, including in the list of recently opened databases.

## 5.1.2.08 — 27 January 2026

- The **Options/Language** list now shows each language under its own name.

## 5.1.2.07 — 26 January 2026

- Japanese and Romanian translations are now available.

## 5.1.2.06 — 25 January 2026

- Turkish and Serbian (Cyrillic) translations are now available, along with updates to the existing language files.

## 5.1.2.05 — 24 January 2026

- Translation updates only.

## 5.1.2.04 — 23 January 2026

- A machine-generated Chinese translation is now available.

## 5.1.2.03 — 22 January 2026

- Translation updates only.

## 5.1.2.02 — 22 January 2026

- Square highlighting now displays correctly in the Sand and Cobalt2 themes.

## 5.1.2.01 — 18 January 2026

- Resuming a paused Lichess tournament game no longer leaves it frozen. Moves you added while paused are kept as a comment and monitoring carries on from the real game.

## 5.1.2.0 — 17 January 2026

- Moves you play yourself in a live Lichess tournament game are now kept as a comment when the real moves arrive with the next update.

## 5.1.1.99 — 16 January 2026

- Arrow-key movement between moves and variations in the **PGN Window** was adjusted.
- The date shown in **Help/About** was corrected for the Flatpak edition.

## 5.1.1.98 — 16 January 2026

- The version number and date shown in **Help/About** now display correctly.
- Arrow-key navigation in the **PGN Window** was fixed.

## 5.1.1.97 — 15 January 2026

- The engine variation arrows can now be turned off in **Options/Preferences/Moves**.

## 5.1.1.96 — 15 January 2026

- Translation updates only.

## 5.1.1.95 — 14 January 2026

- Arrow-key navigation in the **PGN Window** was refined for games that contain more than one variation.

## 5.1.1.94 — 14 January 2026

- In the **PGN Window** the down arrow now enters a variation, the right arrow continues along the line you are in, and the up arrow returns to the main line ([help page](help/PGN.html)).

## 5.1.1.93 — 14 January 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.1.92 — 14 January 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.1.91 — 14 January 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.1.90 — 14 January 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.1.89 — 14 January 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.1.88 — 14 January 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.1.87 — 14 January 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.1.86 — 14 January 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.1.85 — 14 January 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.1.84 — 14 January 2026

- Build and packaging changes only; no user-visible changes.

## 5.1.1.83 — 14 January 2026

- Annotation symbols now use the Lichess/ChessBase style by default, with the older Scid style still available in **Options/Preferences/Moves**.

## 5.1.1.82 — 14 January 2026

- Engine analysis now shows up to three colored arrows on the board, green for the best move, yellow for the second and red for the third and later moves, in the **Engine Window** and the **Analysis Window**.

## 5.1.1.81 — 12 January 2026

- Repetition detection in the **PGN Window** now also updates as you add moves on the board.

## 5.1.1.80 — 12 January 2026

- **Tools/Download TWIC Games** now opens the TWIC web page automatically ([help page](help/Menus.html)).

## 5.1.1.79 — 12 January 2026

- The **PGN Window** now detects and reports two-fold and three-fold repetitions.

## 5.1.1.78 — 9 January 2026

- **Play/Tactical Game** can now use any engine you have set up, so the old Phalanx and Toga engines are no longer needed ([help page](help/Menus.html)).

## 5.1.1.77 — 4 January 2026

- The **Best Games** button in the **Tree Window** now honors the all-games checkbox, so the list matches the games you asked to see.

## 5.1.1.76 — 2 January 2026

- The **Player Information** window now includes a pie chart of the player's results.

## 5.1.1.75 — 30 December 2025

- Lichess tournament monitoring in the **PGN Window** can now be paused and resumed with a pause button.

## 5.1.1.74 — 26 December 2025

- The hover pop-up that shows variations in the **Engine Window** now follows the board perspective you are using.

## 5.1.1.73 — 25 December 2025

- Lichess tournament games stay live in the **PGN Window** and on the board, with no checkbox left to tick ([help page](help/Menus.html)).
- Opening a game in a live tournament now moves the game and the board straight to the last move played.

## 5.1.1.72 — 24 December 2025

- The Lichess tournament monitor has been refined in response to user requests.

## 5.1.1.71 — 22 December 2025

- The **PGN Window** has a **chessdb Engine Tree** button that opens the current position in chessdb.cn's tree of engine evaluations.

## 5.1.1.7 — 20 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.69 — 20 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.68 — 18 December 2025

- **Finish Game** in the **Analysis Window** now accepts a time limit and a depth limit at the same time.

## 5.1.1.67 — 18 December 2025

- The Lichess tournament monitor has been improved.

## 5.1.1.66 — 17 December 2025

- **Finish Game** in the **Analysis Window** consults the Lichess table base, so automatic play stops once the game is decided.
- Lichess tournament games open from the **File** menu and refresh every minute while play continues.

## 5.1.1.65 — 17 December 2025

- Live Lichess broadcast tournaments can be opened and followed, with the games updated while they are being played ([help page](help/Menus.html)).
- Auto-annotation can now be set to add no variations at all.

## 5.1.1.64 — 16 December 2025

- The length of the variations written by automatic annotation can now be set.

## 5.1.1.63 — 15 December 2025

- Automatic annotation in the **Analysis Window** writes shorter variations, up to eight moves.

## 5.1.1.62 — 15 December 2025

- The Lichess and Chess.com import dialogs let you choose a month, and the Chess.com import shows a progress bar.

## 5.1.1.61 — 15 December 2025

- Your own games can now be imported from Lichess and from Chess.com ([help page](help/Menus.html)).

## 5.1.1.6 — 14 December 2025

- The Windows version now uses the new application icon.

## 5.1.1.59 — 14 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.57 — 14 December 2025

- The application icon has been revised.

## 5.1.1.56 — 14 December 2025

- The application has a new icon, and the window manager now shows a sharper PNG version of it.

## 5.1.1.55 — 14 December 2025

- The **Game Info** window is taller, and long comments now show up to three lines.

## 5.1.1.54 — 12 December 2025

- The **Engine Window** and **Analysis Window** use light-colored buttons when the dark or Cobalt2 theme is selected.

## 5.1.1.53 — 11 December 2025

- The **Cobalt2** theme has been improved, and the dark theme along with it.

## 5.1.1.52 — 8 December 2025

- The message shown after downloading TWIC games has been improved.

## 5.1.1.51 — 8 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.5 — 7 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.499 — 7 December 2025

- The name scidCommunity is now used consistently throughout the interface.

## 5.1.1.498 — 6 December 2025

- The TWIC download on Windows is repaired again.

## 5.1.1.497 — 6 December 2025

- A further Windows fix for the TWIC download is included.

## 5.1.1.496 — 6 December 2025

- Downloading TWIC games no longer fails on Windows.

## 5.1.1.41 — 6 December 2025

- Downloading TWIC games and the chess.com upload button now work on Windows.

## 5.1.1.4 — 6 December 2025

- The **PGN Window** has a **Table Base** button that looks up the current position in the Lichess seven-piece table base and reports the result, the best move and the distance to mate.
- The current game can be uploaded to Lichess from the **PGN Window**, and the uploaded game keeps its line breaks.

## 5.1.1.34 — 4 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.33 — 4 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.32 — 4 December 2025

- The **alt** and **clam** themes have been removed because they looked too similar to the classic theme.

## 5.1.1.31 — 4 December 2025

- A new **Cobalt2** dark theme is available.
- Menu colors now update as soon as you switch theme.

## 5.1.1.3 — 4 December 2025

- **Tools** now offers **Download TWIC**, which fetches the latest games from The Week in Chess and opens them in the import dialog so you can filter them or merge them into your database ([help page](help/Menus.html)).

## 5.1.1.22 — 3 December 2025

- The optional **Sand** theme has been reworked, with its colors adjusted.

## 5.1.1.2 — 3 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.13 — 2 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.12 — 2 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.11 — 2 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.10 — 2 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1.1 — 2 December 2025

- Build and packaging changes only; no user-visible changes.

## 5.1.1 — 2 December 2025

- The **Header Search** dialog has a new **Layouts** button for naming, saving and reloading sets of search parameters you use often ([documentation](docs/header_search_layouts.md)).

## 5.1.04 — 1 December 2025

- The **Header Search** dialog now starts a search with the keyboard shortcut Alt + S.
- More than one saved set of Header Search parameters can now be stored, and fields such as Site show the values a saved set contains.

## 5.1.01 — 28 November 2025

- Build and packaging changes only; no user-visible changes.

---

## Credits and origins

scidCommunity is built on other people's work as much as its own. These are the projects whose code, assets or methods appear in the releases above:

- [Scid](https://scid.sourceforge.net/), Shane Hudson's original chess information database, from which scidCommunity descends.
- [Scid vs. PC](https://scidvspc.sourceforge.net/), the long-running usability fork that several features were adopted from.
- [Uwe Klimmek's scid tree](https://codeberg.org/scid/scid), the source of the 3D piece sets and board textures.
- [Uwe Klimmek's theme collection](https://codeberg.org/scid/ttk-themes), the bundled interface themes.
- [Lucas Chess](https://github.com/lukasmonk/lucaschessR6), whose engine collection can be installed from inside scidCommunity.
- [Patzer](https://github.com/SikamikanikoBG/patzer), whose move classification, accuracy method and coaching facts inform Game Review.
- [Lichess](https://lichess.org), source of the accuracy formula, the opening explorer data, the puzzles, the sound themes and the study publishing feature.
- [Chess.com](https://www.chess.com), whose game import and upload features are integrated.
- [Stockfish](https://stockfishchess.org), the engine used by many analysis features and bundled engine workflows.

Licensing details for adapted code are recorded in [Third-party notices](docs/third-party-notices.md).
