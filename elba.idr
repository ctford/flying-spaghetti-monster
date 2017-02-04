module Main

mutual

  data Locked : Type where
    Start  : Locked
    Lock   : Closed -> Locked

  data Closed : Type where
    Close  : Opened -> Closed
    Unlock : Locked -> Closed

  data Opened : Type where
    Open   : Closed -> Opened
