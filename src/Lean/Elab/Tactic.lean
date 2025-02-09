/-
Copyright (c) 2020 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Sebastian Ullrich
-/
prelude
import Lean.Elab.Term
import Lean.Elab.Tactic.Basic
import Lean.Elab.Tactic.ElabTerm
import Lean.Elab.Tactic.Induction
import Lean.Elab.Tactic.Generalize
import Lean.Elab.Tactic.Injection
import Lean.Elab.Tactic.Match
import Lean.Elab.Tactic.Rewrite
import Lean.Elab.Tactic.Location
import Lean.Elab.Tactic.SimpTrace
import Lean.Elab.Tactic.Simp
import Lean.Elab.Tactic.Simproc
import Lean.Elab.Tactic.BuiltinTactic
import Lean.Elab.Tactic.Split
import Lean.Elab.Tactic.Conv
import Lean.Elab.Tactic.Delta
import Lean.Elab.Tactic.Meta
import Lean.Elab.Tactic.Unfold
import Lean.Elab.Tactic.Cache
import Lean.Elab.Tactic.Calc
import Lean.Elab.Tactic.Congr
import Lean.Elab.Tactic.Guard
import Lean.Elab.Tactic.RCases
import Lean.Elab.Tactic.Repeat
import Lean.Elab.Tactic.Ext
import Lean.Elab.Tactic.Change
import Lean.Elab.Tactic.FalseOrByContra
import Lean.Elab.Tactic.Omega
import Lean.Elab.Tactic.Simpa
import Lean.Elab.Tactic.NormCast
import Lean.Elab.Tactic.Symm
import Lean.Elab.Tactic.SolveByElim
