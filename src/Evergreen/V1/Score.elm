module Evergreen.V1.Score exposing (..)

import Evergreen.V1.Player
import Time


type alias Score =
    { player : Evergreen.V1.Player.Player
    , score : Int
    }


type alias SavedScore =
    { timestamp : Time.Posix
    , score : Score
    }
