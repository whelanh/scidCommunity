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

The bundled themes are the Lichess sound sets, converted from the open-source
lichess-org/lila repository (https://github.com/lichess-org/lila,
AGPL-3.0), specifically public/sound/<theme>/:

    standard  piano  nes  sfx  futuristic  lisp  woodland  robot

Mapping from Lichess event names to scidCommunity names:

    Move       -> move, move_normal, move_castling, move_promotion
    Capture    -> move_capture
    Check      -> move_check, Check
    Checkmate  -> Mate

Custom themes
-------------

To add your own theme, create a folder here (e.g. sounds/themes/mine/) and put
any of the files listed above inside it. It will appear in the Sounds
preferences dropdown automatically.
