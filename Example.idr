import Protocol
import Data.List

%language TypeProviders
%default total


-- A session type that enforces valid interactions with a door.
%provide (DoorSession : (Path -> Type)) with Protocol "door.txt"

-- An implementation of the protocol.
door : DoorSession ("locked", "opened")
door = do
--Action "smash"  -> Won't compile because it's not a legal action described in door.txt.
  Action "unlock"
--Action "unlock" -> Won't compile because it's not a legal action *in this state*.
  Action "ring"
  Action "open"


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
