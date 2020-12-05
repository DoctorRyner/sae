module Data.Yaml

public export
data Value = MkObject String String

public export
Show Value where
  show (MkObject key val) = "MkObject \"" ++ key ++ "\" \"" ++ val ++ "\""
