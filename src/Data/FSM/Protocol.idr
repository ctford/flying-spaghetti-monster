||| Provide session types derived from specifications.
module Data.FSM.Protocol

import Data.List

%default total

%access public export

-------------
-- Data Types
-------------

||| A discrete set of alternatives.
data Choice : List a -> Type where
     Choose : (alternative : a) ->
              {alternatives : List a} ->
              {auto membership : Elem alternative alternatives} ->
              Choice alternatives

||| A path between a source and a destination state.
Path : Type
Path = (String, String)

||| A named happy and sad path.
Transition : Type
Transition = (String, Path, Path)

||| Use the allowed transitions to define a finite state machine type.
data Command : Bool -> Type -> Path -> Type where
     Action  : (name : String) ->
               {transitions : List Transition} ->
               {auto membership : Elem (name, (beginning, happy), (beginning, sad)) transitions} ->
               Command True (Choice transitions) (beginning, happy)

     Noop    : Command True (Choice transitions) (state, state)

     (>>=)   : Command True (Choice transitions) (beginning, middle) ->
               (Bool -> Command True (Choice transitions) (middle, end)) ->
               Command True (Choice transitions) (beginning, end)

---------------------------
-- Parsing Transition Files
---------------------------

||| Encode a list of transitions into a session type.
encode : List Transition -> Path -> Type
encode transitions path = Command True (Choice transitions) path

%access private

isComment : String -> Bool
isComment = isPrefixOf "#"

stripComments : List String -> List String
stripComments = filter (not . isComment)

parse : List String -> Maybe Transition
parse [name, source, destination, alternative] =
    Just (name, (source, destination), (source, alternative))
parse [name, source, destination] =
    Just (name, (source, destination), (source, destination))
parse _ = Nothing

||| Read a list of transitions from a file.
readTransitions : String -> IO (Either FileError (List Transition))
readTransitions filename = pure $ map go !(readFile filename)
  where
    go : String -> (List Transition)
    go = mapMaybe (parse . words) .
         stripComments .
         lines

%access export

||| Provide a session type derived from encoding the specified file.
Protocol : String -> IO (Provider (Path -> Type))
Protocol filename =
    pure $
    case !(readTransitions filename) of
      Right transitions => Provide $ encode transitions
      Left _ => Error $ "Unable to read transitions file: " ++ filename
