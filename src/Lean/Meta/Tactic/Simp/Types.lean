/-
Copyright (c) 2020 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import Lean.Meta.AppBuilder
import Lean.Meta.CongrTheorems
import Lean.Meta.Tactic.Replace
import Lean.Meta.Tactic.Simp.SimpTheorems
import Lean.Meta.Tactic.Simp.SimpCongrTheorems

namespace Lean.Meta
namespace Simp

/-- The result of simplifying some expression `e`. -/
structure Result where
  /-- The simplified version of `e` -/
  expr           : Expr
  /-- A proof that `$e = $expr`, where the simplified expression is on the RHS.
  If `none`, the proof is assumed to be `refl`. -/
  proof?         : Option Expr := none
  /-- Save the field `dischargeDepth` at `Simp.Context` because it impacts the simplifier result. -/
  dischargeDepth : UInt32 := 0
  /-- If `cache := true` the result is cached. -/
  cache          : Bool := true
  deriving Inhabited

def mkEqTransOptProofResult (h? : Option Expr) (cache : Bool) (r : Result) : MetaM Result :=
  match h?, cache with
  | none, true  => return r
  | none, false => return { r with cache := false }
  | some p₁, cache => match r.proof? with
    | none    => return { r with proof? := some p₁, cache := cache && r.cache }
    | some p₂ => return { r with proof? := (← Meta.mkEqTrans p₁ p₂), cache := cache && r.cache }

def Result.mkEqTrans (r₁ r₂ : Result) : MetaM Result :=
  mkEqTransOptProofResult r₁.proof? r₁.cache r₂

/-- Flip the proof in a `Simp.Result`. -/
def Result.mkEqSymm (e : Expr) (r : Simp.Result) : MetaM Simp.Result :=
  ({ expr := e, proof? := · }) <$>
  match r.proof? with
  | none => pure none
  | some p => some <$> Meta.mkEqSymm p

abbrev Cache := ExprMap Result

abbrev CongrCache := ExprMap (Option CongrTheorem)

structure Context where
  config           : Config := {}
  /-- `maxDischargeDepth` from `config` as an `UInt32`. -/
  maxDischargeDepth : UInt32 := UInt32.ofNatTruncate config.maxDischargeDepth
  simpTheorems      : SimpTheoremsArray := {}
  congrTheorems     : SimpCongrTheorems := {}
  /--
  Stores the "parent" term for the term being simplified.
  If a simplification procedure result depends on this value,
  then it is its reponsability to set `Result.cache := false`.

  Motivation for this field:
  Suppose we have a simplication procedure for normalizing arithmetic terms.
  Then, given a term such as `t_1 + ... + t_n`, we don't want to apply the procedure
  to every subterm `t_1 + ... + t_i` for `i < n` for performance issues. The procedure
  can accomplish this by checking whether the parent term is also an arithmetical expression
  and do nothing if it is. However, it should set `Result.cache := false` to ensure
  we don't miss simplification opportunities. For example, consider the following:
  ```
  example (x y : Nat) (h : y = 0) : id ((x + x) + y) = id (x + x) := by
    simp_arith only
    ...
  ```
  If we don't set `Result.cache := false` for the first `x + x`, then we get
  the resulting state:
  ```
  ... |- id (2*x + y) = id (x + x)
  ```
  instead of
  ```
  ... |- id (2*x + y) = id (2*x)
  ```
  as expected.

  Remark: given an application `f a b c` the "parent" term for `f`, `a`, `b`, and `c`
  is `f a b c`.
  -/
  parent?           : Option Expr := none
  dischargeDepth    : UInt32 := 0
  deriving Inhabited

def Context.isDeclToUnfold (ctx : Context) (declName : Name) : Bool :=
  ctx.simpTheorems.isDeclToUnfold declName

