# CQL Engine Import

This directory contains the CQL (Chess Query Language) engine imported from scidvspc.

## Provenance
- **Upstream URL:** [https://sourceforge.net/projects/scidvspc/](https://sourceforge.net/projects/scidvspc/)
- **VCS Path:** `svn://svn.code.sf.net/p/scidvspc/code`
- **Imported Revision:** `cb5309c24e17fd7f1ce8d800714c73544a88101e`
- **Import Date:** 2026-10-26
- **Local Mirror Used:** `/home/david/.hermes/cache/scratch/scidvspc/src/cql`

## Project Structure
The majority of the files in this directory are verbatim imports from the scidvspc project.

**Note:** The following files are **scidCommunity's own code** and are not part of the upstream import:
- `src/cql/cql_pgnparse_adapter.h`
- `src/cql/cql_pgnparse_adapter.cpp`

These adapters provide the necessary interface between the scidCommunity core and the imported CQL engine.

## Re-syncing Upstream
To re-sync this engine with upstream changes:
1. Export the current state of the imported files (excluding `cql_pgnparse_adapter.*`).
2. Fetch the latest revision from the upstream VCS path.
3. Replace the imported files with the new versions.
4. Re-apply any local compile fixes required for integration.
5. Verify the build and run the test suite.
