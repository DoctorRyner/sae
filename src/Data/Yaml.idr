module Data.Yaml

public export
data Value = MkObject String String

public export
Show Value where
  show (MkObject key val) = "MkObject \"" ++ key ++ "\" \"" ++ val ++ "\""

public export
data Value2
  = MkObject2 (List (String, Value2))
  | MkArray (List Value2)
  | MkString String

public export
Show Value2 where
  show (MkObject2 xs) = "MkObject " ++ show xs
  show (MkArray xs) = "MkArray " ++ show xs
  show (MkString s) = "MkString " ++ show s
