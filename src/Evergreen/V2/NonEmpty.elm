module Evergreen.V2.NonEmpty exposing (..)


type NonEmpty a
    = NonEmpty a (List a)
