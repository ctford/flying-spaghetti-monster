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

Named : Type -> Type
Named x = (String, x)

||| A named happy and sad path.
Transition : Type
Transition = Named (Path, Path)

||| Use the allowed transitions to define a finite state machine type.
data Command : Type -> Named Path -> Type
where
  Action  : (name : String) ->
            {transitions : List Transition} ->
            {auto membership : Elem (name, (beginning, happy), (beginning, sad)) transitions} ->
            Command (Choice transitions) (beginning, happy, sad)

  Cert    : (name : String) ->
            {transitions : List Transition} ->
            {auto membership : Elem (name, (beginning, happy), (beginning, happy)) transitions} ->
            Command (Choice transitions) (beginning, happy, happy)

  Noop    : Command (Choice transitions) (beginning, beginning, beginning)

  (>>=)   : Command (Choice transitions) (beginning, happy, sad) ->
            ((success : Bool) -> Command (Choice transitions) (if success then happy else sad, end, alt)) ->
            Command (Choice transitions) (beginning, end, alt)

----------------------------
--- Parsing Transition Files
----------------------------

||| Encode a list of transitions into a session type.
encode : List Transition -> Named Path -> Type
encode transitions path = Command (Choice transitions) path

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
Protocol : String -> IO (Provider (Named Path -> Type))
Protocol filename =
  do result <- readTransitions filename
     pure $
       case result of
         Left error => Error $ "Unable to read transitions file: " ++ filename
         Right transitions => Provide $ encode transitions
