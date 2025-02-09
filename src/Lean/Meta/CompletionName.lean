/-
Copyright (c) 2023 Lean FRO, LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import Lean.Meta.Basic
import Lean.Meta.Match.MatcherInfo

/-!
This exports a predicate for checking whether a name should be made
visible in auto-completion and other tactics that suggest names to
insert into Lean code.

The `exact?` tactic is an example of a tactic that benefits from this
functionality.  `exact?` finds lemmas in the environment to use to
prove a theorem, but it needs to avoid inserting references to theorems
with unstable names such as auxillary lemmas that could change with
minor unintentional modifications to definitions.

It uses a blacklist environment extension to enable names in an
environment to be specifically hidden.
-/
namespace Lean.Meta

builtin_initialize completionBlackListExt : TagDeclarationExtension ← mkTagDeclarationExtension

@[export lean_completion_add_to_black_list]
def addToCompletionBlackList (env : Environment) (declName : Name) : Environment :=
  completionBlackListExt.tag env declName

/--
Return true if name is blacklisted for completion purposes.
-/
private def isBlacklisted (env : Environment) (declName : Name) : Bool :=
  declName.isInternal && !isPrivateName declName
  || isAuxRecursor env declName
  || isNoConfusion env declName
  || isRecCore env declName
  || completionBlackListExt.isTagged env declName
  || isMatcherCore env declName

/--
Return true if completion is allowed for name.
-/
def allowCompletion (env : Environment) (declName : Name) : Bool :=
  !(isBlacklisted env declName)

end Lean.Meta
