Sound themes
============

This directory holds "sound themes": sets of move/event sounds that override
the move-type sounds used by scidCommunity when a theme is selected in
Options > Preferences > Sounds.

Each theme is a subdirectory containing any of these .wav files (names are
case-sensitive and match the base sounds/ folder):

    move.wav            generic move (fallback)
    move_normal.wav     a normal (non-capture) move
    move_capture.wav    a capture
    move_castling.wav   castling
    move_check.wav      a move giving check (also used for checkmate in
                        "move sound only" mode)
    move_promotion.wav  a promotion
    Check.wav           the "+" (check) symbol in spoken announcements
    Mate.wav            the "#" (checkmate) symbol in spoken announcements

Any file a theme does not provide falls back to the base sounds/ folder, so a
theme only needs to supply the sounds it wants to change.

Bundled themes
--------------

Each theme directory contains a "copyright" file with its attribution and the
licence that governs its files.

Lichess sound sets, converted from the open-source lichess-org/lila repository
(https://github.com/lichess-org/lila), specifically public/sound/<theme>/
(GNU AGPL v3, full text in LICENSE-AGPLv3.txt):

    standard  piano  nes  sfx  futuristic  lisp  woodland  robot

"wood", a set of wooden taps/knocks built from Kenney's "Impact Sounds" pack
(https://kenney.nl/assets/impact-sounds), CC0 public domain:

    wood

"steel", steel-drum jingles built from Kenney's "Music Jingles" pack
(https://kenney.nl/assets/music-jingles), CC0 public domain:

    steel

Mapping from Lichess event names to scidCommunity names:

    Move       -> move, move_normal, move_castling, move_promotion
    Capture    -> move_capture
    Check      -> move_check, Check
    Checkmate  -> Mate

Note: Lichess's "standard" set maps Check and Checkmate to silence (their
Check.ogg/Checkmate.ogg are symlinks to Silence.ogg). Because scidCommunity's
users expect an audible check sound, the standard theme here omits its
check/mate files so they fall back to the base sounds/ folder (Scid's own
Check, Mate and move_check). Its Move and Capture sounds remain Lichess's.

Custom themes
-------------

To add your own theme, create a folder here (e.g. sounds/themes/mine/) and put
any of the files listed above inside it. It will appear in the Sounds
preferences dropdown automatically.

Optionally add a file named "name" in the theme directory containing the label
to show in the dropdown (e.g. "steel drum" instead of "steel"); otherwise the
folder name is used.
