# Changelog (fork mrsw/Soft4You)

This fork tracks its own patches on top of upstream (mauriziodm/iORM) via a
build-metadata suffix on `IORM_VERSION` (`Source/iORM.pas`), e.g.
`iORM 2 (beta 3.4)+mrsw.29`:

- The base part (`iORM 2 (beta 3.4)`) is upstream's own version string,
  updated only when merging from the `iORM-Upstream` remote tracking branch.
- The `+mrsw.N` suffix counts fork-local changes merged into `development`
  since the last upstream sync point, one per merged branch (or direct
  commit on `development`), bumped as part of the merge itself.
- `N` resets to 1 the next time an upstream merge updates the base version.

Only fork-local changes are listed here; upstream's own history stays in
`git log` (author `Maurizio Del Magno`) and is not duplicated.

## +mrsw.29 (2026-09-23)

- Fix `TioScript` silently ignoring failed statements in a script:
  `TFDScript.ScriptOptions.BreakOnError` defaults to `False`, so a failing
  DDL statement (e.g. an invalid `CREATE INDEX`) was skipped instead of
  aborting the script, and the transaction was committed as if everything
  had succeeded. `TioScript.Create` now sets `BreakOnError := True`, and
  `TioScript.Execute` additionally checks `TotalErrors` after
  `ExecuteScript` as a defense-in-depth safeguard.
  (branch `fix_TioScript_Silently_Ignores_Failed_Statements`)
