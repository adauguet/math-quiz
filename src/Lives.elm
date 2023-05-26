module Lives exposing (..)

import Element exposing (Element)
import Element.Extra as Element
import Element.Font as Font
import Multiplication exposing (Multiplication(..))
import NonEmpty exposing (NonEmpty)
import Random
import UI


type alias Model =
    { state : State
    , tables : NonEmpty Int
    , score : Int
    , lives : Int
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
      , lives = 3
      }
    , generateMultiplication tables
    )


type Msg
    = GotMultiplication Multiplication
    | Select Int


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

                    else if model.lives > 1 then
                        ( { model | lives = model.lives - 1 }, Cmd.none )

                    else
                        ( { model | state = GameOver }, Cmd.none )

                GameOver ->
                    ( model, Cmd.none )


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
                    [ Element.row [] <| List.repeat model.lives (Element.text "❤️")
                    , Element.el [ Element.alignRight ] <|
                        Element.text <|
                            String.fromInt model.score
                    ]
                , Element.text <| String.fromInt table ++ " x " ++ String.fromInt int ++ " ="
                , Element.row [ Element.spacing 50 ]
                    (List.map
                        (\n ->
                            UI.button
                                [ Element.width (Element.px 100)
                                , Element.height (Element.px 80)
                                ]
                                { onPress = toParentMsg (Select n)
                                , label = String.fromInt n
                                , backgroundColor = Element.hsl 212 1 0.47
                                , shadowColor = Element.hsl 207 1 0.32
                                }
                        )
                        list
                    )
                , UI.button [ Element.centerX ]
                    { onPress = onClickHome
                    , label = "Quitter"
                    , backgroundColor = Element.hsl 345 1 0.47
                    , shadowColor = Element.hsl 340 1 0.32
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
                    [ UI.button [ Element.width Element.fill ]
                        { onPress = onClickRestart
                        , label = "Recommencer"
                        , backgroundColor = Element.hsl 345 1 0.47
                        , shadowColor = Element.hsl 340 1 0.32
                        }
                    , UI.button [ Element.width Element.fill ]
                        { onPress = onClickHome
                        , label = "Menu"
                        , backgroundColor = Element.hsl 345 1 0.47
                        , shadowColor = Element.hsl 340 1 0.32
                        }
                    ]
                ]
