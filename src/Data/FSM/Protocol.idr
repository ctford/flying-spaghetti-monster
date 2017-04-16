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

||| A state is described as a String.
State : Type
State = String

||| A path between a source and a destination state.
Path : Type
Path = (State, State)

||| A named happy and sad path.
Transition : Type
Transition = (String , (Path, Path))

||| A Transition can be either Successful or Unsuccessful.
data Success = Successful | Unsuccessful

||| A Fork is Path where the destination state is dependent on Success.
Fork : Type
Fork = (State, (Success -> State))

||| Use the allowed transitions to define a finite state machine type.
data Command : Type -> Fork -> Type
where
  Action  : (name : String) ->
            {transitions : List Transition} ->
            {auto membership : Elem (name, (beginning, happy), (beginning, sad)) transitions} ->
            Command (Choice transitions) (beginning, \success => case success of
                                                                   Successful => happy
                                                                   Unsuccessful => sad)

  Cert    : (name : String) ->
            {transitions : List Transition} ->
            {auto membership : Elem (name, (beginning, happy), (beginning, happy)) transitions} ->
            Command (Choice transitions) (beginning, const happy)

  Noop    : Command (Choice transitions) (beginning, const beginning)

  (>>=)   : Command (Choice transitions) (beginning, continue) ->
            ((result : Success) -> Command (Choice transitions) (continue result, finally)) ->
            Command (Choice transitions) (beginning, finally)

----------------------------
--- Parsing Transition Files
----------------------------

||| Encode a list of transitions into a session type.
encode : List Transition -> Fork -> Type
encode transitions = Command (Choice transitions)

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
Protocol : String -> IO (Provider (Fork -> Type))
Protocol filename =
  do result <- readTransitions filename
     pure $
       case result of
         Left error => Error $ "Unable to read transitions file: " ++ filename
         Right transitions => Provide $ encode transitions
