||| A fallible version of the Door protocol.
module StickyDoor

%default total

||| Third person: the protocol itself.
data Command : (String, Bool -> String) -> Type where
     Open  : Command ("closed", \success => if success then "opened" else "closed")
     Close : Command ("opened", const "closed")
     Knock : Command ("closed", const "closed")

     (>>=) : Command (beginning, decide) ->
             ((result : Bool) -> Command (decide result, end)) ->
             Command (beginning, end)


||| First person: our implementation of the protocol.
session : Command ("closed", const "closed")
session = do
  success <- Open
  case success of
    True  => Close
    False => Knock


||| Second person: an evaluator for our implementation.
run : List Bool -> Command _ -> List String
run _ Open  = ["open"]
run _ Close = ["close"]
run _ Knock = ["knock"]
run [] _    = ["abort"]
run (result :: results) (command >>= continue) =
  (run [] command) ++ (run results $ continue result)
