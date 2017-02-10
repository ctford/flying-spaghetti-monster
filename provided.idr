module Main
import Data.List
%language TypeProviders
%default total

-- A list of valid steps that could eventually come from a type provider.
steps : List (String, String)
steps =
  [("locked", "closed"),
  ("closed", "locked"),
  ("closed", "closed"),
  ("closed", "opened")]

-- A Choice is a type representing a discrete set of choices.
data Choice : List a -> Type
where Choose : (x : a) ->
               {xs : List a} ->
               {auto p : Elem x xs} ->
               Choice xs

-- A choice between the valid steps.
Step : Type
Step = Choice steps

-- Deconstruct a step into its states.
single : Step -> (String, String)
single (Choose x) = x

-- Use the allowed steps to define a finite state machine type.
data Route : Type -> (a, a) -> Type
where
  Begin : Route () (s, s)
  Then  : (step : Step) -> Route () (single step)
  (>>=) : Route a (s1, s2) -> (a -> Route b (s2, s3)) -> Route b (s1, s3)

-- An example implementation of our finite state machine.
door : Route () ("locked", "opened")
door = do Begin
--        Then $ Choose ("locked", "opened") -> Won't compile as it's not a valid step.
          Then $ Choose ("locked", "closed")
          Then $ Choose ("closed", "closed")
          Then $ Choose ("closed", "opened")
