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

> %provide (DoorSession : (Route -> Type)) with Protocol "door.txt"

> ||| Ring the doorbell.
> ||| @ n the number of times to ring
> Ring : (n : Nat) -> DoorSession ("closed", const "closed")
> Ring (S remaining) = do
>   Do "ring"
>   Ring remaining
> Ring Z = do
>   NoOp

> ||| An implementation of the protocol.
> Door : Nat -> DoorSession ("closed", const "closed")
> Door (S retries) = do

`Try "smash"` wouldn't compile, because it's not a legal action described in [`door.txt`][door spec].

>   Ring 3
>   Success <- Try "open" | Failure => NoOp
>   Do "close"
> Door Z = do
>   NoOp

`Try "close"` wouldn't compile, because it's not a legal action *in this state*.

> ||| Interpret a DoorSession, assuming happy path.
> runDoor : DoorSession _ -> List String
> runDoor NoOp             = []
> runDoor (Do x)           = [x]
> runDoor (Try x)          = [x]
> runDoor (x >>= continue) = (runDoor x) ++ (runDoor $ continue Success)

== Vending Machine Example

Define a session type that enforces valid interactions with a vending machine.

> %provide (VendingMachineSession : (Route -> Type)) with Protocol "vending-machine.txt"

> ||| An implementation of the protocol.
> vendingMachine : VendingMachineSession ("waiting", const "vended")
> vendingMachine = do

`Try "hack"` wouldn't compile, because it's not a legal action described in [`vending-machine.txt`][vm spec].

>   Do "pay"
>   Do "return"

`Try "vend"` wouldn't compile, because it's not a legal action *in this state*

>   Do "pay"
>   Do "select"
>   Do "vend"

> ||| Interpret a VendingMachineSession, assuming happy path.
> runVendingMachine : VendingMachineSession _ -> List String
> runVendingMachine NoOp             = []
> runVendingMachine (Do x)           = [x]
> runVendingMachine (Try x)          = [x]
> runVendingMachine (x >>= continue) = (runVendingMachine x) ++ (runVendingMachine $ continue Success)

== Main Executable

> namespace Main
>
>   private runExample : (name : String) -> (results : List String) -> IO ()
>   runExample name results =
>       do putStrLn $ unwords [ "===>", name, "Example" ]
>          putStrLn $ unwords results
>
>   %access export
>
>   main : IO ()
>   main = do
>     runExample "Door" $ runDoor (Door 3)
>     runExample "Vending Machine" $ runVendingMachine vendingMachine

 <!-- Named Links -->

[door spec]: ./door.txt
[vm spec]: ./vending-machine.txt
