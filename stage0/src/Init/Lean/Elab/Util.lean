/-
Copyright (c) 2019 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import Init.Lean.Util.Trace
import Init.Lean.Parser

namespace Lean
namespace Elab

def checkSyntaxNodeKind (env : Environment) (k : Name) : ExceptT String Id Name :=
if Parser.isValidSyntaxNodeKind env k then pure k
else throw "failed"

def checkSyntaxNodeKindAtNamespaces (env : Environment) (k : Name) : List Name → ExceptT String Id Name
| []    => throw "failed"
| n::ns => checkSyntaxNodeKind env (n ++ k) <|> checkSyntaxNodeKindAtNamespaces ns

def syntaxNodeKindOfAttrParam (env : Environment) (parserNamespace : Name) (arg : Syntax) : ExceptT String Id SyntaxNodeKind :=
match attrParamSyntaxToIdentifier arg with
| some k =>
  checkSyntaxNodeKind env k
  <|>
  checkSyntaxNodeKindAtNamespaces env k env.getNamespaces
  <|>
  checkSyntaxNodeKind env (parserNamespace ++ k)
  <|>
  throw ("invalid syntax node kind '" ++ toString k ++ "'")
| none   => throw ("syntax node kind is missing")

structure ElabAttributeEntry :=
(kind     : SyntaxNodeKind)
(declName : Name)

structure ElabAttribute (σ : Type) :=
(attr : AttributeImpl)
(ext  : PersistentEnvExtension ElabAttributeEntry ElabAttributeEntry σ)
(kind : String)

instance ElabAttribute.inhabited {σ} [Inhabited σ] : Inhabited (ElabAttribute σ) := ⟨{ attr := arbitrary _, ext := arbitrary _, kind := "" }⟩

/-
This is just the basic skeleton for attributes such as `[termElab]` and `[commandElab]` attributes, and associated environment extensions.
The state is initialized using `builtinTable`.

The current implementation just uses the bultin elaborators.
-/
def mkElabAttribute {σ} [Inhabited σ] (attrName : Name) (kind : String) (builtinTable : IO.Ref σ) : IO (ElabAttribute σ) := do
ext : PersistentEnvExtension ElabAttributeEntry ElabAttributeEntry σ ← registerPersistentEnvExtension {
  name            := attrName,
  mkInitial       := pure (arbitrary _),
  addImportedFn   := fun env es => do
    table ← builtinTable.get;
    -- TODO: populate table with `es`
    pure table,
  addEntryFn      := fun (s : σ) _ => s,                            -- TODO
  exportEntriesFn := fun _ => #[],                                  -- TODO
  statsFn         := fun _ => fmt (kind ++ " elaborator attribute") -- TODO
};
let attrImpl : AttributeImpl := {
  name  := attrName,
  descr := kind ++ " elaborator",
  add   := fun env decl args persistent => pure env -- TODO
};
pure { ext := ext, attr := attrImpl, kind := kind }

@[init] private def regTraceClasses : IO Unit := do
registerTraceClass `Elab;
registerTraceClass `Elab.step

end Elab
end Lean
