import Protocol
import Data.List

%language TypeProviders
%default total

-- A type that enforces valid steps.
%provide (Route : ((String, String) -> Type)) with Protocol "steps.txt"

-- An example implementation of our finite state machine.
door : Route ("locked", "opened")
door = do Begin
--        Then $ Choose ("locked", "opened") -> Won't compile as it's not a valid step.
          Then $ Choose ("locked", "closed")
          Then $ Choose ("closed", "closed")
          Then $ Choose ("closed", "opened")
