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

## +mrsw.30 (2026-10-02)

- Fix random access violation when an edit view is closed after the list
  view it was opened from: model presenters and natural adapters kept
  non-owning interface references to components destroyed first.
  `TioModelPresenterCustom` registers for the free notification of
  `MasterBindSource`, `SelectorFor` and `ETMfor` (and
  `TioModelPresenterMaster` of `WhereBuilderFor`) and resets the property
  when they are destroyed; the natural adapters (object and interface) do
  the same with their source adapter; `TioModelPresenterCustom.Destroy` no
  longer leaves `FBindSourceAdapter` assigned after freeing it. Adds
  `EioMasterBindSourceRecursionException` (a presenter cannot be its own
  `MasterBindSource`). The same pattern is NOT yet applied to the DataSet and
  PrototypeBindSource families nor to the other references listed in
  `Docs/Dangling-References-When-A-Source-Is-Destroyed-First.md`.
  (branches `fix_Natural_Adapter_Source_Free_Notification` and
  `fea_Manage_Free_Notification_Model_Presenter_Custom`)

## +mrsw.29 (2026-09-23)

- Fix `TioScript` silently ignoring failed statements in a script:
  `TFDScript.ScriptOptions.BreakOnError` defaults to `False`, so a failing
  DDL statement (e.g. an invalid `CREATE INDEX`) was skipped instead of
  aborting the script, and the transaction was committed as if everything
  had succeeded. `TioScript.Create` now sets `BreakOnError := True`, and
  `TioScript.Execute` additionally checks `TotalErrors` after
  `ExecuteScript` as a defense-in-depth safeguard.
  (branch `fix_TioScript_Silently_Ignores_Failed_Statements`)
