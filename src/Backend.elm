module Backend exposing (app)

import Lamdera
import Types exposing (BackendModel, BackendMsg(..))


app :
    { init : ( BackendModel, Cmd BackendMsg )
    , update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
    , updateFromFrontend : Lamdera.SessionId -> Lamdera.ClientId -> toBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
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
    ( { message = "" }, Cmd.none )


update : BackendMsg -> BackendModel -> ( BackendModel, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )


updateFromFrontend : Lamdera.SessionId -> Lamdera.ClientId -> toBackend -> BackendModel -> ( BackendModel, Cmd BackendMsg )
updateFromFrontend _ _ _ backendModel =
    ( backendModel, Cmd.none )


subscriptions : BackendModel -> Sub BackendMsg
subscriptions model =
    Sub.none