def Context.mkDefault : MetaM Context :=
  return { config := {}, simpTheorems := #[(← getSimpTheorems)], congrTheorems := (← getSimpCongrTheorems) }

abbrev UsedSimps := HashMap Origin Nat

structure State where
  cache        : Cache := {}
  congrCache   : CongrCache := {}
  usedTheorems : UsedSimps := {}
  numSteps     : Nat := 0

private opaque MethodsRefPointed : NonemptyType.{0}

private def MethodsRef : Type := MethodsRefPointed.type

instance : Nonempty MethodsRef := MethodsRefPointed.property

abbrev SimpM := ReaderT MethodsRef $ ReaderT Context $ StateRefT State MetaM

@[extern "lean_simp"]
opaque simp (e : Expr) : SimpM Result

@[extern "lean_dsimp"]
opaque dsimp (e : Expr) : SimpM Expr

/--
Result type for a simplification procedure. We have `pre` and `post` simplication procedures.
-/
inductive Step where
  /--
  For `pre` procedures, it returns the result without visiting any subexpressions.

  For `post` procedures, it returns the result.
  -/
  | done (r : Result)
  /--
  For `pre` procedures, the resulting expression is passed to `pre` again.

  For `post` procedures, the resulting expression is passed to `pre` again IF
  `Simp.Config.singlePass := false` and resulting expression is not equal to initial expression.
  -/
  | visit (e : Result)
  /--
  For `pre` procedures, continue transformation by visiting subexpressions, and then
  executing `post` procedures.

  For `post` procedures, this is equivalent to returning `visit`.
  -/
  | continue (e? : Option Result := none)
  deriving Inhabited

/--
A simplification procedure. Recall that we have `pre` and `post` procedures.
See `Step`.
-/
abbrev Simproc := Expr → SimpM Step

def mkEqTransResultStep (r : Result) (s : Step) : MetaM Step :=
  match s with
  | .done r'            => return .done (← mkEqTransOptProofResult r.proof? r.cache r')
  | .visit r'           => return .visit (← mkEqTransOptProofResult r.proof? r.cache r')
  | .continue none      => return .continue r
  | .continue (some r') => return .continue (some (← mkEqTransOptProofResult r.proof? r.cache r'))

/--
"Compose" the two given simplification procedures. We use the following semantics.
- If `f` produces `done` or `visit`, then return `f`'s result.
- If `f` produces `continue`, then apply `g` to new expression returned by `f`.

See `Simp.Step` type.
-/
@[always_inline]
def andThen (f g : Simproc) : Simproc := fun e => do
  match (← f e) with
  | .done r            => return .done r
  | .continue none     => g e
  | .continue (some r) => mkEqTransResultStep r (← g r.expr)
  | .visit r           => return .visit r

instance : AndThen Simproc where
  andThen s₁ s₂ := andThen s₁ (s₂ ())

/--
`Simproc` .olean entry.
-/
structure SimprocOLeanEntry where
  /-- Name of a declaration stored in the environment which has type `Simproc`. -/
  declName : Name
  post     : Bool := true
  keys     : Array SimpTheoremKey := #[]
  deriving Inhabited

/--
`Simproc` entry. It is the .olean entry plus the actual function.
-/
structure SimprocEntry extends SimprocOLeanEntry where
  /--
  Recall that we cannot store `Simproc` into .olean files because it is a closure.
  Given `SimprocOLeanEntry.declName`, we convert it into a `Simproc` by using the unsafe function `evalConstCheck`.
  -/
  proc : Simproc

abbrev SimprocTree := DiscrTree SimprocEntry

structure Simprocs where
  pre          : SimprocTree   := DiscrTree.empty
  post         : SimprocTree   := DiscrTree.empty
  simprocNames : PHashSet Name := {}
  erased       : PHashSet Name := {}
  deriving Inhabited

structure Methods where
  pre        : Simproc                    := fun _ => return .continue
  post       : Simproc                    := fun e => return .done { expr := e }
  discharge? : Expr → SimpM (Option Expr) := fun _ => return none
  deriving Inhabited

unsafe def Methods.toMethodsRefImpl (m : Methods) : MethodsRef :=
  unsafeCast m

@[implemented_by Methods.toMethodsRefImpl]
opaque Methods.toMethodsRef (m : Methods) : MethodsRef

unsafe def MethodsRef.toMethodsImpl (m : MethodsRef) : Methods :=
  unsafeCast m

@[implemented_by MethodsRef.toMethodsImpl]
opaque MethodsRef.toMethods (m : MethodsRef) : Methods

def getMethods : SimpM Methods :=
  return MethodsRef.toMethods (← read)

def pre (e : Expr) : SimpM Step := do
  (← getMethods).pre e

def post (e : Expr) : SimpM Step := do
  (← getMethods).post e

def discharge? (e : Expr) : SimpM (Option Expr) := do
  (← getMethods).discharge? e

@[inline] def getContext : SimpM Context :=
  readThe Context

def getConfig : SimpM Config :=
  return (← getContext).config

@[inline] def withParent (parent : Expr) (f : SimpM α) : SimpM α :=
  withTheReader Context (fun ctx => { ctx with parent? := parent }) f

def getSimpTheorems : SimpM SimpTheoremsArray :=
  return (← readThe Context).simpTheorems

