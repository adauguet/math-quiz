module Evergreen.V11.Mistakes exposing (..)

import Dict


type alias Mistakes =
    Dict.Dict ( Int, Int ) Int
