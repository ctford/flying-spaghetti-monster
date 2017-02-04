module Main

mutual

  data Locked = Start | Lock Closed
  data Closed = Close Opened | Unlock Locked
  data Opened = Open Closed
