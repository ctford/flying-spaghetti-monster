module Main
import Data.List
%language TypeProviders
%default total

data Choice : List a -> Type
where Choose : (x : a) ->
               {xs : List a} ->
               {auto p : Elem x xs} ->
               Choice xs

transitions : List (String, String)
transitions =
  [("locked", "closed"),
  ("closed", "locked"),
  ("closed", "closed"),
  ("closed", "opened")]

Transition : Type
Transition = Choice transitions

single : Transition -> (String, String)
single (Choose x) = x

data Route : Type -> (a, a) -> Type
where
  Begin : Route () (s, s)
  Then  : (t : Transition) -> Route () (single t)
  (>>=) : Route a (s1, s2) -> (a -> Route b (s2, s3)) -> Route b (s1, s3)

door : Route () ("locked", "opened")
door = do Begin
--        Then $ Choose ("locked", "opened") -> Won't compile as it's not a valid transition.
          Then $ Choose ("locked", "closed")
          Then $ Choose ("closed", "closed")
          Then $ Choose ("closed", "opened")
