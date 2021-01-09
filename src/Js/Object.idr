module Js.Object

import Js.Array
import Js.FFI

public export
data Object : Type where [external]

export
%foreign (js "() => ({})")
empty : Object

export
%foreign (js "(_, key, val, obj) => {obj[key] = val; return obj}")
insert : String -> a -> Object -> Object

export
singleton : String -> a -> Object
singleton key val = insert key val empty

infix 10 =:

public export
(=:) : String -> a -> Object
(=:) = singleton

export
%foreign (js "xs => Object.assign({}, ...xs)")
merge : Array Object -> Object

export
fromList : List Object -> Object
fromList = merge . fromList
