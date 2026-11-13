###
### uci.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
###
######################################################################
### The old home of the UCI formatting helpers
###
### FROZEN (2026-11-11). This file is being retired by issue #437. What is left
### is the three one-line ::ucifmt:: wrappers: §5 deleted the rest with the
### Analysis window that was their only user - startEngine/sendToEngine/
### closeUCIengine, the pipe reader, the engine-options dialog and the analysis
### array behind them. The UCI parser is NOT here; it lives in enginecomm.tcl
### and stays. Do not add a caller: §6 repoints the remaining callers at
### ::ucifmt:: and deletes this file.
### Inventory and the per-symbol decision table: docs/analysis-engine-inventory.md

namespace eval uci {
    ################################################################################
    # UCI moves use long notation
    # returns 1 if an error occurred when entering a move
    # The implementation lives in tcl/tools/uci_format.tcl (::ucifmt::): #437 §4
    # needed it without this file, and §6 deletes this mode. The wrapper keeps
    # every caller inside ::uci working until then.
    ################################################################################
    proc sc_move_add { moves } {
        return [::ucifmt::sc_move_add $moves]
    }
    ################################################################################
    #make UCI output more readable (b1c3 -> Nc3)
    ################################################################################
    proc formatPv { moves { fen "" } } {
        return [::ucifmt::formatPv $moves $fen]
    }
    ################################################################################
    #   Format a line starting at current position where <moves> were played (in San notation)
    ################################################################################
    proc formatPvAfterMoves { played_moves moves } {
        return [::ucifmt::formatPvAfterMoves $played_moves $moves]
    }
}
###
### End of file: uci.tcl
###