def getSimpCongrTheorems : SimpM SimpCongrTheorems :=
  return (← readThe Context).congrTheorems

@[inline] def savingCache (x : SimpM α) : SimpM α := do
  let cacheSaved := (← get).cache
  modify fun s => { s with cache := {} }
  try x finally modify fun s => { s with cache := cacheSaved }

@[inline] def withSimpTheorems (s : SimpTheoremsArray) (x : SimpM α) : SimpM α := do
  savingCache <| withTheReader Context (fun ctx => { ctx with simpTheorems := s }) x

@[inline] def withDischarger (discharge? : Expr → SimpM (Option Expr)) (x : SimpM α) : SimpM α :=
  savingCache <| withReader (fun r => { MethodsRef.toMethods r with discharge? }.toMethodsRef) x

def recordSimpTheorem (thmId : Origin) : SimpM Unit :=
  modify fun s => if s.usedTheorems.contains thmId then s else
    let n := s.usedTheorems.size
    { s with usedTheorems := s.usedTheorems.insert thmId n }

def Result.getProof (r : Result) : MetaM Expr := do
  match r.proof? with
  | some p => return p
  | none   => mkEqRefl r.expr

/--
  Similar to `Result.getProof`, but adds a `mkExpectedTypeHint` if `proof?` is `none`
  (i.e., result is definitionally equal to input), but we cannot establish that
  `source` and `r.expr` are definitionally when using `TransparencyMode.reducible`. -/
def Result.getProof' (source : Expr) (r : Result) : MetaM Expr := do
  match r.proof? with
  | some p => return p
  | none   =>
    if (← isDefEq source r.expr) then
      mkEqRefl r.expr
    else
      /- `source` and `r.expr` must be definitionally equal, but
         are not definitionally equal at `TransparencyMode.reducible` -/
      mkExpectedTypeHint (← mkEqRefl r.expr) (← mkEq source r.expr)

/-- Construct the `Expr` `cast h e`, from a `Simp.Result` with proof `h`. -/
def Result.mkCast (r : Simp.Result) (e : Expr) : MetaM Expr := do
  mkAppM ``cast #[← r.getProof, e]

def mkCongrFun (r : Result) (a : Expr) : MetaM Result :=
  match r.proof? with
  | none   => return { expr := mkApp r.expr a, proof? := none }
  | some h => return { expr := mkApp r.expr a, proof? := (← Meta.mkCongrFun h a) }

def mkCongr (r₁ r₂ : Result) : MetaM Result :=
  let e := mkApp r₁.expr r₂.expr
  match r₁.proof?, r₂.proof? with
  | none,     none   => return { expr := e, proof? := none }
  | some h,  none    => return { expr := e, proof? := (← Meta.mkCongrFun h r₂.expr) }
  | none,    some h  => return { expr := e, proof? := (← Meta.mkCongrArg r₁.expr h) }
  | some h₁, some h₂ => return { expr := e, proof? := (← Meta.mkCongr h₁ h₂) }

def mkImpCongr (src : Expr) (r₁ r₂ : Result) : MetaM Result := do
  let e := src.updateForallE! r₁.expr r₂.expr
  match r₁.proof?, r₂.proof? with
  | none,     none   => return { expr := e, proof? := none }
  | _,        _      => return { expr := e, proof? := (← Meta.mkImpCongr (← r₁.getProof) (← r₂.getProof)) } -- TODO specialize if bottleneck

/-- Given the application `e`, remove unnecessary casts of the form `Eq.rec a rfl` and `Eq.ndrec a rfl`. -/
partial def removeUnnecessaryCasts (e : Expr) : MetaM Expr := do
  let mut args := e.getAppArgs
  let mut modified := false
  for i in [:args.size] do
    let arg := args[i]!
    if isDummyEqRec arg then
      args := args.set! i (elimDummyEqRec arg)
      modified := true
  if modified then
    return mkAppN e.getAppFn args
  else
    return e
where
  isDummyEqRec (e : Expr) : Bool :=
    (e.isAppOfArity ``Eq.rec 6 || e.isAppOfArity ``Eq.ndrec 6) && e.appArg!.isAppOf ``Eq.refl

  elimDummyEqRec (e : Expr) : Expr :=
    if isDummyEqRec e then
      elimDummyEqRec e.appFn!.appFn!.appArg!
    else
      e

