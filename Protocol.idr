module Protocol
import Data.List

%access public export
%default total

-- A Choice is a type representing a discrete set of choices.
data Choice : List a -> Type
where Choose : (x : a) ->
               {xs : List a} ->
               {auto p : Elem x xs} ->
               Choice xs

-- Read a list of transitions from a file.
readTransitions : String -> IO (Either FileError (List (String, String)))
readTransitions filename =
  do result <- readFile filename
     pure $ map (pair . words) result
  where pair : List String -> List (String, String)
        pair (x1::x2::xs) = (x1, x2)::(pair xs)
        pair _ = []

-- Deconstruct a transition into its source and destination states.
single : (xs : List (String, String)) -> (Choice xs) -> (String, String)
single _ (Choose x) = x

-- Use the allowed transitions to define a finite state machine type.
data Command : (transition : Type) -> (convert : (step -> (String, String))) -> Type -> (String, String) -> Type
where
  Begin : Command transition convert () (state, state)
  Then  : (t : transition) -> Command step convert () (convert t)
  (>>=) : Command transition convert a (s1, s2) ->
          (a -> Command transition convert b (s2, s3)) ->
          Command transition convert b (s1, s3)

-- A type provider providing a list of steps.
Protocol : String -> IO (Provider ((String, String) -> Type))
Protocol filename =
  do result <- readTransitions filename
     pure $
       case result of
         Left error => Error $ "Unable to read transitions file: " ++ filename
         Right transitions => Provide $ Command (Choice transitions) (single transitions) ()
