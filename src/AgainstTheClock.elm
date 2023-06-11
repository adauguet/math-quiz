module AgainstTheClock exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Element exposing (Element)
import Element.Extra as Element
import Element.Font as Font
import Lamdera exposing (sendToBackend)
import Multiplication exposing (Multiplication(..))
import NonEmpty exposing (NonEmpty)
import Player exposing (Player(..))
import Random
import Time
import Types
    exposing
        ( AgainstTheClockMsg(..)
        , AgainstTheClockState(..)
        , ToBackend(..)
        )
import UI


type alias Model =
    Types.AgainstTheClockModel


init : NonEmpty Int -> ( Model, Cmd Msg )
init tables =
    ( { state = ChoosePlayer
      , tables = tables
      , score = 0
      , remainingTime = 60
      }
    , Cmd.none
    )


type alias Msg =
    Types.AgainstTheClockMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotMultiplication multiplication ->
            case model.state of
                Loading player ->
                    ( { model | state = Playing player multiplication }, Cmd.none )

                Playing player _ ->
                    ( { model | state = Playing player multiplication }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ClickedPlayer player ->
            ( { model | state = Loading player }, generateMultiplication model.tables )

        Select answer ->
            case model.state of
                Playing player (Multiplication a b _) ->
                    if answer == a * b then
                        ( { model
                            | state = Loading player
                            , score = model.score + 1
                          }
                        , generateMultiplication model.tables
                        )

                    else
                        let
                            score =
                                { player = player, score = model.score }
                        in
                        ( { model | state = GameOver player }, sendToBackend (SaveScore score) )

                _ ->
                    ( model, Cmd.none )

        Tick ->
            case model.state of
                Playing player _ ->
                    let
                        newTime =
                            model.remainingTime - 1
                    in
                    if newTime <= 0 then
                        let
                            score =
                                { player = player, score = model.score }
                        in
                        ( { model | state = GameOver player }, sendToBackend (SaveScore score) )

                    else
                        ( { model | remainingTime = newTime }, Cmd.none )

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
        Loading _ ->
            Element.column
                [ Element.centerX
                , Element.centerY
                ]
                [ Element.text "Chargement ..." ]

        ChoosePlayer ->
            let
                playerButton player =
                    UI.greenButton []
                        { onPress = toParentMsg <| ClickedPlayer player
                        , label = Player.toString player
                        }
            in
            Element.column
                [ Element.centerX
                , Element.centerY
                , Element.spacing 20
                ]
                [ Element.text "Choisis le joueur"
                , Element.row [ Element.spacing 10 ]
                    [ playerButton Joseph
                    , playerButton Thomas
                    ]
                ]

        Playing player (Multiplication table int list) ->
            Element.column
                [ Element.spacing 100
                , Element.centerX
                , Element.centerY
                ]
                [ Element.row
                    [ Element.spacing 50
                    , Font.size 32
                    , Element.width Element.fill
                    ]
                    [ Element.text (String.fromInt model.remainingTime)
                    , Element.row [ Element.alignRight, Element.spacing 10 ]
                        [ Element.text <| Player.toString player
                        , Element.el
                            [ Element.width (Element.px 50)
                            , Font.alignRight
                            ]
                            (Element.text <| String.fromInt model.score)
                        ]
                    ]
                , Element.text <| String.fromInt table ++ " x " ++ String.fromInt int ++ " ="
                , Element.row [ Element.spacing 20 ]
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

        GameOver _ ->
            Element.column
                [ Element.centerX
                , Element.centerY
                , Element.spacing 50
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
                , Element.column [ Element.spacing 20, Element.centerX ]
                    [ UI.redButton [ Element.width Element.fill ]
                        { onPress = onClickRestart
                        , label = "Recommencer"
                        }
                    , UI.redButton [ Element.width Element.fill ]
                        { onPress = onClickHome
                        , label = "Menu"
                        }
                    ]
                ]


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.state of
        Playing _ _ ->
            Time.every 1000 (\_ -> Tick)

        _ ->
            Sub.none
