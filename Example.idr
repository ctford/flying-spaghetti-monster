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
--Then $ Choose ("locked", "opened") -> Won't compile as it's not a valid transition from door.txt.
  Then $ Choose ("locked", "closed")
  Then $ Choose ("closed", "closed")
  Then $ Choose ("closed", "opened")


-- A session type that enforces valid interactions with a vending machine.
%provide (VendingMachineSession : (Path -> Type)) with Protocol "vending-machine.txt"

-- An implementation of the protocol.
vendingMachine : VendingMachineSession ("waiting", "vended")
vendingMachinedoor = do
  Begin
--Then $ Choose ("waiting", "selected") -> Won't compile as it's not a valid transition from vending-machine.txt.
  Then $ Choose ("waiting", "paid")
  Then $ Choose ("paid", "waiting")
  Then $ Choose ("waiting", "paid")
  Then $ Choose ("paid", "selected")
  Then $ Choose ("selected", "vended")
