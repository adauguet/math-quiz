module Evergreen.V5.BestScores.Types exposing (..)

import Evergreen.V5.Score


type Model
    = Loading
    | Loaded (List Evergreen.V5.Score.SavedScore)


type Msg
    = GotScores (List Evergreen.V5.Score.SavedScore)
