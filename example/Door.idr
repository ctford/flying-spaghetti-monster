||| A non-abstracted version of the Door protocol.
module Door

%default total

||| Third person: the protocol itself.
data Session : (String, String) -> Type where
     Open  : Session ("closed", "opened")
     Close : Session ("opened", "closed")
     Knock : Session ("closed", "closed")

     (>>=) : Session (beginning, middle) ->
             (() -> Session (middle, end)) ->
             Session (beginning, end)


||| First person: our implementation of the protocol.
session : Session ("closed", "closed")
session = do
  Open
--Knock
  Close


||| Second person: an evaluator for our implementation.
run : Session _ -> List String
run Open  = ["open"]
run Close = ["close"]
run Knock = ["knock"]
run (command >>= continue) =
  (run command) ++ (run $ continue ())


||| Alternative first person: knock before entering.
polite : Nat -> Session ("closed", "closed")
polite Z = do
  Open
  Close
polite (S knocks) = do
  Knock
  polite knocks
--polite (S knocks)
