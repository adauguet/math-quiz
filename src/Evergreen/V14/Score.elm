module Evergreen.V14.Score exposing (..)

import Time


type alias SavedScore =
    { timestamp : Time.Posix
    , player : String
    , score : Int
    }
