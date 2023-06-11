module Evergreen.V1.NonEmpty exposing (..)


type NonEmpty a
    = NonEmpty a (List a)
