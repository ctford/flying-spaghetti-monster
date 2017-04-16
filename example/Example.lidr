= Flying Spaghetti Monster Examples

> module Example
>
> import Data.FSM.Protocol
> import Data.List
>
> %language TypeProviders
> %default total
>
> %access public export


== Door Example

Define a session type that enforces valid interactions with a door.

> %provide (DoorSession : (State -> (Success -> State) -> Type)) with Protocol "example/door.txt"

> ||| Ring the doorbell.
> ||| @ n the number of times to ring
> Ring : (n : Nat) -> DoorSession "closed" (const "closed")
> Ring Z     = Noop
> Ring (S remaining) = do
>   Cert "ring"
>   Ring remaining

> ||| An implementation of the protocol.
> door : Nat -> DoorSession "locked" (const "end")
> door Z = Cert "give-up"
> door (S retries) = do

`Action "smash"` wouldn't compile, because it's not a legal action described in [`door.txt`][door spec].

>  Successful <- Action "unlock" | Unsuccessful => door retries
>  Ring 3
>  Successful <- Action "open"   | Unsuccessful => Cert "quit"
>  Cert "enter"

`Action "unlock"` wouldn't compile, because it's not a legal action *in this state*.

> runDoor : DoorSession a b -> List String
> runDoor Noop = []
> runDoor (Cert x) = [x]
> runDoor (Action x) = [x]
> runDoor (x >>= continue) = (runDoor x) ++ (runDoor $ continue Successful)
>{-

== Vending Machine Example

Define a session type that enforces valid interactions with a vending machine.

> %provide (VendingMachineSession : (Path -> Type)) with
>          Protocol "example/vending-machine.txt"

> ||| An implementation of the protocol.
> vendingMachine : VendingMachineSession ("waiting", "vended")
> vendingMachine =

`Action "hack"` won't compile,
because it's not a legal action described in [`vending-machine.txt`][vm spec].

>   do Action "pay"
>      Action "return"

`Action "vend"` won't compile,
because it's not a legal action *in this state*

>      Action "pay"
>      Action "select"
>      Action "vend"

> runVendingMachine : VendingMachineSession (a, b) -> List String
> runVendingMachine (x >>= rest) =
>     runVendingMachine x ++ runVendingMachine (rest True)
> runVendingMachine (Action x)   = [x]
> runVendingMachine Noop         = []

== Main Executable

>-}
>{-
> namespace Main
>
>   private runExample : (name : String) -> (results : List String) -> IO ()
>   runExample name results =
>       do putStrLn $ unwords [ "===>", name, "Example" ]
>          putStrLn $ unwords results
>
>   %access export
>
>
>   doorExample : IO ()
>   doorExample =
>       runExample "Door" $
>       runDoor (door 3)
>
>   vendingMachineExample : IO ()
>   vendingMachineExample =
>       runExample "Vending Machine" $
>       runVendingMachine vendingMachine
>
>   main : IO ()
>   main = do doorExample
>             vendingMachineExample


 <!-- Named Links -->

[door spec]: ./door.txt
[vm spec]: ./vending-machine.txt

>-}
