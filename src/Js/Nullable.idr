module Js.Nullable

import Js.FFI

public export
data Nullable : Type -> Type where [external]

export
%foreign (js "(t1, x) => x ? 0 : 1")
isNullInt : Nullable a -> Double

export
isNull : Nullable a -> Bool
isNull nullable = isNullInt nullable == 1.0

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