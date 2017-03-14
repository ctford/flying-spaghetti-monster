import Protocol
import Data.List

%language TypeProviders
%default total


-- A session type that enforces valid interactions with a door.
%provide (DoorSession : (Path -> Bool -> Type)) with Protocol "door.txt"

riiing : Nat -> DoorSession("closed", "closed") True
riiing Z = Noop
riiing (S k) = do
  Action "ring"
  riiing k

-- An implementation of the protocol.
door : Nat -> Bool -> DoorSession ("locked", "end") True
door nTimes anyoneHome = do
--Action  "smash"  -> Won't compile because it's not a legal action described in door.txt.
  Failure "unlock"
  Action  "unlock"
--Action  "unlock" -> Won't compile because it's not a legal action *in this state*.
  riiing  nTimes
  if not anyoneHome
     then
          do Failure "open"
             Action "quit"
     else
          do Action "open"
             Action "enter"

from : DoorSession (a, b) success -> String
from {a} _ = a

to : DoorSession (a, b) success -> String
to {b} _ = b

run : DoorSession (a, b) success -> List String
run (x >>= rest) = (run x) ++ (run $ rest True)
run x = [from x, to x]

partial
runActions : DoorSession (a, b) success -> List String
runActions (x >>= rest) = (runActions x) ++ (runActions $ rest True)
runActions (Action x) = [x]
runActions (Failure x) = [x]
runActions Noop = []


-- A session type that enforces valid interactions with a vending machine.
%provide (VendingMachineSession : (Path -> Bool -> Type)) with Protocol "vending-machine.txt"

-- An implementation of the protocol.
vendingMachine : VendingMachineSession ("waiting", "vended") True
vendingMachine = do
--Action "hack" -> Won't compile as it's not a legal action described in vending-machine.txt.
  Action "pay"
  Action "return"
--Action "vend" -> Won't compile as it's not a legal action *in this state*.
  Action "pay"
  Action "select"
  Action "vend"
