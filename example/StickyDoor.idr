||| A fallible version of the Door protocol.
module StickyDoor

%default total

||| Third person: the protocol itself.
data Command : (String, Bool -> String) -> Type where
     Open    : Command ("closed", \success => if success then "opened" else "closed")
     Close   : Command ("opened", const "closed")
     Knock   : Command ("closed", const "closed")
     Nothing : Command (a, const a)

     (>>=)   : Command (beginning, decide) ->
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
run _ Open    = ["open"]
run _ Close   = ["close"]
run _ Knock   = ["knock"]
run _ Nothing = []
run [] _      = []
run (result :: results) (command >>= continue) =
  (run [] command) ++ (run results $ continue result)


||| Alternative first person: keep trying.
persistent : Nat -> Command ("closed", const "closed")
persistent (S knocks) = do
  success <- Open
  case success of
    True  => Close
    False => persistent knocks
persistent Z = do
  Nothing
