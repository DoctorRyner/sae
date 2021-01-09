module Js.Glob

import Js.FFI
import Js.Nullable

%foreign (node "path => __prim_js2idris_array([])")
prim__getFileNames : String -> PrimIO (Nullable (List String))

export
getFileNames : String -> IO (Nullable (List String))
getFileNames = primIO . prim__getFileNames