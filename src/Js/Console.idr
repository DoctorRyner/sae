module Js.Console

import Js.FFI

%foreign (js "(_, x) => console.log(x)")
prim__log : a -> PrimIO ()

export
log : a -> IO ()
log = primIO . prim__log

%foreign (js "(_, x) => console.warn(x)")
prim__warn : a -> PrimIO ()

export
warn : a -> IO ()
warn = primIO . prim__warn

%foreign (js "(_, x) => console.error(x)")
prim__error : a -> PrimIO ()

export
error : a -> IO ()
error = primIO . prim__warn
