module BestScores exposing (..)

import BestScores.Types as BestScores exposing (Msg(..))
import Element exposing (Element)
import Lamdera exposing (sendToBackend)
import Player
import Types exposing (ToBackend(..))


type alias Model =
    BestScores.Model


init : ( Model, Cmd BestScores.Msg )
init =
    ( [], sendToBackend GetScores )


type alias Msg =
    BestScores.Msg


update : Msg -> Model
update msg =
    case msg of
        GotScores scores ->
            scores


view : Model -> Element msg
view scores =
    Element.column
        [ Element.centerX
        , Element.centerY
        , Element.spacing 20
        ]
        [ Element.text "Meilleurs scores"
        , scores
            |> List.map
                (\{ score } ->
                    Element.row [ Element.spacing 10 ]
                        [ Element.text <| Player.toString score.player
                        , Element.text <| String.fromInt score.score
                        ]
                )
            |> Element.column [ Element.spacing 10 ]
        ]
