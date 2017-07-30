||| A non-abstracted version of the Door protocol.
module Door

%default total

||| Third person: the protocol itself.
data Command : (String, String) -> Type where
     Open  : Command ("closed", "opened")
     Close : Command ("opened", "closed")
     Knock : Command ("closed", "closed")

     (>>=) : Command (beginning, middle) ->
             (() -> Command (middle, end)) ->
             Command (beginning, end)

||| First person: our implementation of the protocol.
session : Command ("closed", "closed")
session = do Knock
             Open
          -- Knock
             Close

||| Second person: an evaluator for our implementation.
run : Command _ -> List String
run Open  = ["open"]
run Close = ["close"]
run Knock = ["knock"]
run (command >>= continue) =
  (run command) ++ (run $ continue ())
