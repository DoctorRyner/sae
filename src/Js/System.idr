module Js.System

import Js.FFI
import Js.Array

%foreign (js "() => process.argv")
prim__getArgs : PrimIO (Array String)

export
getArgs : IO (List String)
getArgs = toList <$> primIO prim__getArgs

%foreign (node "str => require('shelljs').exec(str).code")
prim__system : String -> PrimIO Double

export
system : String -> IO Double
system = primIO . prim__system

%foreign (node "() => process.env.HOME")
prim__getHomeDir : PrimIO String

export
getHomeDir : IO String
getHomeDir = primIO prim__getHomeDir