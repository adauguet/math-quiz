module Evergreen.V1.BestScores.Types exposing (..)

import Evergreen.V1.Score


type alias Model =
    List Evergreen.V1.Score.SavedScore


type Msg
    = GotScores (List Evergreen.V1.Score.SavedScore)
