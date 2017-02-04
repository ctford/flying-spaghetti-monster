module Main

data State = Closed | Opened
data Command : Type -> State -> State -> Type
where
  Open  : Command () Closed Opened
  Close : Command () Opened Closed
  Ring  : Command () Closed Closed
  Pure  : a -> Command a state state
  (>>=) : Command a s1 s2 -> (a -> Command b s2 s3) -> Command b s1 s3
