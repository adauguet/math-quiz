module Evergreen.V2.Score exposing (..)

import Time


type alias SavedScore =
    { timestamp : Time.Posix
    , player : String
    , score : Int
    }
