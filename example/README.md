Flying Spaghetti Monster Examples
=================================

```idris
module Example

import Data.FSM.Protocol
import Data.List

%language TypeProviders
%default total

%access public export
```

Door Example
------------

Define a session type that enforces valid interactions with a door.

```idris
%provide (DoorSession : (Path -> Type)) with
         Protocol "door.txt"
```

```idris
||| Ring the doorbell.
||| @ n the number of times to ring
riiing : (n : Nat) -> DoorSession ("closed", "closed")
riiing Z     = Noop
riiing (S k) = do Action "ring"
                  riiing k
```

```idris
||| An implementation of the protocol.
door : Nat -> DoorSession ("locked", "end")
door nTimes =
```

`Action "smash"` won't compile,
because it's not a legal action described in [`door.txt`](./door.txt).

```idris
    do Action  "unlock"
```

`Action "unlock"` won't compile,
because it's not a legal action *in this state*.

```idris
       riiing nTimes
       Action "open"
       Action "enter"
```

```idris
runDoor : DoorSession (a, b) -> List String
runDoor (x >>= rest) = (runDoor x) ++ (runDoor $ rest True)
runDoor (Action x)   = [x]
runDoor Noop         = []
```

Vending Machine Example
-----------------------

Define a session type that enforces valid interactions with a vending machine.

```idris
%provide (VendingMachineSession : (Path -> Type)) with
         Protocol "vending-machine.txt"
```

```idris
||| An implementation of the protocol.
vendingMachine : VendingMachineSession ("waiting", "vended")
vendingMachine =
```

`Action "hack"` won't compile,
because it's not a legal action described in [`vending-machine.txt`](./vending-machine.txt).

```idris
  do Action "pay"
     Action "return"
```

`Action "vend"` won't compile,
because it's not a legal action *in this state*

```idris
     Action "pay"
     Action "select"
     Action "vend"
```

```idris
runVendingMachine : VendingMachineSession (a, b) -> List String
runVendingMachine (x >>= rest) =
    runVendingMachine x ++ runVendingMachine (rest True)
runVendingMachine (Action x)   = [x]
runVendingMachine Noop         = []
```

Main Executable
---------------

```idris
namespace Main

  private runExample : (name : String) -> (results : List String) -> IO ()
  runExample name results =
      do putStrLn $ unwords [ "===>", name, "Example" ]
         putStrLn $ unwords results

  %access export

  doorExample : IO ()
  doorExample =
      runExample "Door" $
      runDoor (door 3)

  vendingMachineExample : IO ()
  vendingMachineExample =
      runExample "Vending Machine" $
      runVendingMachine vendingMachine

  main : IO ()
  main = do doorExample
            vendingMachineExample
```

<!-- Named Links -->
