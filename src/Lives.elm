module Lives exposing (..)

import Element exposing (Element)
import Element.Extra as Element
import Element.Font as Font
import Multiplication exposing (Multiplication(..))
import NonEmpty exposing (NonEmpty)
import Random exposing (Generator)
import UI


type alias Model =
    { state : State
    , tables : NonEmpty Int
    , answered : List ( Multiplication, Int )
    }


score : List ( Multiplication, Int ) -> Int
score answered =
    answered
        |> List.filter (\( Multiplication a b _, answer ) -> a * b == answer)
        |> List.length


mistakes : List ( Multiplication, Int ) -> Int
mistakes answered =
    answered
        |> List.filter (\( Multiplication a b _, answer ) -> a * b /= answer)
        |> List.length


lives : List ( Multiplication, Int ) -> Int
lives answered =
    3 - mistakes answered


type State
    = Loading
    | Playing PlayingState Multiplication
    | GameOver (Maybe String)


type PlayingState
    = Idle
    | Answered Int


init : NonEmpty Int -> ( Model, Cmd Msg )
init tables =
    ( { state = Loading
      , tables = tables
      , answered = []
      }
    , generateMultiplication tables
    )


type Msg
    = GotMultiplication Multiplication
    | Select Int
    | Next
    | GotGameOverGif String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotMultiplication multiplication ->
            ( { model | state = Playing Idle multiplication }, Cmd.none )

        Select answer ->
            case model.state of
                Loading ->
                    ( model, Cmd.none )

                Playing Idle multiplication ->
                    let
                        m =
                            { model | answered = ( multiplication, answer ) :: model.answered }
                    in
                    if lives m.answered == 0 then
                        ( { m | state = GameOver Nothing }, generateGameOverGif )

                    else
                        ( { m | state = Playing (Answered answer) multiplication }, Cmd.none )

                Playing (Answered _) _ ->
                    ( model, Cmd.none )

                GameOver _ ->
                    ( model, Cmd.none )

        Next ->
            ( { model | state = Loading }, generateMultiplication model.tables )

        GotGameOverGif filePath ->
            case model.state of
                GameOver Nothing ->
                    ( { model | state = GameOver (Just filePath) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


generateMultiplication : NonEmpty Int -> Cmd Msg
generateMultiplication tables =
    Random.generate GotMultiplication (Multiplication.generator tables)


generateGameOverGif : Cmd Msg
generateGameOverGif =
    Random.generate GotGameOverGif gifGenerator


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

        Playing state (Multiplication a b list) ->
            Element.column
                [ Element.spacing 80
                , Element.centerX
                , Element.centerY
                , Element.paddingXY 30 30
                ]
                [ Element.row
                    [ Element.spacing 50
                    , Font.size 32
                    , Element.width Element.fill
                    ]
                    [ Element.text <| String.repeat (lives model.answered) "❤️" ++ String.repeat (3 - lives model.answered) "\u{1FA76}"
                    , Element.el [ Element.alignRight ] <|
                        Element.text <|
                            String.fromInt (score model.answered)
                    ]
                , Element.el [ Element.centerX, Font.size 64 ] <| Element.text <| String.fromInt a ++ " x " ++ String.fromInt b
                , Element.wrappedRow [ Element.spacing 20 ]
                    (List.map
                        (\option ->
                            case state of
                                Idle ->
                                    UI.blueButton
                                        [ Element.width (Element.px 100)
                                        , Element.height (Element.px 80)
                                        ]
                                        { onPress = toParentMsg (Select option)
                                        , label = String.fromInt option
                                        }

                                Answered answer ->
                                    UI.tile
                                        { label = String.fromInt option
                                        , backgroundColor =
                                            if option == a * b then
                                                UI.green

                                            else if option == answer then
                                                UI.red

                                            else
                                                UI.lightGray
                                        }
                        )
                        list
                    )
                , let
                    quitButton =
                        UI.redButton [ Element.alignLeft ]
                            { onPress = onClickHome
                            , label = "Quitter"
                            }
                  in
                  case state of
                    Idle ->
                        quitButton

                    Answered _ ->
                        Element.row [ Element.width Element.fill ]
                            [ quitButton
                            , UI.blueButton [ Element.alignRight ]
                                { onPress = toParentMsg Next
                                , label = "Continuer"
                                }
                            ]
                ]

        GameOver filePath ->
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
                , Element.image
                    [ Element.height (Element.fill |> Element.maximum 300)
                    , Element.centerX
                    ]
                    { src = filePath |> Maybe.withDefault "", description = "" }
                , Element.el
                    [ Font.size 30
                    , Element.centerX
                    ]
                  <|
                    Element.text <|
                        "Score : "
                            ++ String.fromInt (score model.answered)
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


gifGenerator : Generator String
gifGenerator =
    Random.uniform "judy-hopps-zootopia.gif"
        [ "zootopia-bunny.gif"
        , "zootopia-judy-2.gif"
        , "zootopia-judy-hopps.gif"
        , "zootopia-judy.gif"
        , "zootopia.gif"
        ]
        |> Random.map (\fileName -> "./img/" ++ fileName)
