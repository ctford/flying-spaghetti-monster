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
>   Succeed

> ||| An implementation of the protocol.
> Door : Nat -> DoorSession ("closed", const "closed")
> Door (S retries) = do

`Try "smash"` wouldn't compile, because it's not a legal action described in [`door.txt`][door spec].

>   Ring 3
>   Success <- Try "open" | Failure => Door retries
>   Do "close"
> Door Z = do
>   Fail

`Try "close"` wouldn't compile, because it's not a legal action *in this state*.

> ||| Interpret a DoorSession, requesting input from the user on Try.
> runDoor : DoorSession _ -> IO Result
> runDoor Succeed          = do
>   pure Success
> runDoor Fail             = do
>   pure Failure
> runDoor (Do x)           = do
>   putStrLn $ x ++ "!"
>   pure Success
> runDoor (Try x)          = do
>   putStrLn $ x ++ "?"
>   line <- getLine
>   let result = if line == "y" then Success else Failure
>   pure result
> runDoor (x >>= continue) = do
>   result <- runDoor x
>   runDoor $ continue result

== Vending Machine Example

Define a session type that enforces valid interactions with a vending machine.

> %provide (VendingMachineSession : (Route -> Type)) with Protocol "vending-machine.txt"

> ||| An implementation of the protocol.
> vendingMachine : VendingMachineSession ("waiting", const "waiting")
> vendingMachine = do

`Try "hack"` wouldn't compile, because it's not a legal action described in [`vending-machine.txt`][vm spec].

>   Do "insert-coin"
>   Do "insert-coin"

`Try "vend"` wouldn't compile, because it's not a legal action *in this state*

>   Success <- Try "select" | Failure => Do "return"
>   Do "vend"

> ||| Interpret a VendingMachineSession, requesting input from the user on Try.
> runVendingMachine : VendingMachineSession _ -> IO Result
> runVendingMachine Succeed          = do
>   pure Success
> runVendingMachine Fail             = do
>   pure Failure
> runVendingMachine (Do x)           = do
>   putStrLn $ x ++ "!"
>   pure Success
> runVendingMachine (Try x)          = do
>   putStrLn $ x ++ "?"
>   line <- getLine
>   let result = if line == "y" then Success else Failure
>   pure result
> runVendingMachine (x >>= continue) = do
>   result <- runVendingMachine x
>   runVendingMachine $ continue result

== Main Executable

> namespace Main
>
>   %access export
>
>   main : IO ()
>   main = do
>     putStrLn "Running the Door example... press 'y' to make an action succeed."
>     success <- runDoor $ Door 3
>     case success of
>       Success => putStrLn "Entering..."
>       Failure => putStrLn "Giving up..."

 <!-- Named Links -->

[door spec]: ./door.txt
[vm spec]: ./vending-machine.txt
