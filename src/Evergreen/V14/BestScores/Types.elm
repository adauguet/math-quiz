module Evergreen.V14.BestScores.Types exposing (..)

import Evergreen.V14.Score


type Model
    = Loading
    | Loaded (List Evergreen.V14.Score.SavedScore)


type Msg
    = GotScores (List Evergreen.V14.Score.SavedScore)
