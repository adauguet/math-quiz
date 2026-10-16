module Evergreen.V14.Mistakes exposing (..)

import Dict


type alias Mistakes =
    Dict.Dict ( Int, Int ) Int
