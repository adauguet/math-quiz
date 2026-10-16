module BestScores exposing (..)

import BestScores.Types as BestScores exposing (Model(..), Msg(..))
import Element exposing (Element)
import Element.Font as Font
import Lamdera exposing (sendToBackend)
import Score
import Types exposing (ToBackend(..))
import UI


type alias Model =
    BestScores.Model


init : ( Model, Cmd BestScores.Msg )
init =
    ( Loading, sendToBackend GetScores )


type alias Msg =
    BestScores.Msg


update : Msg -> Model
update msg =
    case msg of
        GotScores scores ->
            Loaded scores


view : { onClickHome : parentMsg } -> Model -> Element parentMsg
view { onClickHome } model =
    Element.column
        [ Element.centerX
        , Element.padding 50
        , Element.spacing 50
        , Element.height Element.fill
        ]
        [ Element.el
            [ Element.width Element.fill
            , Element.centerX
            , Font.center
            ]
            (Element.text "Meilleurs scores")
        , case model of
            Loading ->
                Element.el [ Element.centerX ] (Element.text "Chargement ...")

            Loaded [] ->
                Element.el [ Element.centerX ] (Element.text "Pas encore de scores !")

            Loaded list ->
                list
                    |> List.sortWith (flipped <| Score.compare)
                    |> List.take 10
                    |> List.map
                        (\{ player, score } ->
                            Element.row
                                [ Element.spacing 10
                                , Element.width Element.fill
                                ]
                                [ Element.text player
                                , Element.el [ Element.alignRight ] <| Element.text <| String.fromInt score
                                ]
                        )
                    |> Element.column
                        [ Element.spacing 10
                        , Element.width Element.fill
                        ]
        , UI.redButton [ Element.centerX, Element.alignBottom ]
            { onPress = onClickHome
            , label = Element.text "Retour au menu"
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
