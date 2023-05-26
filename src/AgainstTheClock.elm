module AgainstTheClock exposing (..)

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Extra as Element
import Element.Font as Font
import Element.Input as Input
import Multiplication exposing (Multiplication(..))
import NonEmpty exposing (NonEmpty)
import Random
import Time


type alias Model =
    { state : State
    , tables : NonEmpty Int
    , score : Int
    , remainingTime : Int
    }


type State
    = Loading
    | Playing Multiplication
    | GameOver


init : NonEmpty Int -> ( Model, Cmd Msg )
init tables =
    ( { state = Loading
      , tables = tables
      , score = 0
      , remainingTime = 60
      }
    , generateMultiplication tables
    )


type Msg
    = GotMultiplication Multiplication
    | Select Int
    | Tick


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotMultiplication multiplication ->
            ( { model | state = Playing multiplication }, Cmd.none )

        Select answer ->
            case model.state of
                Loading ->
                    ( model, Cmd.none )

                Playing (Multiplication a b _) ->
                    if answer == a * b then
                        ( { model
                            | state = Loading
                            , score = model.score + 1
                          }
                        , generateMultiplication model.tables
                        )

                    else
                        ( { model | state = GameOver }, Cmd.none )

                GameOver ->
                    ( model, Cmd.none )

        Tick ->
            let
                newTime =
                    model.remainingTime - 1
            in
            if newTime <= 0 then
                ( { model | state = GameOver }, Cmd.none )

            else
                ( { model | remainingTime = newTime }, Cmd.none )


generateMultiplication : NonEmpty Int -> Cmd Msg
generateMultiplication tables =
    Random.generate GotMultiplication (Multiplication.generator tables)


view :
    { toParentMsg : Msg -> msg
    , onClickRestart : msg
    , onClickHome : msg
    }
    -> Model
    -> Element msg
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
                    , Element.el [ Element.alignRight ] <|
                        Element.text <|
                            String.fromInt model.score
                    ]
                , Element.text <| String.fromInt table ++ " x " ++ String.fromInt int ++ " ="
                , Element.row [ Element.spacing 50 ]
                    (List.map
                        (\n ->
                            Input.button
                                [ Element.width (Element.px 100)
                                , Element.height (Element.px 80)
                                , Border.rounded 5
                                , Font.center
                                , Font.size 32
                                , Font.center
                                , Element.centerX
                                , Border.rounded 12
                                , Background.color <| Element.hsl 212 1 0.47
                                , Font.color <| Element.white
                                , Element.mouseOver
                                    [ Element.moveUp 2
                                    , Border.shadow
                                        { offset = ( 0, 6 )
                                        , size = 0
                                        , blur = 0
                                        , color = Element.hsl 207 1 0.32
                                        }
                                    ]
                                , Border.shadow
                                    { offset = ( 0, 4 )
                                    , size = 0
                                    , blur = 0
                                    , color = Element.hsl 207 1 0.32
                                    }
                                ]
                                { onPress = Just <| toParentMsg (Select n)
                                , label = Element.text <| String.fromInt n
                                }
                        )
                        list
                    )
                , Input.button
                    [ Font.size 30
                    , Border.width 1
                    , Border.rounded 3
                    , Element.paddingXY 20 10
                    ]
                    { onPress = Just onClickHome
                    , label = Element.text "Quitter"
                    }
                ]

        GameOver ->
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
                  <|
                    Element.text <|
                        "Score : "
                            ++ String.fromInt model.score
                , Element.column [ Element.spacing 20 ]
                    [ Input.button buttonAttributes
                        { onPress = Just onClickRestart
                        , label = Element.text "Recommencer"
                        }
                    , Input.button buttonAttributes
                        { onPress = Just onClickHome
                        , label = Element.text "Menu"
                        }
                    ]
                ]


buttonAttributes : List (Element.Attr () msg)
buttonAttributes =
    [ Font.size 32
    , Element.width Element.fill
    , Font.center
    , Element.centerX
    , Border.rounded 12
    , Element.paddingXY 42 12
    , Background.color <| Element.hsl 345 1 0.47
    , Font.color <| Element.white
    , Element.mouseOver
        [ Element.moveUp 2
        , Border.shadow
            { offset = ( 0, 6 )
            , size = 0
            , blur = 0
            , color = Element.hsl 340 1 0.32
            }
        ]
    , Border.shadow
        { offset = ( 0, 4 )
        , size = 0
        , blur = 0
        , color = Element.hsl 340 1 0.32
        }
    ]


subscriptions : Sub Msg
subscriptions =
    Time.every 1000 (\_ -> Tick)