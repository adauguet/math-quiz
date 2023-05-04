module Main exposing (generator, main)

import Browser
import Element
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
    { multiplication : Maybe Multiplication }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { multiplication = Nothing }, Random.generate GotMultiplication generator )


type Msg
    = GotMultiplication Multiplication
    | Select Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotMultiplication multiplication ->
            ( { multiplication = Just multiplication }, Cmd.none )

        Select answer ->
            case model.multiplication of
                Just (Multiplication a b _) ->
                    if answer == a * b then
                        ( { multiplication = Nothing }, Random.generate GotMultiplication generator )

                    else
                        ( model, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )


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
                    [ Element.text <| String.fromInt table ++ " x " ++ String.fromInt int
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


type Multiplication
    = Multiplication Int Int (List Int)


generator : Generator Multiplication
generator =
    let
        unique =
            Set.fromList >> Set.toList
    in
    Random.map2 (\table int -> ( table, int )) (Random.int 1 10) (Random.int 1 10)
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
