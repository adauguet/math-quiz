module AgainstTheClock exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , updateFromBackend
    , view
    )

import Element exposing (Element)
import Element.Extra as Element
import Element.Font as Font
import Element.Input as Input
import Lamdera exposing (sendToBackend)
import Multiplication exposing (Multiplication(..))
import NonEmpty exposing (NonEmpty)
import Random
import Time
import Types
    exposing
        ( AgainstTheClockMsg(..)
        , AgainstTheClockState(..)
        , AgainstTheClockToFrontEnd(..)
        , GameOverState(..)
        , ToBackend(..)
        )
import UI


type alias Model =
    Types.AgainstTheClockModel


init : NonEmpty Int -> ( Model, Cmd Msg )
init tables =
    ( { state = Loading
      , tables = tables
      , score = 0
      , remainingTime = 60
      }
    , generateMultiplication tables
    )


type alias Msg =
    Types.AgainstTheClockMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotMultiplication multiplication ->
            case model.state of
                Loading ->
                    ( { model | state = Playing multiplication }, Cmd.none )

                Playing _ ->
                    ( { model | state = Playing multiplication }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Select answer ->
            case model.state of
                Playing (Multiplication a b _) ->
                    if answer == a * b then
                        ( { model
                            | state = Loading
                            , score = model.score + 1
                          }
                        , generateMultiplication model.tables
                        )

                    else
                        ( { model | state = GameOver (Idle "") }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Tick ->
            case model.state of
                Playing _ ->
                    let
                        newTime =
                            model.remainingTime - 1
                    in
                    if newTime <= 0 then
                        ( { model | state = GameOver (Idle "") }, Cmd.none )

                    else
                        ( { model | remainingTime = newTime }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        DidInputPlayer player ->
            case model.state of
                GameOver _ ->
                    ( { model | state = GameOver (Idle player) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SubmitScore ->
            case model.state of
                GameOver (Idle "") ->
                    ( model, Cmd.none )

                GameOver (Idle player) ->
                    ( { model | state = GameOver Submitting }, sendToBackend (SaveScore player model.score) )

                _ ->
                    ( model, Cmd.none )


generateMultiplication : NonEmpty Int -> Cmd Msg
generateMultiplication tables =
    Random.generate GotMultiplication (Multiplication.generator tables)


view :
    { toParentMsg : Msg -> parentMsg
    , onClickRestart : parentMsg
    , onClickHome : parentMsg
    }
    -> Model
    -> Element parentMsg
view { toParentMsg, onClickRestart, onClickHome } model =
    case model.state of
        Loading ->
            Element.column
                [ Element.centerX
                , Element.centerY
                ]
                [ Element.text "Chargement ..." ]

        Playing (Multiplication table int list) ->
            Element.column
                [ Element.spacing 80
                , Element.centerX
                , Element.centerY
                , Element.padding 20
                , Element.width Element.fill
                ]
                [ Element.row
                    [ Element.spacing 50
                    , Font.size 32
                    , Element.width Element.fill
                    ]
                    [ Element.text (String.fromInt model.remainingTime)
                    , Element.el [ Element.alignRight ]
                        (Element.text <| String.fromInt model.score)
                    ]
                , Element.el [ Element.centerX, Font.size 64 ] <| Element.text <| String.fromInt table ++ " x " ++ String.fromInt int
                , Element.wrappedRow [ Element.spacing 20 ]
                    (List.map
                        (\n ->
                            UI.blueButton
                                [ Element.width (Element.px 100)
                                , Element.height (Element.px 80)
                                ]
                                { onPress = toParentMsg (Select n)
                                , label = String.fromInt n
                                }
                        )
                        list
                    )
                , UI.redButton [ Element.centerX ]
                    { onPress = onClickHome
                    , label = "Quitter"
                    }
                ]

        GameOver gameOverState ->
            Element.column
                [ Element.centerX
                , Element.centerY
                , Element.spacing 50
                , Element.padding 20
                ]
                [ Element.el
                    [ Font.heavy
                    , Element.centerX
                    , Font.color <| Element.hsl 345 1 0.47
                    , Font.size 64
                    , Font.shadow
                        { offset = ( 1, 2 )
                        , blur = 2
                        , color = Element.gray
                        }
                    , Font.family [ Font.typeface "VT323" ]
                    ]
                    (Element.text "GAME OVER")
                , Element.el
                    [ Font.size 30
                    , Element.centerX
                    ]
                    (Element.text <| "Score : " ++ String.fromInt model.score)
                , case gameOverState of
                    Idle player ->
                        Element.row [ Element.centerX, Element.spacing 20 ]
                            [ Input.text [ Element.width (Element.fill |> Element.maximum 200) ]
                                { onChange = DidInputPlayer >> toParentMsg
                                , text = player
                                , placeholder = Nothing
                                , label = Input.labelHidden "Nom du joueur"
                                }
                            , UI.blueButton []
                                { onPress = toParentMsg SubmitScore
                                , label = "Envoyer"
                                }
                            ]

                    Submitting ->
                        Element.el [ Element.centerX ] (Element.text "Envoi en cours ...")

                    Submitted ->
                        Element.el [ Element.centerX ] (Element.text "Score enregistré")
                , Element.column [ Element.spacing 20, Element.centerX ]
                    [ UI.blueButton [ Element.width Element.fill ]
                        { onPress = onClickRestart
                        , label = "Recommencer"
                        }
                    , UI.blueButton [ Element.width Element.fill ]
                        { onPress = onClickHome
                        , label = "Menu"
                        }
                    ]
                ]


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.state of
        Playing _ ->
            Time.every 1000 (\_ -> Tick)

        _ ->
            Sub.none


updateFromBackend : AgainstTheClockToFrontEnd -> Model -> ( Model, Cmd Msg )
updateFromBackend toFrontEnd model =
    case toFrontEnd of
        SavedScore ->
            ( { model | state = GameOver Submitted }, Cmd.none )
