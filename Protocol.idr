module Protocol
import Data.List

%access public export
%default total

-- A discrete set of alternatives.
data Choice : List a -> Type
where Choose : (alternative : a) ->
               {alternatives : List a} ->
               {auto membership : Elem alternative alternatives} ->
               Choice alternatives

-- A path between a source and a destination state.
Path : Type
Path = (String, String)

-- A named path.
Transition : Type
Transition = (String, Path, Path)

-- Use the allowed transitions to define a finite state machine type.
data Command : Type -> Path -> (result : Type) -> Type
where
  Action  : (name : String) ->
            {transitions : List Transition} ->
            {p1 , p2 : Path} ->
            {auto membership : Elem (name , p1 , p2) transitions} ->
            Command (Choice transitions) p1 Bool

  Noop    : Command (Choice transitions) (state, state) Bool

  (>>=)   : Command (Choice transitions) (beginning, middle) Bool ->
            (Bool -> Command (Choice transitions) (middle, end) Bool) ->
            Command (Choice transitions) (beginning, end) Bool

-- Encode a list of transitions into a session type.
encode : List Transition -> Path -> Type -> Type
encode transitions = Command (Choice transitions)

comment : String -> Bool
comment = isPrefixOf "#"

parse : List String -> Maybe Transition
parse [name, source, destination, alternative] = Just (name, (source, destination), (source, alternative))
parse [name, source, destination] = Just (name, (source, destination), (source, destination))
parse _ = Nothing

-- Read a list of transitions from a file.
readTransitions : String -> IO (Either FileError (List Transition))
readTransitions filename =
  do contents <- readFile filename
     let entries = map lines contents
     let nonComments = map (filter (not . comment)) entries
     let parsed  = map (mapMaybe $ parse . words) nonComments
     pure $ parsed

-- Provide a session type derived from encoding the specified file.
Protocol : String -> IO (Provider (Path -> Type -> Type))
Protocol filename =
  do result <- readTransitions filename
     pure $
       case result of
         Left error => Error $ "Unable to read transitions file: " ++ filename
         Right transitions => Provide $ encode transitions
