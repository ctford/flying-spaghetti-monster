||| A fallible version of the Door protocol.
module StickyDoor

%default total

||| Third person: the protocol itself.
data Session : (String, Bool -> String) -> Type where
     Open    : Session ("closed", \success => if success then "opened" else "closed")
     Close   : Session ("opened", const "closed")
     Knock   : Session ("closed", const "closed")
     Nothing : Session (a, const a)

     (>>=)   : Session (beginning, decide) ->
               ((result : Bool) -> Session (decide result, end)) ->
               Session (beginning, end)


||| First person: our implementation of the protocol.
session : Session ("closed", const "closed")
session = do
  success <- Open
  case success of
    True  => Close
    False => Knock


||| Second person: an evaluator for our implementation.
run : List Bool -> Session _ -> List String
run _ Open    = ["open"]
run _ Close   = ["close"]
run _ Knock   = ["knock"]
run _ Nothing = []
run [] _      = []
run (result :: results) (command >>= continue) =
  (run [] command) ++ (run results $ continue result)


||| Alternative first person: keep trying.
persistent : Nat -> Session ("closed", const "closed")
persistent (S knocks) = do
  success <- Open
  case success of
    True  => Close
    False => persistent knocks
persistent Z = do
  Nothing
