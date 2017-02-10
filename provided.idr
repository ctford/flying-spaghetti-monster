module Main
import Data.List
%language TypeProviders

data Choice : List a -> Type
where Is : (x : a) ->
           {xs : List a} ->
           {auto p : Elem x xs} ->
           Choice xs

states : List String
states = ["start", "locked", "closed", "opened"]

State : Type
State = Choice states

transitions : List (State, State)
transitions =
  [(Is "locked", Is "closed"),
  (Is "start", Is "start"),
  (Is "start", Is "closed"),
  (Is "closed", Is "locked"),
  (Is "closed", Is "closed"),
  (Is "closed", Is "opened")]

Transition : Type
Transition = Choice transitions

ring : Transition
ring = Is (Is "closed", Is "closed")

commence : Transition
commence = Is (Is "start", Is "closed")

Derived : Type
Derived = (State, State)

solo : Transition -> Derived
solo (Is (x, y)) = (x, y)

data Command : Type -> (State, State) -> Type
where
  Change : (t : Transition) -> Command () (solo t)
  Pure   : a -> Command a (Is "start", Is "start")
  (>>=)  : Command a (s1, s2) -> (a -> Command b (s2, s3)) -> Command b (s1, s3)

doorProg : Command () (Is "start", Is "closed")
doorProg = do Pure ()
              Change commence
              Change ring
--              Change commence
--              Open
--              Close

-- %provide (fsm : State) with FsmType "solo" ["bar", "baz"]
