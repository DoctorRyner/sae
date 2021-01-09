module Js.Array

import Js.FFI

public export
data Array : Type -> Type where [external]

export
%foreign (js "() => []")
empty : Array a

export
%foreign (js "(_, x) => [x]")
singleton : a -> Array a

export
%foreign (js "(_, xs, ys) => xs.concat(ys)")
(++) : Array a -> Array a -> Array a

snoc : Array a -> a -> Array a
snoc xs a = xs ++ singleton a

%foreign (js "(_, n, xs) => xs.slice(Number(n))")
drop : Nat -> Array a -> Array a

export
tail : Array a -> Array a
tail = drop 1

export
%foreign (js "(_, i, xs) => xs[i]")
index : Nat -> Array a -> a

export
%foreign (js "(_, xs) => BigInt(xs.length)")
length : Array a -> Nat

export
head : Array a -> a
head = index 0

export
%foreign (js "(_, xs) => xs[xs.length - 1]")
last : Array a -> a

export
fromList : List a -> Array a
fromList [] = empty
fromList (x::xs) = singleton x ++ fromList xs

export
toList : Array a -> List a
toList xs =
  if length xs == 0
  then []
  else [head xs] ++ toList (tail xs)
