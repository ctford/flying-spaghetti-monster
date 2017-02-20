import Protocol
import Data.List

%language TypeProviders
%default total


-- A session type that enforces valid interactions with a door.
%provide (DoorSession : (Path -> Type)) with Protocol "door.txt"

riiing : Nat -> DoorSession("closed", "closed")
riiing Z = Action "ring"
riiing (S k) = do
  Action "ring"
  riiing k

-- An implementation of the protocol.
door : Nat -> Bool -> DoorSession ("ready", "finished")
door nTimes anyoneHome = do
  Action  "start"
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


-- A session type that enforces valid interactions with a vending machine.
%provide (VendingMachineSession : (Path -> Type)) with Protocol "vending-machine.txt"

-- An implementation of the protocol.
vendingMachine : VendingMachineSession ("waiting", "vended")
vendingMachine = do
--Action "hack" -> Won't compile as it's not a legal action described in vending-machine.txt.
  Action "pay"
  Action "return"
--Action "vend" -> Won't compile as it's not a legal action *in this state*.
  Action "pay"
  Action "select"
  Action "vend"
