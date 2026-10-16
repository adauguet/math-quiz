module Evergreen.V5.Score exposing (..)

import Time


type alias SavedScore =
    { timestamp : Time.Posix
    , player : String
    , score : Int
    }
