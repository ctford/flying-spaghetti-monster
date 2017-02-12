import Protocol
import Data.List

%language TypeProviders
%default total


-- A session type that enforces valid interactions with a door.
%provide (DoorSession : (Path -> Type)) with Protocol "door.txt"

-- An implementation of the protocol.
door : DoorSession ("locked", "opened")
door = do
  Begin
--Then "smash"  -> Won't compile because it's not a legal action described in door.txt.
  Then "unlock"
--Then "unlock" -> Won't compile because it's not a legal action *in this state*.
  Then "ring"
  Then "open"


-- A session type that enforces valid interactions with a vending machine.
%provide (VendingMachineSession : (Path -> Type)) with Protocol "vending-machine.txt"

-- An implementation of the protocol.
vendingMachine : VendingMachineSession ("waiting", "vended")
vendingMachine = do
  Begin
--Then "hack" -> Won't compile as it's not a legal action described in vending-machine.txt.
  Then "pay"
  Then "return"
--Then "vend" -> Won't compile as it's not a legal action *in this state*
  Then "pay"
  Then "select"
  Then "vend"
