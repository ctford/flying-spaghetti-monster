module Main
import Data.List
%language TypeProviders
%default total

-- A Choice is a type representing a discrete set of choices.
data Choice : List a -> Type
where Choose : (x : a) ->
               {xs : List a} ->
               {auto p : Elem x xs} ->
               Choice xs

-- Read a list of pairs from a file.
readSteps : String -> IO (Either FileError (List (String, String)))
readSteps filename =
  do result <- readFile filename
     pure $ map (pair . words) result
  where pair : List String -> List (String, String)
        pair (x1::x2::xs) = (x1, x2)::(pair xs)
        pair _ = []

-- Deconstruct a step into its states.
single : (xs : List (String, String)) -> (Choice xs) -> (String, String)
single _ (Choose x) = x

-- Use the allowed steps to define a finite state machine type.
data Path : (step : Type) -> (convert : (step -> (String, String))) -> Type -> (String, String) -> Type
where
  Begin : Path step convert () (state, state)
  Then  : (s : step) -> Path step convert () (convert s)
  (>>=) : Path step convert a (s1, s2) ->
          (a -> Path step convert b (s2, s3)) ->
          Path step convert b (s1, s3)

-- A type provider providing a list of steps.
Protocol : String -> IO (Provider ((String, String) -> Type))
Protocol filename =
  do result <- readSteps filename
     pure $
       case result of
         Left error => Error $ "Unable to read steps file: " ++ filename
         Right steps => Provide $ Path (Choice steps) (single steps) ()

-- A type that enforces valid steps.
%provide (Route : ((String, String) -> Type)) with Protocol "steps.txt"

-- An example implementation of our finite state machine.
door : Route ("locked", "opened")
door = do Begin
--        Then $ Choose ("locked", "opened") -> Won't compile as it's not a valid step.
          Then $ Choose ("locked", "closed")
          Then $ Choose ("closed", "closed")
          Then $ Choose ("closed", "opened")
