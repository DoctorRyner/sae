module Data.Json.Types

public export
data Value
  = MkObject (List (String, Value))
  | MkArray (List Value)
  | MkString String
  | MkNumber Integer
  | MkBool Bool
  | MkNull

public export
Show Value where
  show (MkObject xs) = "MkObject " ++ show xs
  show (MkArray xs) = "MkArray " ++ show xs
  show (MkString x) = "MkString " ++ show x
  show (MkNumber x) = "MkNumber " ++ show x
  show (MkBool x) = "MkBool " ++ show x
  show MkNull = "MkNull"
