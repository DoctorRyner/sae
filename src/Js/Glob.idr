module Js.Glob

import Js.FFI

%foreign (node "path => __prim_js2idris_array(require('glob').glob.sync(path))")
prim__getFileNames : String -> PrimIO (List String)

export
getFileNames : String -> IO (List String)
getFileNames = primIO . prim__getFileNames