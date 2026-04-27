module Lives exposing (..)

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Extra as Element
import Element.Font as Font
import Multiplication exposing (Multiplication(..))
import NonEmpty exposing (NonEmpty)
import Random exposing (Generator)
import Time
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
    | Answered
        { answer : Int
        , since : Int
        , wait : Int
        }


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
    | GotTime Int


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
                        ( { m
                            | state =
                                Playing
                                    (Answered
                                        { answer = answer
                                        , since = 0
                                        , wait = waitForAnswer multiplication answer
                                        }
                                    )
                                    multiplication
                          }
                        , Cmd.none
                        )

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

        GotTime delta ->
            case model.state of
                Playing (Answered ({ since, wait } as data)) multiplication ->
                    if since < wait then
                        ( { model | state = Playing (Answered { data | since = since + delta }) multiplication }, Cmd.none )

                    else
                        ( { model | state = Loading }, generateMultiplication model.tables )

                _ ->
                    ( model, Cmd.none )


waitForAnswer : Multiplication -> Int -> Int
waitForAnswer (Multiplication a b _) answer =
    if a * b == answer then
        1000

    else
        5000


generateMultiplication : NonEmpty Int -> Cmd Msg
generateMultiplication tables =
    Random.generate GotMultiplication (Multiplication.generator tables)


generateGameOverGif : Cmd Msg
generateGameOverGif =
    Random.generate GotGameOverGif gifGenerator


gifGenerator : Generator String
gifGenerator =
    Random.uniform "judy-hopps-zootopia.gif"
        [ "zootopia-bunny.gif"
        , "zootopia-judy-2.gif"
        , "zootopia-judy-hopps.gif"
        , "zootopia-judy.gif"
        , "zootopia.gif"
        ]


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
                                        , label = Element.text <| String.fromInt option
                                        }

                                Answered { answer } ->
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
                            , label = Element.text "Quitter"
                            }
                  in
                  case state of
                    Idle ->
                        quitButton

                    Answered { since, wait } ->
                        Element.row [ Element.width Element.fill, Element.spacing 10 ]
                            [ quitButton
                            , UI.blueButton
                                [ Element.behindContent
                                    (Element.row
                                        [ Element.height Element.fill
                                        , Element.width Element.fill
                                        , Element.clip
                                        , Border.rounded 12
                                        ]
                                        [ Element.el
                                            [ Background.color UI.darkBlue
                                            , Element.width (Element.fillPortion since)
                                            , Element.height Element.fill
                                            ]
                                            Element.none
                                        , Element.el
                                            [ Background.color UI.blue
                                            , Element.width (Element.fillPortion (wait - since))
                                            , Element.height Element.fill
                                            ]
                                            Element.none
                                        ]
                                    )
                                ]
                                { onPress = toParentMsg Next
                                , label = Element.text "Continuer"
                                }
                            ]
                ]

        GameOver filePath ->
            Element.column
                [ Element.centerX
                , Element.centerY
                , Element.spacing 50
                , Element.paddingXY 10 20
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
                    { src =
                        filePath
                            |> Maybe.map (\fp -> "./" ++ fp)
                            |> Maybe.withDefault ""
                    , description = ""
                    }
                , Element.el
                    [ Font.size 30
                    , Element.centerX
                    ]
                    (Element.text <| "Score : " ++ String.fromInt (score model.answered))
                , Element.column [ Element.centerX ]
                    (List.map
                        (\( Multiplication a b _, answer ) ->
                            let
                                color =
                                    if a * b == answer then
                                        UI.green

                                    else
                                        UI.red
                            in
                            Element.el
                                [ Font.color color
                                ]
                                (Element.text (String.fromInt a ++ " x " ++ String.fromInt b))
                        )
                        model.answered
                    )
                , Element.column [ Element.spacing 20, Element.centerX ]
                    [ UI.blueButton [ Element.width Element.fill ]
                        { onPress = onClickRestart
                        , label = Element.text "Recommencer"
                        }
                    , UI.blueButton [ Element.width Element.fill ]
                        { onPress = onClickHome
                        , label = Element.text "Menu"
                        }
                    ]
                ]


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.state of
        Playing (Answered _) _ ->
            -- Sub.none
            Time.every 5 (\_ -> GotTime 5)

        _ ->
            Sub.none
