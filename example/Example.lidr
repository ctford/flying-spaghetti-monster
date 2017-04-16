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

> %provide (DoorSession : (Route -> Type)) with Protocol "example/door.txt"

> ||| Ring the doorbell.
> ||| @ n the number of times to ring
> Ring : (n : Nat) -> DoorSession ("closed", const "closed")
> Ring Z     = Noop
> Ring (S remaining) = do
>   Do "ring"
>   Ring remaining

> ||| An implementation of the protocol.
> door : Nat -> DoorSession ("locked", const "end")
> door Z = Do "give-up"
> door (S retries) = do

`Try "smash"` wouldn't compile, because it's not a legal action described in [`door.txt`][door spec].

>  Success <- Try "unlock" | Failure => door retries
>  Ring 3
>  Success <- Try "open"   | Failure => Do "quit"
>  Do "enter"

`Try "unlock"` wouldn't compile, because it's not a legal action *in this state*.

> runDoor : DoorSession _ -> List String
> runDoor Noop = []
> runDoor (Do x) = [x]
> runDoor (Try x) = [x]
> runDoor (x >>= continue) = (runDoor x) ++ (runDoor $ continue Success)
>{-

== Vending Machine Example

Define a session type that enforces valid interactions with a vending machine.

> %provide (VendingMachineSession : (Path -> Type)) with
>          Protocol "example/vending-machine.txt"

> ||| An implementation of the protocol.
> vendingMachine : VendingMachineSession ("waiting", "vended")
> vendingMachine =

`Try "hack"` won't compile,
because it's not a legal action described in [`vending-machine.txt`][vm spec].

>   do Try "pay"
>      Try "return"

`Try "vend"` won't compile,
because it's not a legal action *in this state*

>      Try "pay"
>      Try "select"
>      Try "vend"

> runVendingMachine : VendingMachineSession (a, b) -> List String
> runVendingMachine (x >>= rest) =
>     runVendingMachine x ++ runVendingMachine (rest True)
> runVendingMachine (Try x)   = [x]
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
