module Js.Dom

import Js.FFI

export
data HtmlElement : Type where [external]

%foreign (browser "x => document.getElementById(x)")
prim__getElementById : String -> PrimIO HtmlElement

export
getElementById : String -> IO HtmlElement
getElementById = primIO . prim__getElementById
