#!/bin/sh
# Compile every CQL translation unit that the application builds and fail if
# any of them produces a warning.
#
# Every .cpp in this directory is part of the application build and is compiled
# below. A future import that reintroduces an old idiom shows up here instead of
# being silenced in the build files.
#
#   src/cql/scripts/check-warnings.sh
#
set -u

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cql=$(CDPATH= cd -- "$here/.." && pwd)
src=$(CDPATH= cd -- "$cql/.." && pwd)

CXX=${CXX:-g++}
CXXFLAGS=${CXXFLAGS:--std=c++20 -Wall -Wextra -Wno-deprecated-declarations}
# -frtti: the engine dispatches on dynamic_cast<>() throughout.
CQLFLAGS="-DINTEGRATED -frtti -I$src -I$src/external -I$cql"

warnings=$(mktemp)
trap 'rm -f "$warnings"' EXIT

for file in "$cql"/*.cpp; do
    # shellcheck disable=SC2086
    $CXX $CXXFLAGS -fsyntax-only $CQLFLAGS "$file" 2>&1 |
        grep -E "^$cql/.*(warning|error):" >>"$warnings"
done

if [ -s "$warnings" ]; then
    sort -u "$warnings" >&2
    echo "CQL: warnings above; the engine must compile warning-free." >&2
    exit 1
fi
echo "CQL: all translation units compile without warnings."
