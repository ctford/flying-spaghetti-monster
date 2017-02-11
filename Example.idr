import Protocol
import Data.List

%language TypeProviders
%default total

-- A session type that enforces valid transitions.
%provide (Session : (Path -> Type)) with Protocol "transitions.txt"

-- An implementation of the protocol.
door : Session ("locked", "opened")
door = do Begin
--        Then $ Choose ("locked", "opened") -> Won't compile as it's not a valid transition.
          Then $ Choose ("locked", "closed")
          Then $ Choose ("closed", "closed")
          Then $ Choose ("closed", "opened")
