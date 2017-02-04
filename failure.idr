module Main

data State = Closed | Opened
data Command : (result : Type) -> State -> (result -> State) -> Type
where
  Open  : Command Bool Closed (\success => if success then Opened else Closed)
  Close : Command () Opened (const Closed)
  Ring  : Command () Closed (const Closed)
  Pure  : (result : type) -> Command type (decide result) decide
  (>>=) : Command a state decide ->
          ((result : a) -> Command b (decide result) decide_next) ->
          Command b state decide_next
