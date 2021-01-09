module Js.Nullable

import Js.FFI

public export
data Nullable : Type -> Type where [external]

export
%foreign (js "(t1, x) => x ? true : false")
isNull : Nullable a -> Bool

export
%foreign (js "t1 => null")
null : Nullable a

export
fromNull : a -> Nullable a -> a
fromNull def nullable =
    if isNull nullable
    then def
    else unsafeCoerce nullable

export
unsafeFromNull : Nullable a -> a
unsafeFromNull = unsafeCoerce