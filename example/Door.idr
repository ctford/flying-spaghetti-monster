||| A non-abstracted version of the Door protocol.
module Door

%default total

data Command : (String, String) -> Type where
     Open  : Command ("closed", "opened")
     Close : Command ("opened", "closed")
     Knock : Command ("closed", "closed")

     (>>=) : Command (beginning, middle) ->
             (() -> Command (middle, end)) ->
             Command (beginning, end)

doorProg : Command ("closed", "closed")
doorProg = do Knock
              Open
           -- Knock
              Close
