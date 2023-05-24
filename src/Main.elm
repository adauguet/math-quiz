module Main exposing (generator, main)

import Browser
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import NonEmpty exposing (NonEmpty)
import Random exposing (Generator)
import Random.List
import Set


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


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


init : () -> ( Model, Cmd Msg )
init _ =
    let
        tables =
            NonEmpty.make 1 [ 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
    in
    ( { state = Loading
      , tables = tables
      , score = 0
      , lives = 3
      }
    , Random.generate GotMultiplication (generator tables)
    )


type Msg
    = GotMultiplication Multiplication
    | Select Int
    | RemoveTable Int
    | AddTable Int
    | Reset


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
                        , Random.generate GotMultiplication (generator model.tables)
                        )

                    else if model.lives > 1 then
                        ( { model | lives = model.lives - 1 }, Cmd.none )

                    else
                        ( { model | state = GameOver }, Cmd.none )

                GameOver ->
                    ( model, Cmd.none )

        RemoveTable table ->
            case NonEmpty.filter (\x -> x /= table) model.tables of
                Just tables ->
                    ( { model | tables = tables, score = 0, lives = 5 }, Random.generate GotMultiplication (generator tables) )

                Nothing ->
                    ( model, Cmd.none )

        AddTable table ->
            let
                tables =
                    NonEmpty.append table model.tables
            in
            ( { model | tables = tables, score = 0, lives = 5 }, Random.generate GotMultiplication (generator tables) )

        Reset ->
            ( { state = Loading
              , tables = model.tables
              , score = 0
              , lives = 5
              }
            , Random.generate GotMultiplication (generator model.tables)
            )


view : Model -> Html Msg
view model =
    Element.layoutWith { options = [] } [ Font.size 48 ] <|
        case model.state of
            Loading ->
                Element.none

            Playing (Multiplication table int list) ->
                Element.row
                    [ Element.spacing 50
                    , Element.width Element.fill
                    , Element.height Element.fill
                    ]
                    [ Element.el [ Element.paddingXY 50 50 ] <| tablesView model.tables
                    , Element.column
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
                                    Input.button
                                        [ Element.width (Element.px 100)
                                        , Element.height (Element.px 80)
                                        , Border.width 1
                                        , Border.rounded 5
                                        , Font.center
                                        ]
                                        { onPress = Just (Select n)
                                        , label = Element.text <| String.fromInt n
                                        }
                                )
                                list
                            )
                        ]
                    ]

            GameOver ->
                Element.column
                    [ Element.centerX
                    , Element.centerY
                    , Element.spacing 50
                    ]
                    [ Element.el [ Font.heavy ] <| Element.text "GAME OVER"
                    , Element.el [ Font.size 30, Element.centerX ] <| Element.text <| "Score : " ++ String.fromInt model.score
                    , Input.button
                        [ Font.size 30
                        , Element.centerX
                        , Border.width 1
                        , Border.rounded 3
                        , Element.paddingXY 20 10
                        ]
                        { onPress = Just Reset
                        , label = Element.text "Recommencer"
                        }
                    ]


tablesView : NonEmpty Int -> Element Msg
tablesView tables =
    Element.column [ Element.spacing 10 ]
        (List.map
            (\int ->
                let
                    attributes =
                        [ Element.width (Element.px 80)
                        , Element.height (Element.px 50)
                        , Border.rounded 5
                        , Font.center
                        , Font.size 24
                        ]
                in
                if NonEmpty.member int tables then
                    Input.button
                        (attributes
                            ++ [ Background.color (Element.rgb255 0 0 255)
                               , Font.color (Element.rgb255 255 255 255)
                               ]
                        )
                        { onPress = Just <| RemoveTable int
                        , label = Element.text <| String.fromInt int
                        }

                else
                    Input.button
                        (attributes
                            ++ [ Background.color (Element.rgb255 200 200 200)
                               , Font.color (Element.rgb255 255 255 255)
                               ]
                        )
                        { onPress = Just <| AddTable int
                        , label = Element.text <| String.fromInt int
                        }
            )
            (List.range 1 10)
        )


type Multiplication
    = Multiplication Int Int (List Int)


generator : NonEmpty Int -> Generator Multiplication
generator nonEmpty =
    let
        unique =
            Set.fromList >> Set.toList
    in
    Random.map2 (\table int -> ( table, int )) (NonEmpty.generator nonEmpty) (Random.int 1 10)
        |> Random.andThen
            (\( a, b ) ->
                Random.List.shuffle (answers a b |> unique)
                    |> Random.andThen (\list -> Random.List.shuffle (a * b :: (list |> List.take 3) |> unique))
                    |> Random.map (\list -> Multiplication a b list)
            )


answers : Int -> Int -> List Int
answers a b =
    [ a * b - 1
    , a * (b - 1)
    , a * (b + 1)
    , a * b + 1
    , a + b
    , (a - 1) * b
    , (a + 1) * b
    ]
