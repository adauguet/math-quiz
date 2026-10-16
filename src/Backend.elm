module Backend exposing (app)

import Env exposing (..)
import Lamdera exposing (ClientId, SessionId, sendToFrontend)
import Score
import Task
import Time
import Types exposing (AgainstTheClockToFrontEnd(..), BackendModel, BackendMsg(..), ToBackend(..), ToFrontend(..))


app :
    { init : ( BackendModel, Cmd BackendMsg )
    , update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
    , updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
    , subscriptions : BackendModel -> Sub BackendMsg
    }
app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = subscriptions
        }


init : ( BackendModel, Cmd msg )
init =
    ( case Env.mode of
        Production ->
            []

        Development ->
            [ { timestamp = Time.millisToPosix 1
              , player = "Joseph"
              , score = 1
              }
            , { timestamp = Time.millisToPosix 2
              , player = "Joseph"
              , score = 2
              }
            , { timestamp = Time.millisToPosix 3
              , player = "Joseph"
              , score = 5
              }
            , { timestamp = Time.millisToPosix 4
              , player = "Joseph"
              , score = 3
              }
            , { timestamp = Time.millisToPosix 5
              , player = "Joseph"
              , score = 4
              }
            , { timestamp = Time.millisToPosix 6
              , player = "Thomas"
              , score = 4
              }
            ]
    , Cmd.none
    )


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg scores =
    case msg of
        GotTime clientId player score now ->
            ( { timestamp = now, player = player, score = score } :: scores, sendToFrontend clientId (AgainstTheClockToFrontEnd SavedScore) )

        GotScoresTime clientId now ->
            ( scores, sendToFrontend clientId (SendScores (List.filter (isSameWeek now) scores)) )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend _ clientId toBackend scores =
    case toBackend of
        SaveScore player score ->
            ( scores, Task.perform (GotTime clientId player score) Time.now )

        GetScores ->
            ( scores, Task.perform (GotScoresTime clientId) Time.now )


{-| Whether a score was saved during the week of `now`. Weeks start on Monday
at 00:00 UTC, so best scores reset every week. Older scores are kept.
-}
isSameWeek : Time.Posix -> Score.SavedScore -> Bool
isSameWeek now { timestamp } =
    Time.posixToMillis timestamp >= startOfWeek now


startOfWeek : Time.Posix -> Int
startOfWeek now =
    let
        dayMillis =
            24 * 60 * 60 * 1000

        days =
            Time.posixToMillis now // dayMillis

        -- The epoch, 1970-01-01, was a Thursday.
        daysSinceMonday =
            modBy 7 (days + 3)
    in
    (days - daysSinceMonday) * dayMillis


subscriptions : BackendModel -> Sub BackendMsg
subscriptions _ =
    Sub.none
