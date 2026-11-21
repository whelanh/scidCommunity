#!/usr/bin/env bash
#
# Fail if an ELF file under the given paths needs a CPU newer than plain
# x86-64, the baseline every x86-64 machine supports.
#
# Why this exists: Ubuntu 26.04 builds its archive for the amd64v3 variant, so
# its gcc defaults to -march=x86-64-v3.  A binary built that way carries
# "x86 ISA needed: x86-64-baseline, x86-64-v2, x86-64-v3" in
# .note.gnu.property, and the dynamic loader refuses to start it on anything
# older than Haswell:
#
#     CPU ISA level is lower than required
#
# That is what broke the 5.1.4.70 and later downloads on an Ivy Bridge
# ThinkPad X230 (issue #530).  The release workflows build on ubuntu-24.04 and
# run this script over the finished package, so the same regression fails the
# build instead of reaching users.
#
# Usage: scripts/check-x86-64-baseline.sh PATH...
#
set -euo pipefail

if [ "$#" -eq 0 ]; then
    echo "usage: $0 PATH..." >&2
    exit 2
fi

# AVX2/BMI1/BMI2 instructions: the x86-64-v3 features a v2 CPU lacks.  AVX1
# permutes such as vpermilpd are deliberately not listed, because Ivy Bridge
# and earlier have AVX1.
V3_INSTRUCTIONS='vpbroadcast[a-z]*|vpternlog[a-z]*|vpermq|vpermd|vpermps|vpermpd|vinserti128|vperm2i128|andn|bzhi|shlx|shrx|pdep|pext'

for tool in readelf objdump od; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "::error::$tool is required but not installed"
        exit 1
    fi
done

status=0

check_file() {
    local f=$1 magic isa v3_count

    # Skip anything that is not an ELF file: the packages are mostly Tcl,
    # bitmaps, help pages and shell wrappers.
    magic=$(od -An -tx1 -N4 "$f" | tr -d ' \n')
    [ "$magic" = 7f454c46 ] || return 0

    isa=$(readelf -n "$f" 2>/dev/null | sed -n 's/.*x86 ISA needed: //p')
    case "$isa" in
        *x86-64-v2* | *x86-64-v3*)
            echo "::error file=$f::$f requires $isa; it will not start on pre-Haswell CPUs"
            status=1
            return 0
            ;;
    esac

    # The note is what the loader checks, but not every toolchain emits it,
    # so look at the code as well.  The pattern is anchored to the mnemonic
    # field (after "address:") so that symbol names in operand text cannot
    # match, and grep -c (not -q) keeps objdump from dying of SIGPIPE, which
    # pipefail would turn into a false pass.
    v3_count=$(objdump -d --no-show-raw-insn "$f" 2>/dev/null \
        | grep -cE ":[[:space:]]+($V3_INSTRUCTIONS)([[:space:]]|$)" || true)
    if [ "${v3_count:-0}" -gt 0 ]; then
        echo "::error file=$f::$f contains x86-64-v3 instructions (AVX2/BMI) without declaring them"
        status=1
    fi
}

for path in "$@"; do
    if [ -d "$path" ]; then
        while IFS= read -r -d '' f; do
            check_file "$f"
        done < <(find "$path" -type f -print0)
    elif [ -f "$path" ]; then
        check_file "$path"
    else
        echo "::error::no such file or directory: $path"
        status=1
    fi
done

if [ "$status" -ne 0 ]; then
    echo "Refusing to publish binaries that need x86-64-v2/v3 (see issue #530)."
fi
exit "$status"
