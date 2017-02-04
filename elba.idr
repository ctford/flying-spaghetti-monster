module Main

mutual

  data Locked : Nat -> Type where
    Start  : (code : Nat) -> Locked code
    Lock   : (code : Nat) -> Closed -> Locked code

  data Closed : Type where
    Unlock : (code : Nat) -> Locked code -> Closed

  data Opened = Open Closed