/--
Given a simplified function result `r` and arguments `args`, simplify arguments using `simp` and `dsimp`.
The resulting proof is built using `congr` and `congrFun` theorems.
-/
def congrArgs (r : Result) (args : Array Expr) : SimpM Result := do
  if args.isEmpty then
    return r
  else
    let cfg ← getConfig
    let infos := (← getFunInfoNArgs r.expr args.size).paramInfo
    let mut r := r
    let mut i := 0
    for arg in args do
      if h : i < infos.size then
        trace[Debug.Meta.Tactic.simp] "app [{i}] {infos.size} {arg} hasFwdDeps: {infos[i].hasFwdDeps}"
        let info := infos[i]
        if cfg.ground && info.isInstImplicit then
          -- We don't visit instance implicit arguments when we are reducing ground terms.
          -- Motivation: many instance implicit arguments are ground, and it does not make sense
          -- to reduce them if the parent term is not ground.
          -- TODO: consider using it as the default behavior.
          -- We have considered it at https://github.com/leanprover/lean4/pull/3151
          r ← mkCongrFun r arg
        else if !info.hasFwdDeps then
          r ← mkCongr r (← simp arg)
        else if (← whnfD (← inferType r.expr)).isArrow then
          r ← mkCongr r (← simp arg)
        else
          r ← mkCongrFun r (← dsimp arg)
      else if (← whnfD (← inferType r.expr)).isArrow then
        r ← mkCongr r (← simp arg)
      else
        r ← mkCongrFun r (← dsimp arg)
      i := i + 1
    return r

/--
Retrieve auto-generated congruence lemma for `f`.

Remark: If all argument kinds are `fixed` or `eq`, it returns `none` because
using simple congruence theorems `congr`, `congrArg`, and `congrFun` produces a more compact proof.
-/
def mkCongrSimp? (f : Expr) : SimpM (Option CongrTheorem) := do
  if f.isConst then if (← isMatcher f.constName!) then
    -- We always use simple congruence theorems for auxiliary match applications
    return none
  let info ← getFunInfo f
  let kinds ← getCongrSimpKinds f info
  if kinds.all fun k => match k with | CongrArgKind.fixed => true | CongrArgKind.eq => true | _ => false then
    /- See remark above. -/
    return none
  match (← get).congrCache.find? f with
  | some thm? => return thm?
  | none =>
    let thm? ← mkCongrSimpCore? f info kinds
    modify fun s => { s with congrCache := s.congrCache.insert f thm? }
    return thm?

