# Dangling references when a source presenter/adapter is destroyed first

Reference note for the original iORM author. It describes a random access
violation found in the fork, its root cause, how it was diagnosed and how it
was fixed. It is application-agnostic: the scenario is a list view and an
edit view of one of its objects, nothing more.

Fork reference: branch `fix_Natural_Adapter_Source_Free_Notification`
(includes `fea_Manage_Free_Notification_Model_Presenter_Custom`).


## 1. Summary

An edit view opened for an object selected in a list view keeps interface
references to the list's model presenter and bind source adapter. These
objects are `TComponent` descendants **without reference counting** and they
are **not owned** by the edit presenter. If the list view is closed (and its
presenter destroyed) before the edit view, the edit presenter is left with
dangling references. Nothing happens at that moment: the crash comes later,
when the edit view is closed and the references are used or released.

The access violation is random, because it depends on what the memory
manager did with the freed memory in the meantime. It is therefore easy to
miss in testing and easy to mistake for a generic memory problem.


## 2. Symptom

- Access violation (`$C0000005`) when an edit view is closed.
- It happens only if the list view that the edit view was opened from has
  been closed **before** the edit view. Closing in the opposite order (the
  normal, stacked order) never fails.
- Closing the list view and then immediately closing the edit view often does
  NOT fail. Waiting a while, or switching to other views before closing the
  edit view, makes it fail. It may also depend on actions performed in
  between.
- Typical call stack of the final form of the problem (the top frame is in
  the RTL, called directly from the presenter destructor):

```
System._IntfClear
iORM.MVVM.ModelPresenter.Custom.TioModelPresenterCustom.Destroy
iORM.MVVM.ModelPresenter.Master.TioModelPresenterMaster.Destroy
System.TObject.Free
System.Classes.TComponent.DestroyComponents
System.Classes.TComponent.Destroy
System.Classes.TDataModule.Destroy
... (view model destruction) ...
```

  Before the fixes, intermediate variants of the same problem showed the
  access violation inside
  `TioNaturalActiveInterfaceObjectBindSourceAdapter.Destroy` or inside
  `System.TObject.CleanupInstance` -> `System._FinalizeRecord` ->
  `System._IntfClear` (the compiler generated cleanup of the interface
  fields of the presenter).


## 3. Reproduction (generic)

1. Open a list view backed by a master model presenter.
2. Open the edit view of one object of the list. The edit presenter gets a
   natural bind source adapter built from the list (see
   `TioModelPresenterCustom._CreateAdapter`, the branch that calls
   `GetNaturalBSAfromMasterBindSource` when `MasterBindSource` is assigned).
3. Close the list view. Its presenter and adapter are destroyed.
4. Wait a while / switch to other views, then come back and close the edit
   view.
5. Access violation (not on every attempt: repeat a few times).


## 4. Root cause

Three kinds of references from the edit side to the list side were left
dangling when the list side was destroyed:

1. `TioModelPresenterCustom.FMasterBindSource` (and, by the same mechanism,
   `FSelectorFor`, `FETMfor` and `TioModelPresenterMaster.FWhereBuilderFor`):
   interface references to other presenters. In the scenario above
   `FMasterBindSource` is the list's presenter. In the destructor and in the
   compiler generated cleanup of the instance the field is cleared with
   `_IntfClear`, which calls `_Release` through the interface table of an
   object that no longer exists.

2. `TioNaturalActive*ObjectBindSourceAdapter.FSourceAdapter`: the natural
   adapter keeps a reference to the adapter it was built from (the list's
   adapter). Its destructor reads `FSourceAdapter.DetailAdaptersContainer`
   and the automatic finalization of the interface field calls `_Release`,
   both on a destroyed object.

3. `TioModelPresenterCustom.FBindSourceAdapter` after `.Free`: the destructor
   frees the adapter through the interface (`FBindSourceAdapter.Free`) but
   leaves the interface field assigned, so the compiler generated cleanup
   later calls `_Release` on freed memory. This one is a defensive fix: it
   is a real dangling use, but it was not proven to be, by itself, the cause
   of the reported access violation.

Why it is random: `_Release` of these components does nothing useful (no
reference counting), but it still has to read the interface table stored in
the object. If the freed block has not been reused, the read works and
nothing fails. If the memory manager reused or merged the block, the table
is garbage and the call crashes. This depends on the heap state, hence the
dependence on waiting, on other views being opened, and so on.

How the three were told apart: the first fix (item 2) moved the crash from
`TioNaturalActive...Destroy` to the compiler generated cleanup; the second
(item 3) did not change the stack; stepping the interface fields one by one
in the destructor (assigning `nil` to each, temporarily) pointed to
`FMasterBindSource` as the failing one (the debugger highlights the line after
the failing statement). With the free notification on
`MasterBindSource` the access violation no longer occurred in repeated runs.


## 5. Fix

All the changes follow the same pattern: whoever holds a non-owning
reference to a component registers for its free notification and forgets the
reference when the component is destroyed.

### 5.1 `TioModelPresenterCustom` / `TioModelPresenterMaster` (branch `fea_Manage_Free_Notification_Model_Presenter_Custom`)

