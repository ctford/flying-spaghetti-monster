import Protocol
import Data.List

%language TypeProviders
%default total


-- A session type that enforces valid interactions with a door.
%provide (DoorSession : (Path -> Type -> Type)) with Protocol "door.txt"

riiing : Nat -> DoorSession("closed", "closed") Bool
riiing Z = Noop
riiing (S k) = do
  Action "ring"
  riiing k

-- An implementation of the protocol.
door : Nat -> DoorSession ("locked", "end") Bool
door nTimes = do
--Action  "smash"  -> Won't compile because it's not a legal action described in door.txt.
  Action  "unlock"
--Action  "unlock" -> Won't compile because it's not a legal action *in this state*.
  riiing nTimes
  Action "open"
  Action "enter"

runDoor : DoorSession (a, b) Bool -> List String
runDoor (x >>= rest) = (runDoor x) ++ (runDoor $ rest True)
runDoor (Action x) = [x]
runDoor Noop = []


-- A session type that enforces valid interactions with a vending machine.
%provide (VendingMachineSession : (Path -> Type -> Type)) with Protocol "vending-machine.txt"

-- An implementation of the protocol.
vendingMachine : VendingMachineSession ("waiting", "vended") Bool
vendingMachine = do
--Action "hack" -> Won't compile as it's not a legal action described in vending-machine.txt.
  Action "pay"
  Action "return"
--Action "vend" -> Won't compile as it's not a legal action *in this state*.
  Action "pay"
  Action "select"
  Action "vend"

runVendingMachine : VendingMachineSession (a, b) Bool -> List String
runVendingMachine (x >>= rest) = (runVendingMachine x) ++ (runVendingMachine $ rest True)
runVendingMachine (Action x) = [x]
runVendingMachine Noop = []
