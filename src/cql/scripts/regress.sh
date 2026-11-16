#!/bin/bash
#
# Given a collection of CQL syntax files, run the two standalone cql apps
# with each of those files against a common PDN DB and redirect the output
# to their respective log files.
#
# Run diff against the log files to verify that the two standalone execs
# flag the same games.

EXECS="cql pcql"
EXAMPLES=../examples/*.cql
#EXAMPLES=$HOME/git-svn/scidvspc-code/src/cql/examples/*stalemate*.cql
PGN_IN=$HOME/tmp/cql_test.pgn
OUT_DIR=/tmp/cql

rm -rf $OUT_DIR
mkdir -p $OUT_DIR

for exec in $EXECS ; do 
  LOG=$OUT_DIR/$exec.log
  for script in $EXAMPLES ; do
    PGN_OUT=$OUT_DIR/out_${exec}_$(basename $script cql)pgn
    echo $exec -i $PGN_IN -o $PGN_OUT $script 
    $exec -i $PGN_IN -o $PGN_OUT $script  >>  $LOG
  done
done

diff ${OUT_DIR}/*.log | grep CQL:

exit 0