- `Notification` override: when the component referenced by
  `FMasterBindSource`, `FETMfor` or `FSelectorFor` (Custom), or by
  `FWhereBuilderFor` (Master), is destroyed, the property is set to `nil`.
  (The `FSelectorFor` branch of `TioModelPresenterCustom.Notification` was
  added afterwards: the original branch registered the notification in
  `SetSelectorFor` but never reset the field.)
- The setters (`SetMasterBindSource`, `SetETMfor`, `SetSelectorFor`,
  `SetWhereBuilderFor`) remove the free notification of the previous value
  and register the new one.
- New exception class `EioMasterBindSourceRecursionException`: a presenter
  cannot be its own `MasterBindSource`.

### 5.2 Natural adapters (object and interface variants)

```pascal
// constructor, after FSourceAdapter := ASourceAdapter
(FSourceAdapter as TComponent).FreeNotification(Self);

procedure TioNaturalActive...Adapter.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  // The source adapter (usually the one of a list) is not owned by this
  // adapter and can be destroyed before it.
  if (Operation = opRemove) and Assigned(FSourceAdapter) and
    (AComponent = (FSourceAdapter as TComponent)) then
    FSourceAdapter := nil;
end;

// destructor, after RemoveNaturalBindSourceAdapter
if Assigned(FSourceAdapter) then
  (FSourceAdapter as TComponent).RemoveFreeNotification(Self);
```

All the existing code of the natural adapters already tests
`Assigned(FSourceAdapter)`, so an adapter without source simply behaves like
one that never had it.

### 5.3 `TioModelPresenterCustom.Destroy`

```pascal
if CheckAdapter then
begin
  if not (csDestroying in TComponent(FBindSourceAdapter).ComponentState) then
    FBindSourceAdapter.Free;
  // The adapter is (being) destroyed: forget the interface without releasing
  // it, otherwise the compiler generated cleanup would call _Release on a
  // freed object.
  Pointer(FBindSourceAdapter) := nil;
end;
```

Assigning `nil` to the interface variable would call `_Release` on the freed
object; casting to `Pointer` avoids it. It is safe because these adapters do
not reference count.


## 6. Verification

- The scenario of section 3 was repeated in the reporting application after
  all the changes above: no access violation.
- Closing the views in the normal order was not affected.
- The first two changes alone (5.2 and 5.3) were not enough: the access
  violation was still reproducible until the free notification of
  `MasterBindSource` (5.1) was added.
- No automated test exists for this case. A test would need to create a
  list presenter and an edit presenter linked through `MasterBindSource`,
  destroy the list presenter, then destroy the edit presenter, ideally with
  a memory manager that fills freed blocks so that the failure is not random.


## 7. Known gaps and open questions

Only the model presenter family (`TioModelPresenterCustom` /
`TioModelPresenterMaster`) and the natural adapters are covered. A survey of
the interface fields that point to components not owned by the holder found
the following, NOT changed and NOT proven to be a problem in practice:

A) The same four fields, in sibling classes that were not touched:
   `iORM.DB.DataSet.Custom` / `iORM.DB.DataSet.Master` and
   `iORM.LiveBindings.PrototypeBindSource.Custom` / `.Master`
   (`FMasterBindSource`, `FETMfor`, `FSelectorFor`, `FWhereBuilderFor`).
   The pattern of section 5.1 applies unchanged.

B) References whose lifetime relation needs an analysis first, because the
   holder normally lives inside the same tree as the target and the real
   risk depends on the destruction order:
   - `FBindSourceAdapter` in `iORM.MVVM.ModelBindSource`,
     `iORM.DB.DataSet.Base` and `iORM.LiveBindings.PrototypeBindSource.Custom`;
   - `FBindSource` in the four active bind source adapters (object/list,
     with and without interfaces);
   - `FTargetBindSource` in `iORM.MVVM.VMAction`, `iORM.StdActions.Fmx` and
     `iORM.StdActions.Vcl`;
   - `TioWhere.FETMfor`, and `FMasterAdapter` / `FMasterAdaptersContainer`
     in the detail adapters container (the collections of registered
     detail/natural adapters are a dictionary and a `TList` of interfaces).

Other open questions:

- The destructor of `TioModelPresenterCustom` frees `FBindSourceAdapter` only
  if it is not already being destroyed. Which of the two owners (presenter
  or the component that owns the adapter) should free it is not documented;
  the change in 5.3 only makes both cases safe.
- Interfaces on `TComponent` descendants without reference counting are
  convenient but they make this kind of problem easy to introduce. A weak
  reference helper, or a single place that wraps "non-owning reference to a
  component with free notification", might be worth considering.


## 8. Files

- `Source/iORM.MVVM.ModelPresenter.Custom.pas`
- `Source/iORM.MVVM.ModelPresenter.Master.pas`
- `Source/iORM.Exceptions.pas`
- `Source/iORM.LiveBindings.NaturalActiveInterfaceObjectBindSourceAdapter.pas`
- `Source/iORM.LiveBindings.NaturalActiveObjectBindSourceAdapter.pas`
