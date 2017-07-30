module ProvidedDoor

import Data.FSM.Protocol
import Data.List

%language TypeProviders
%default total

%access public export


||| Third person: the protocol itself.
%provide (DoorSession : (Route -> Type)) with Protocol "door.txt"


||| First person: our implementation of the protocol.
Ring : (n : Nat) -> DoorSession ("closed", const "closed")
Ring (S remaining) = do
  Do "ring"
  Ring remaining
Ring Z = do
  Succeed

Door : Nat -> DoorSession ("closed", const "closed")
Door (S retries) = do
  Ring 3
  Success <- Try "open" | Failure => Door retries
  Do "close"
Door Z = do
  Fail


||| Second person: an evaluator for our implementation,
||| asking for user input when we hit a Try.
queryUser : IO Result
queryUser = do
  line <- getLine
  let result = if line == "y" then Success else Failure
  pure result

runDoor : DoorSession _ -> IO Result
runDoor Succeed          = pure Success
runDoor Fail             = pure Failure
runDoor (Do x)           = do
  putStrLn $ x ++ "!"
  pure Success
runDoor (Try x)          = do
  putStrLn $ x ++ "?"
  queryUser
runDoor (x >>= continue) = do
  result <- runDoor x
  runDoor $ continue result


namespace Main

  %access export

  example : String -> IO Result -> IO ()
  example eg session = do
    putStrLn ("Running the " ++ eg ++ " example... press 'y' to make an action succeed.")
    success <- session
    case success of
      Success => putStrLn "Success... :-)"
      Failure => putStrLn "Failure... :-("

  main : IO ()
  main = do
    example "Door" $ runDoor $ Door 3
    putStrLn "Finished!"
