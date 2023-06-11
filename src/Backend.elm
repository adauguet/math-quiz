module Backend exposing (app)

import Env exposing (..)
import Lamdera exposing (ClientId, SessionId, sendToFrontend)
import Player exposing (Player(..))
import Task
import Time
import Types exposing (BackendModel, BackendMsg(..), ToBackend(..), ToFrontend(..))


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
              , score = { player = Joseph, score = 1 }
              }
            , { timestamp = Time.millisToPosix 2
              , score = { player = Joseph, score = 2 }
              }
            , { timestamp = Time.millisToPosix 3
              , score = { player = Joseph, score = 5 }
              }
            , { timestamp = Time.millisToPosix 4
              , score = { player = Joseph, score = 3 }
              }
            , { timestamp = Time.millisToPosix 5
              , score = { player = Joseph, score = 4 }
              }
            , { timestamp = Time.millisToPosix 6
              , score = { player = Thomas, score = 4 }
              }
            ]
    , Cmd.none
    )


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg scores =
    case msg of
        GotTime score now ->
            ( { timestamp = now, score = score } :: scores, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend _ clientId toBackend scores =
    case toBackend of
        SaveScore score ->
            ( scores, Task.perform (GotTime score) Time.now )

        GetScores ->
            ( scores, sendToFrontend clientId (SendScores scores) )


subscriptions : BackendModel -> Sub BackendMsg
subscriptions _ =
    Sub.none
