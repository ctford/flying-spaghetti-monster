import Protocol
import Data.List

%language TypeProviders
%default total


-- A session type that enforces valid interactions with a door.
%provide (DoorSession : (UPath -> Type)) with Protocol "door.txt"

riiing : Nat -> DoorSession ("closed", "closed", "closed")
riiing Z = Noop
riiing (S k) = do
  success <- Action "ring"
  case success of
       False => riiing k
       True => riiing k

-- An implementation of the protocol.
partial
door : Nat -> DoorSession ("locked", "end", "end")
door nTimes = do
--Action  "smash"  -> Won't compile because it's not a legal action described in door.txt.
  success <- Action  "unlock"
  case success of
       True => do
         success <- Action "open"
         case success of
           True => do
             success <- Action "enter"
             case success of
               True => do Noop
--Action  "unlock" -> Won't compile because it's not a legal action *in this state*.
--  riiing nTimes
--  Action "open"
--  Action "enter"

runDoor : DoorSession (a, b, c) -> List String
runDoor (x >>= rest) = (runDoor x) ++ (runDoor $ rest True)
runDoor (Action x) = [x]
runDoor Noop = []


-- A session type that enforces valid interactions with a vending machine.
-- %provide (VendingMachineSession : (Path -> Type)) with Protocol "vending-machine.txt"

-- An implementation of the protocol.
--vendingMachine : VendingMachineSession ("waiting", "vended")
--vendingMachine = do
--Action "hack" -> Won't compile as it's not a legal action described in vending-machine.txt.
--  Action "pay"
--  Action "return"
--Action "vend" -> Won't compile as it's not a legal action *in this state*.
--  Action "pay"
--  Action "select"
--  Action "vend"

--runVendingMachine : VendingMachineSession (a, b) -> List String
--runVendingMachine (x >>= rest) = (runVendingMachine x) ++ (runVendingMachine $ rest True)
--runVendingMachine (Action x) = [x]
--runVendingMachine Noop = []
