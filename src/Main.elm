module Main exposing (generator, main)

import Browser
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
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
    { multiplication : Maybe Multiplication
    , tables : NonEmpty Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        tables =
            NonEmpty 1 [ 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
    in
    ( { multiplication = Nothing
      , tables = tables
      }
    , Random.generate GotMultiplication (generator tables)
    )


type Msg
    = GotMultiplication Multiplication
    | Select Int
    | RemoveTable Int
    | AddTable Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotMultiplication multiplication ->
            ( { model | multiplication = Just multiplication }, Cmd.none )

        Select answer ->
            case model.multiplication of
                Just (Multiplication a b _) ->
                    if answer == a * b then
                        ( { model | multiplication = Nothing }, Random.generate GotMultiplication (generator model.tables) )

                    else
                        ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        RemoveTable table ->
            case filter (\x -> x /= table) model.tables of
                Just tables ->
                    ( { model | tables = tables }, Random.generate GotMultiplication (generator tables) )

                Nothing ->
                    ( model, Cmd.none )

        AddTable table ->
            let
                tables =
                    append table model.tables
            in
            ( { model | tables = tables }, Random.generate GotMultiplication (generator tables) )


view : Model -> Html Msg
view model =
    Element.layoutWith { options = [] } [ Font.size 48 ] <|
        case model.multiplication of
            Just (Multiplication table int list) ->
                Element.column
                    [ Element.centerX
                    , Element.centerY
                    , Element.spacing 50
                    ]
                    [ tablesView model.tables
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

            Nothing ->
                Element.text ""


tablesView : NonEmpty Int -> Element Msg
tablesView tables =
    Element.row [ Element.spacing 10 ]
        (List.map
            (\int ->
                if member int tables then
                    Input.button
                        [ Element.width (Element.px 100)
                        , Element.height (Element.px 80)
                        , Border.rounded 5
                        , Font.center
                        , Background.color (Element.rgb255 0 0 255)
                        , Font.color (Element.rgb255 255 255 255)
                        ]
                        { onPress = Just <| RemoveTable int
                        , label = Element.text <| String.fromInt int
                        }

                else
                    Input.button
                        [ Element.width (Element.px 100)
                        , Element.height (Element.px 80)
                        , Border.width 1
                        , Border.rounded 5
                        , Font.center
                        ]
                        { onPress = Just <| AddTable int
                        , label = Element.text <| String.fromInt int
                        }
            )
            (List.range 1 10)
        )


type Multiplication
    = Multiplication Int Int (List Int)


generator : NonEmpty Int -> Generator Multiplication
generator (NonEmpty n ns) =
    let
        unique =
            Set.fromList >> Set.toList
    in
    Random.map2 (\table int -> ( table, int )) (Random.uniform n ns) (Random.int 1 10)
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



-- NonEmpty


type NonEmpty a
    = NonEmpty a (List a)


member : a -> NonEmpty a -> Bool
member a (NonEmpty x xs) =
    a == x || List.member a xs


fromList : List a -> Maybe (NonEmpty a)
fromList list =
    case list of
        x :: xs ->
            Just (NonEmpty x xs)

        _ ->
            Nothing


toList : NonEmpty a -> List a
toList (NonEmpty x xs) =
    x :: xs


filter : (a -> Bool) -> NonEmpty a -> Maybe (NonEmpty a)
filter isIncluded =
    toList >> List.filter isIncluded >> fromList


append : a -> NonEmpty a -> NonEmpty a
append a (NonEmpty x xs) =
    NonEmpty a (x :: xs)
