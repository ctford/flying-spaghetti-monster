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
--Act "smash"  -> Won't compile because it's not a valid action.
  Act "unlock"
--Act "unlock" -> Won't compile because it's not a valid action *in this state*.
  Act "ring"
  Act "open"


-- A session type that enforces valid interactions with a vending machine.
%provide (VendingMachineSession : (Path -> Type)) with Protocol "vending-machine.txt"

-- An implementation of the protocol.
vendingMachine : VendingMachineSession ("waiting", "vended")
vendingMachine = do
  Begin
--Then $ Choose ("hack",   ("waiting", "selected")) -> Won't compile as it's not a valid transition from vending-machine.txt.
  Then $ Choose ("pay",    ("waiting", "paid"))
  Then $ Choose ("return", ("paid", "waiting"))
  Then $ Choose ("pay",    ("waiting", "paid"))
  Then $ Choose ("select", ("paid", "selected"))
  Then $ Choose ("vend",   ("selected", "vended"))
