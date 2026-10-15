module Practice exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Env
import Html.Attributes
import Mistakes
import Multiplication exposing (Multiplication(..))
import NonEmpty exposing (NonEmpty(..))
import Practice.Types exposing (Msg(..), PlayingState(..), State(..))
import Random
import Time
import UI


type alias Model =
    Practice.Types.Model


type alias Msg =
    Practice.Types.Msg


init : NonEmpty Int -> ( Model, Cmd Msg )
init tables =
    let
        model =
            { state = Loading
            , tables = tables
            , mistakes = Mistakes.empty
            , answered = []
            , debug = False
            }
    in
    ( model, generateMultiplication model )


score : List ( Multiplication, Int ) -> Int
score answered =
    answered
        |> List.filter (\( Multiplication a b _, answer ) -> a * b == answer)
        |> List.length


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotMultiplication multiplication ->
            case model.state of
                Loading ->
                    ( { model | state = Playing Idle multiplication }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Select answer ->
            case model.state of
                Playing Idle ((Multiplication a b _) as multiplication) ->
                    let
                        isCorrect =
                            a * b == answer
                    in
                    ( { model
                        | answered = ( multiplication, answer ) :: model.answered
                        , mistakes = Mistakes.record ( a, b ) isCorrect model.mistakes
                        , state =
                            Playing
                                (Answered
                                    { answer = answer
                                    , since = 0
                                    , wait =
                                        if isCorrect then
                                            1000

                                        else
                                            5000
                                    }
                                )
                                multiplication
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        Next ->
            case model.state of
                Playing (Answered _) _ ->
                    next model

                _ ->
                    ( model, Cmd.none )

        GotTime delta ->
            case model.state of
                Playing (Answered ({ since, wait } as data)) multiplication ->
                    if since < wait then
                        ( { model | state = Playing (Answered { data | since = since + delta }) multiplication }, Cmd.none )

                    else
                        next model

                _ ->
                    ( model, Cmd.none )

        Restart ->
            case model.state of
                Finished ->
                    let
                        newModel =
                            { model | state = Loading, answered = [], mistakes = Mistakes.empty }
                    in
                    ( newModel, generateMultiplication newModel )

                _ ->
                    ( model, Cmd.none )

        Finish ->
            case model.state of
                Playing _ _ ->
                    ( { model | state = Finished }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ToggleDebug ->
            ( { model | debug = not model.debug }, Cmd.none )


next : Model -> ( Model, Cmd Msg )
next model =
    ( { model | state = Loading }, generateMultiplication model )


generateMultiplication : Model -> Cmd Msg
generateMultiplication model =
    Random.generate GotMultiplication (Mistakes.generator model.mistakes model.tables)


view :
    { toParentMsg : Msg -> msg
    , onClickHome : msg
    }
    -> Model
    -> Element msg
view config model =
    case ( Env.mode, model.state ) of
        ( Env.Development, Playing _ _ ) ->
            withDebug config model

        ( Env.Development, Finished ) ->
            withDebug config model

        _ ->
            gameView config model


withDebug :
    { toParentMsg : Msg -> msg
    , onClickHome : msg
    }
    -> Model
    -> Element msg
withDebug config model =
    Element.column
        [ Element.width Element.fill
        , Element.spacing 20
        , Element.paddingEach { top = 0, right = 0, bottom = 20, left = 0 }
        ]
        [ gameView config model
        , UI.grayButton [ Element.centerX ]
            { onPress = config.toParentMsg ToggleDebug
            , label =
                Element.text
                    (if model.debug then
                        "Masquer le debug"

                     else
                        "Debug"
                    )
            }
        , if model.debug then
            debugView model

          else
            Element.none
        ]


{-| Shows, for each multiplication, its number of mistakes, its weight and its
chance of being picked as the next question.
-}
debugView : Model -> Element msg
debugView model =
    let
        weights =
            Mistakes.weights model.mistakes model.tables

        total =
            List.sum (List.map Tuple.first weights)

        cellWidth =
            Element.px 56

        cellHeight =
            Element.px 72

        cell pair =
            let
                mistakeCount =
                    Mistakes.count pair model.mistakes
            in
            case List.filter (\( _, p ) -> p == pair) weights of
                ( w, _ ) :: _ ->
                    Element.column
                        [ Element.width cellWidth
                        , Element.height cellHeight
                        , Element.padding 8
                        , Element.spacing 6
                        , Border.rounded 4
                        , Background.color
                            (if mistakeCount > 0 then
                                UI.red

                             else
                                UI.lightGray
                            )
                        ]
                        [ Element.el [ Element.centerX, Font.bold ] (Element.text (String.fromFloat w))
                        , Element.el [ Element.centerX, Font.size 13 ]
                            (Element.text (percent (w / total)))
                        , Element.el [ Element.centerX, Font.size 13 ]
                            (Element.text (String.fromInt mistakeCount ++ " err."))
                        ]

                [] ->
                    -- Below the diagonal: already counted in `( b, a )`.
                    Element.el [ Element.width cellWidth, Element.height cellHeight ] Element.none

        header =
            Element.row [ Element.spacing 4 ]
                (Element.el [ Element.width cellWidth ] Element.none
                    :: List.map
                        (\b -> Element.el [ Element.width cellWidth ] (Element.el [ Element.centerX, Font.bold ] (Element.text (String.fromInt b))))
                        (List.range 1 10)
                )

        tableRow a =
            Element.row [ Element.spacing 4 ]
                (Element.el [ Element.width cellWidth, Element.height cellHeight, Font.bold ] (Element.el [ Element.centerY ] (Element.text (String.fromInt a ++ " x")))
                    :: List.map (\b -> cell ( a, b )) (List.range 1 10)
                )
    in
    Element.column
        [ Element.centerX
        , Element.spacing 6
        , Element.padding 10
        , Element.width (Element.shrink |> Element.maximum 900)

        -- elm-ui sizes column children with `flex-basis: 0px` and
        -- `min-height: min-content`. Firefox gives a scrolling element an
        -- almost zero `min-content` height, which collapses the panel, so it
        -- starts from its content height instead. Not `Element.scrollbarX`,
        -- which also lets the panel shrink.
        , Element.htmlAttribute (Html.Attributes.style "overflow-x" "auto")
        , Element.htmlAttribute (Html.Attributes.style "flex-basis" "auto")
        , Element.htmlAttribute (Html.Attributes.style "flex-shrink" "0")
        , Font.size 14
        ]
        (Element.text "Poids, chance d'être tiré et nombre d'erreurs (prochaine question)"
            :: header
            :: List.map tableRow (tablesList model.tables)
        )


tablesList : NonEmpty Int -> List Int
tablesList (NonEmpty table tables) =
    List.sort (table :: tables)


percent : Float -> String
percent ratio =
    String.fromFloat (toFloat (round (ratio * 1000)) / 10) ++ " %"


gameView :
    { toParentMsg : Msg -> msg
    , onClickHome : msg
    }
    -> Model
    -> Element msg
gameView { toParentMsg, onClickHome } model =
    case model.state of
        Loading ->
            loadingView

        Playing state (Multiplication a b list) ->
            Element.column
                [ Element.spacing 60
                , Element.centerX
                , Element.paddingXY 30 30
                ]
                [ Element.row
                    [ Element.spacing 50
                    , Font.size 32
                    , Element.width Element.fill
                    ]
                    [ Element.text <|
                        "Question "
                            ++ String.fromInt
                                (case state of
                                    Idle ->
                                        List.length model.answered + 1

                                    Answered _ ->
                                        List.length model.answered
                                )
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
                            { onPress = toParentMsg Finish
                            , label = Element.text "Terminer"
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

        Finished ->
            Element.column
                [ Element.centerX
                , Element.centerY
                , Element.spacing 50
                , Element.paddingXY 10 20
                ]
                [ Element.el
                    [ Font.size 30
                    , Element.centerX
                    ]
                    (Element.text <|
                        "Score : "
                            ++ String.fromInt (score model.answered)
                            ++ " / "
                            ++ String.fromInt (List.length model.answered)
                    )
                , case Mistakes.mostFrequent 5 model.mistakes of
                    [] ->
                        Element.el [ Element.centerX ] (Element.text "Rien à revoir, bravo !")

                    mostFrequent ->
                        Element.column [ Element.centerX, Element.spacing 10 ]
                            (Element.el [ Element.centerX ] (Element.text "À revoir :")
                                :: List.map
                                    (\( ( a, b ), _ ) ->
                                        Element.el [ Element.centerX, Font.color UI.red ]
                                            (Element.text (String.fromInt a ++ " x " ++ String.fromInt b ++ " = " ++ String.fromInt (a * b)))
                                    )
                                    mostFrequent
                            )
                , Element.column [ Element.spacing 20, Element.centerX ]
                    [ UI.blueButton [ Element.width Element.fill ]
                        { onPress = toParentMsg Restart
                        , label = Element.text "Recommencer"
                        }
                    , UI.blueButton [ Element.width Element.fill ]
                        { onPress = onClickHome
                        , label = Element.text "Menu"
                        }
                    ]
                ]


loadingView : Element msg
loadingView =
    Element.column
        [ Element.centerX
        , Element.centerY
        ]
        [ Element.text "Chargement ..." ]


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.state of
        Playing (Answered _) _ ->
            Time.every 5 (\_ -> GotTime 5)

        _ ->
            Sub.none
