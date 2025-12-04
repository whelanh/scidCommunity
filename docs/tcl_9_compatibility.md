# Tcl/Tk 9.0 Compatibility

This document describes the changes made to ScidCommunity to support both Tcl/Tk 8.6 and 9.0, enabling forward compatibility as Tcl 9.0 becomes more widely adopted.

## Overview

ScidCommunity now builds and runs on both Tcl/Tk 8.6 and 9.0 without modification. The compatibility layer handles API differences transparently, allowing developers and users to work with either version.

## Key Incompatibilities Between Tcl 8.6 and 9.0

### 1. **Tcl_Size Type Introduction**

**Issue**: Tcl 9.0 introduced `Tcl_Size` (typedef for `ptrdiff_t`) to replace `int` for size-related parameters in the C API. Functions like `Tcl_SplitList` now require `Tcl_Size*` instead of `int*`.

**Solution**: Added a compatibility typedef in `src/tkscid.cpp`:

```cpp
// Tcl 8.6/9.0 compatibility: Tcl_Size introduced in 9.0
#ifndef TCL_MAJOR_VERSION
#error "TCL_MAJOR_VERSION not defined"
#elif TCL_MAJOR_VERSION < 9
typedef int Tcl_Size;
#endif
```

This allows the code to use `Tcl_Size` uniformly:
- **Tcl 8.6**: `Tcl_Size` maps to `int` (matches old API)
- **Tcl 9.0**: `Tcl_Size` is the native type (`ptrdiff_t`)

**Files Modified**:
- `src/tkscid.cpp`: Changed `int largc` → `Tcl_Size largc` and `int pgnTextCount` → `Tcl_Size pgnTextCount`

### 2. **Combined Tcl/Tk Library**

**Issue**: Tcl 9.0 merged Tcl and Tk into a single library (`libtcl9tk9.0.so`) on some platforms, whereas Tcl 8.6 uses separate libraries (`libtcl8.6.so` and `libtk8.6.so`).

**Solution**: Enhanced the `configure` script to detect both patterns:

```tcl
# Tcl 9.0+ uses combined libtcl9tk9.0.so
set tclv_major [lindex [split $tclv .] 0]
if {$tclv_major >= 9} {
    # Check for combined library
    set opt(tk_lib) [findDir "libtcl${tclv_major}tk${tclv}.*" $libraryPath]
    if {$opt(tk_lib) != ""} {
        set opt(tk_lib_file) "tcl${tclv_major}tk${tclv}"
    }
}

if {$opt(tk_lib) == ""} {
    # Fallback to separate libraries (Tcl 8.6 or if combined not found)
    set opt(tk_lib) [findDir "libtk${tclv}.*" $libraryPath]
    # ... existing logic
}
```

The configure script now:
- Checks for combined library only when major version ≥ 9
- Falls back to separate library detection for Tcl 8.6
- Generates appropriate linker flags: `-ltcl9tk9.0` (9.0) or `-ltcl8.6 -ltk8.6` (8.6)

**Files Modified**:
- `configure`: Added version-aware library detection

### 3. **trace variable Command Deprecated**

**Issue**: Tcl 9.0 removed support for `trace variable` and `trace vdelete`, replacing them with `trace add variable` and `trace remove variable`. The old commands also used single-letter operation codes (`w`, `r`, `u`) instead of full names (`write`, `read`, `unset`).

**Solution**: Created a compatibility wrapper in `tcl/start.tcl` that intercepts trace commands in Tcl 9.0:

```tcl
# Tcl 8.6/9.0 compatibility: trace variable -> trace add variable
if {[package vcompare [info patchlevel] 9.0] >= 0} {
    rename trace _trace_orig
    proc trace {op args} {
        if {$op eq "variable"} {
            # Map old single-letter ops to new full names
            set varName [lindex $args 0]
            set opsList [lindex $args 1]
            set command [lindex $args 2]
            set newOps ""
            foreach char [split $opsList ""] {
                switch $char {
                    w { append newOps "write " }
                    r { append newOps "read " }
                    u { append newOps "unset " }
                }
            }
            return [_trace_orig add variable $varName [string trim $newOps] $command]
        } elseif {$op eq "vdelete"} {
            # Similar mapping for vdelete -> remove
            # ... (code omitted for brevity)
        } else {
            return [_trace_orig $op {*}$args]
        }
    }
}
```

