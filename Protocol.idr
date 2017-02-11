module Protocol
import Data.List

%access public export
%default total

-- A Choice is a type representing a discrete set of alternatives.
data Choice : List a -> Type
where Choose : (alternative : a) ->
               {alternatives : List a} ->
               {auto membershipProof : Elem alternative alternatives} ->
               Choice alternatives

-- Read a list of transitions from a file.
readTransitions : String -> IO (Either FileError (List (String, String)))
readTransitions filename =
  do result <- readFile filename
     pure $ map (pair . words) result
  where pair : List String -> List (String, String)
        pair (source::destination::rest) = (source, destination)::(pair rest)
        pair _ = []

-- Use the allowed transitions to define a finite state machine type.
data Command : (transition : Type) -> (convert : (step -> (String, String))) -> Type -> (String, String) -> Type
where
  Begin : Command transition convert () (state, state)

  Then  : (t : transition) ->
          Command step convert () (convert t)

  (>>=) : Command transition convert a (beginning, middle) ->
          (a -> Command transition convert b (middle, end)) ->
          Command transition convert b (beginning, end)

-- Encode a list of transitions into a session type.
encode : List (String, String) -> (String, String) -> Type
encode transitions = Command (Choice transitions) single ()
  where single : {auto xs : List (String, String)} -> (Choice xs) -> (String, String)
        single (Choose x) = x

-- A type provider providing a list of steps.
Protocol : String -> IO (Provider ((String, String) -> Type))
Protocol filename =
  do result <- readTransitions filename
     pure $
       case result of
         Left error => Error $ "Unable to read transitions file: " ++ filename
         Right transitions => Provide $ encode transitions
