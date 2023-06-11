module BestScores exposing (..)

import BestScores.Types as BestScores exposing (Msg(..))
import Element exposing (Element)
import Element.Font as Font
import Lamdera exposing (sendToBackend)
import Player
import Score
import Types exposing (ToBackend(..))
import UI


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


view : { onClickHome : parentMsg } -> Model -> Element parentMsg
view { onClickHome } scores =
    Element.column
        [ Element.centerX
        , Element.paddingXY 0 50
        , Element.spacing 50
        ]
        [ Element.el
            [ Element.width Element.fill
            , Font.center
            ]
            (Element.text "Meilleurs scores")
        , case scores of
            [] ->
                Element.text "Pas encore de scores !"

            list ->
                list
                    |> List.sortWith (flipped <| Score.compare)
                    |> List.take 10
                    |> List.map
                        (\{ score } ->
                            Element.row
                                [ Element.spacing 10
                                , Element.width Element.fill
                                ]
                                [ Element.text <| Player.toString score.player
                                , Element.el [ Element.alignRight ] <| Element.text <| String.fromInt score.score
                                ]
                        )
                    |> Element.column
                        [ Element.spacing 10
                        , Element.width Element.fill
                        ]
        , UI.redButton [ Element.centerX ]
            { onPress = onClickHome
            , label = "Retour au menu"
            }
        ]


flipped : (a -> a -> Order) -> a -> a -> Order
flipped compare a b =
    case compare a b of
        LT ->
            GT

        EQ ->
            EQ

        GT ->
            LT