This wrapper:
- Detects Tcl 9.0+ via version check
- Renames the native `trace` command to `_trace_orig`
- Provides a new `trace` proc that converts old syntax to new
- Maps `w` → `write`, `r` → `read`, `u` → `unset`
- Leaves all 57 existing `trace variable` calls unchanged

**Files Modified**:
- `tcl/start.tcl`: Added trace compatibility wrapper

### 4. **Package Require Tk Version**

**Issue**: Hardcoded `package require Tk 8.6` fails when only Tk 9.0 is installed.

**Solution**: Added fallback logic in `tcl/start.tcl`:

```tcl
# Support both Tcl/Tk 8.6 and 9.0+
if {[catch {package require Tk 8.6}]} {
    package require Tk 9.0
}
```

This tries 8.6 first (for compatibility with existing systems), then falls back to 9.0 if 8.6 isn't available.

**Files Modified**:
- `tcl/start.tcl`: Added version fallback logic

## Building for Different Versions

### Building with Tcl/Tk 8.6

```bash
./configure
make clean
make
```

The configure script automatically detects Tcl 8.6 and configures for separate libraries.

### Building with Tcl/Tk 9.0

```bash
tclsh9.0 configure TCL_VERSION=9.0
make clean
make
```

Explicitly run configure with `tclsh9.0` to ensure version 9.0 is detected. The script will find the combined library and set appropriate flags.

### Verifying Your Build

After building, check the generated `Makefile` for the correct library flags:

```bash
grep TCL_LIBRARY Makefile
```

Expected output:
- **Tcl 8.6**: `TCL_LIBRARY = -L/usr/lib64 -ltcl8.6 -ltk8.6`
- **Tcl 9.0**: `TCL_LIBRARY = -L/usr/lib64 -ltcl9tk9.0`

## Testing

Test the application in both environments to ensure full compatibility:

1. **Compile Test**: Build successfully with both Tcl 8.6 and 9.0
2. **Runtime Test**: Launch the application and verify:
   - UI renders correctly
   - Trace validations work (edit fields, search dialogs)
   - No console errors about deprecated commands
3. **Feature Test**: Exercise major features (database operations, searches, analysis)

## Summary of Changes

| File | Change | Purpose |
|------|--------|---------|
| `src/tkscid.cpp` | Added `Tcl_Size` typedef | C API compatibility |
| `src/tkscid.cpp` | Changed variable types to `Tcl_Size` | Match new API signatures |
| `configure` | Added combined library detection | Handle merged Tcl/Tk library |
| `configure` | Version-gated library search | Prevent wrong library detection |
| `tcl/start.tcl` | Added trace compatibility wrapper | Support deprecated commands |
| `tcl/start.tcl` | Added version fallback for Tk | Load correct Tk version |

## Future Considerations

As Tcl 9.x evolves:
- Monitor for additional API changes in future 9.x releases
- Consider eventually requiring 9.0+ and removing compatibility shims
- Update documentation when upstream Tcl/Tk distributions standardize on 9.0
- Test on multiple platforms (Linux distributions, macOS, Windows) as 9.0 adoption varies

## Resources

- [Tcl/Tk 9.0 Release Notes](https://www.tcl-lang.org/software/tcltk/9.0.html)
- [Tcl 9.0 Migration Guide](https://www.tcl-lang.org/man/tcl9.0/TclCmd/library.html)
- [TIP 494: Tcl_Size Type](https://core.tcl-lang.org/tips/doc/trunk/tip/494.md)

---

**Last Updated**: December 4, 2025  
**Tested With**: Tcl/Tk 8.6.14, Tcl/Tk 9.0.2 (Fedora Rawhide)
