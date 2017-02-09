module Main
import Data.List
%language TypeProviders

--data A : a -> Type
--where The : (x : a) -> A x

data Selection : List a -> Type
where Select   : (x : a) ->
                 {xs : List a} ->
                 {auto p : Elem x xs} ->
                 Selection xs

State : Type
State = Selection ["locked", "closed", "opened"] 

Transition : Type
Transition = Selection [("locked", "closed"), ("closed", "locked"), ("closed", "opened")]

data Command : Type -> State -> State -> Type
where
  Open  : Command () (Select "closed") (Select "opened")
  Close : Command () (Select "opened") (Select "closed")
  Ring  : Command () (Select "closed") (Select "closed")
  Pure  : a -> Command a state state
  (>>=) : Command a s1 s2 -> (a -> Command b s2 s3) -> Command b s1 s3

doorProg : Command () (Select "closed") (Select "closed")
doorProg = do Ring
              Open
              Close

--opened : Type
--opened = Selection (A Void) ["closed"]

--tristate : List String -> List String -> List String -> (Type, Type, Type)
--tristate xs ys zs = (Selection xs, Selection ys, Selection zs)

--state : (String, List String) -> (String, Type)
--state (name, inbound) = (name, Selection inbound)

--data FSM : Type
--where
--  States : List State -> FSM

--door : FSM
--door = States [NodeAndEdges "foo" Selection ["bar", "baz"]]

--session : door
--session = ?foo

--member : Nat -> (n : Nat ** (Elem n [n, 2, 3]))
--member x = (x ** (the (Elem x [x, 2, 3]) Here))

--FsmType : String -> List String -> IO (Provider State)
--FsmType name names = pure $ Provide $ NodeAndEdges name names

-- %provide (fsm : State) with FsmType "foo" ["bar", "baz"]