/--
Try to use automatically generated congruence theorems. See `mkCongrSimp?`.
-/
def tryAutoCongrTheorem? (e : Expr) : SimpM (Option Result) := do
  let f := e.getAppFn
  -- TODO: cache
  let some cgrThm ← mkCongrSimp? f | return none
  if cgrThm.argKinds.size != e.getAppNumArgs then return none
  let args := e.getAppArgs
  let infos := (← getFunInfoNArgs f args.size).paramInfo
  let config ← getConfig
  let mut simplified := false
  let mut hasProof   := false
  let mut hasCast    := false
  let mut argsNew    := #[]
  let mut argResults := #[]
  let mut i          := 0 -- index at args
  for arg in args, kind in cgrThm.argKinds do
    if h : config.ground ∧ i < infos.size then
      if (infos[i]'h.2).isInstImplicit then
        -- Do not visit instance implict arguments when `ground := true`
        -- See comment at `congrArgs`
        argsNew := argsNew.push arg
        i := i + 1
        continue
    match kind with
    | CongrArgKind.fixed => argsNew := argsNew.push (← dsimp arg)
    | CongrArgKind.cast  => hasCast := true; argsNew := argsNew.push arg
    | CongrArgKind.subsingletonInst => argsNew := argsNew.push arg
    | CongrArgKind.eq =>
      let argResult ← simp arg
      argResults := argResults.push argResult
      argsNew    := argsNew.push argResult.expr
      if argResult.proof?.isSome then hasProof := true
      if arg != argResult.expr then simplified := true
    | _ => unreachable!
    i := i + 1
  if !simplified then return some { expr := e }
  /-
    If `hasProof` is false, we used to return `mkAppN f argsNew` with `proof? := none`.
    However, this created a regression when we started using `proof? := none` for `rfl` theorems.
    Consider the following goal
    ```
    m n : Nat
    a : Fin n
    h₁ : m < n
    h₂ : Nat.pred (Nat.succ m) < n
    ⊢ Fin.succ (Fin.mk m h₁) = Fin.succ (Fin.mk m.succ.pred h₂)
    ```
    The term `m.succ.pred` is simplified to `m` using a `Nat.pred_succ` which is a `rfl` theorem.
    The auto generated theorem for `Fin.mk` has casts and if used here at `Fin.mk m.succ.pred h₂`,
    it produces the term `Fin.mk m (id (Eq.refl m) ▸ h₂)`. The key property here is that the
    proof `(id (Eq.refl m) ▸ h₂)` has type `m < n`. If we had just returned `mkAppN f argsNew`,
    the resulting term would be `Fin.mk m h₂` which is type correct, but later we would not be
    able to apply `eq_self` to
    ```lean
    Fin.succ (Fin.mk m h₁) = Fin.succ (Fin.mk m h₂)
    ```
    because we would not be able to establish that `m < n` and `Nat.pred (Nat.succ m) < n` are definitionally
    equal using `TransparencyMode.reducible` (`Nat.pred` is not reducible).
    Thus, we decided to return here only if the auto generated congruence theorem does not introduce casts.
  -/
  if !hasProof && !hasCast then return some { expr := mkAppN f argsNew }
  let mut proof := cgrThm.proof
  let mut type  := cgrThm.type
  let mut j := 0 -- index at argResults
  let mut subst := #[]
  for arg in args, kind in cgrThm.argKinds do
    proof := mkApp proof arg
    subst := subst.push arg
    type := type.bindingBody!
    match kind with
    | CongrArgKind.fixed => pure ()
    | CongrArgKind.cast  => pure ()
    | CongrArgKind.subsingletonInst =>
      let clsNew := type.bindingDomain!.instantiateRev subst
      let instNew ← if (← isDefEq (← inferType arg) clsNew) then
        pure arg
      else
        match (← trySynthInstance clsNew) with
        | LOption.some val => pure val
        | _ =>
          trace[Meta.Tactic.simp.congr] "failed to synthesize instance{indentExpr clsNew}"
          return none
      proof := mkApp proof instNew
      subst := subst.push instNew
      type := type.bindingBody!
    | CongrArgKind.eq =>
      let argResult := argResults[j]!
      let argProof ← argResult.getProof' arg
      j := j + 1
      proof := mkApp2 proof argResult.expr argProof
      subst := subst.push argResult.expr |>.push argProof
      type := type.bindingBody!.bindingBody!
    | _ => unreachable!
  let some (_, _, rhs) := type.instantiateRev subst |>.eq? | unreachable!
  let rhs ← if hasCast then removeUnnecessaryCasts rhs else pure rhs
  if hasProof then
    return some { expr := rhs, proof? := proof }
  else
    /- See comment above. This is reachable if `hasCast == true`. The `rhs` is not structurally equal to `mkAppN f argsNew` -/
    return some { expr := rhs }

/--
Return a WHNF configuration for retrieving `[simp]` from the discrimination tree.
If user has disabled `zeta` and/or `beta` reduction in the simplifier, or enabled `zetaDelta`,
we must also disable/enable them when retrieving lemmas from discrimination tree. See issues: #2669 and #2281
-/
def getDtConfig (cfg : Config) : WhnfCoreConfig :=
  match cfg.beta, cfg.zeta, cfg.zetaDelta with
  | true, true, false => simpDtConfig
  | _,    _,    _     => { simpDtConfig with zeta := cfg.zeta, beta := cfg.beta, zetaDelta := cfg.zetaDelta }

def Result.addExtraArgs (r : Result) (extraArgs : Array Expr) : MetaM Result := do
  match r.proof? with
  | none => return { expr := mkAppN r.expr extraArgs }
  | some proof =>
    let mut proof := proof
    for extraArg in extraArgs do
      proof ← Meta.mkCongrFun proof extraArg
    return { expr := mkAppN r.expr extraArgs, proof? := some proof }

def Step.addExtraArgs (s : Step) (extraArgs : Array Expr) : MetaM Step := do
  match s with
  | .visit r => return .visit (← r.addExtraArgs extraArgs)
  | .done r => return .done (← r.addExtraArgs extraArgs)
  | .continue none => return .continue none
  | .continue (some r) => return .continue (← r.addExtraArgs extraArgs)

end Simp

export Simp (SimpM Simprocs)

/--
  Auxiliary method.
  Given the current `target` of `mvarId`, apply `r` which is a new target and proof that it is equal to the current one.
-/
def applySimpResultToTarget (mvarId : MVarId) (target : Expr) (r : Simp.Result) : MetaM MVarId := do
  match r.proof? with
  | some proof => mvarId.replaceTargetEq r.expr proof
  | none =>
    if target != r.expr then
      mvarId.replaceTargetDefEq r.expr
    else
      return mvarId

end Lean.Meta
