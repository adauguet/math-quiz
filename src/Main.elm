module Main exposing (main)

import AgainstTheClock
import Browser
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Extra as Element
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Lives
import Multiplication exposing (Multiplication(..))
import NonEmpty exposing (NonEmpty)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { page : Page
    , tables : NonEmpty Int
    }


type Page
    = Home
    | AgainstTheClock AgainstTheClock.Model
    | Lives Lives.Model
    | Settings


init : () -> ( Model, Cmd Msg )
init _ =
    ( { page = Home
      , tables = NonEmpty.make 1 [ 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
      }
    , Cmd.none
    )


type Msg
    = LivesMsg Lives.Msg
    | AgainstTheClockMsg AgainstTheClock.Msg
    | ClickLives
    | ClickAgainstTheClock
    | RemoveTable Int
    | AddTable Int
    | ClickHome


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LivesMsg livesMsg ->
            case model.page of
                Lives livesModel ->
                    let
                        ( m, cmd ) =
                            Lives.update livesMsg livesModel
                    in
                    ( { model | page = Lives m }, Cmd.map LivesMsg cmd )

                _ ->
                    ( model, Cmd.none )

        AgainstTheClockMsg againstTheClockMsg ->
            case model.page of
                AgainstTheClock againstTheClockModel ->
                    let
                        ( m, cmd ) =
                            AgainstTheClock.update againstTheClockMsg againstTheClockModel
                    in
                    ( { model | page = AgainstTheClock m }, Cmd.map AgainstTheClockMsg cmd )

                _ ->
                    ( model, Cmd.none )

        ClickLives ->
            let
                ( m, cmd ) =
                    Lives.init model.tables
            in
            ( { model | page = Lives m }, Cmd.map LivesMsg cmd )

        ClickAgainstTheClock ->
            let
                ( m, cmd ) =
                    AgainstTheClock.init model.tables
            in
            ( { model | page = AgainstTheClock m }, Cmd.map AgainstTheClockMsg cmd )

        RemoveTable table ->
            case NonEmpty.filter (\x -> x /= table) model.tables of
                Just tables ->
                    ( { model | tables = tables }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        AddTable table ->
            let
                tables =
                    NonEmpty.append table model.tables
            in
            ( { model | tables = tables }, Cmd.none )

        ClickHome ->
            ( { model | page = Home }, Cmd.none )


view : Model -> Html Msg
view model =
    Element.layoutWith
        { options =
            [ Element.focusStyle
                { borderColor = Nothing
                , backgroundColor = Nothing
                , shadow = Nothing
                }
            ]
        }
        [ Font.family [ Font.typeface "Bubblegum Sans" ]
        , Font.size 32
        ]
    <|
        case model.page of
            Home ->
                Element.column
                    [ Element.centerX
                    , Element.centerY
                    , Element.spacing 100
                    ]
                    [ tablesView model.tables
                    , Input.button
                        [ Border.width 1
                        , Border.rounded 3
                        , Element.paddingXY 12 6
                        ]
                        { onPress = Just ClickLives
                        , label = Element.text "3 vies"
                        }
                    , Input.button
                        [ Border.width 1
                        , Border.rounded 3
                        , Element.paddingXY 12 6
                        ]
                        { onPress = Just ClickAgainstTheClock
                        , label = Element.text "Contre la montre"
                        }
                    ]

            Lives livesModel ->
                Lives.view
                    { toParentMsg = LivesMsg
                    , onClickRestart = ClickLives
                    , onClickHome = ClickHome
                    }
                    livesModel

            AgainstTheClock againstTheClockModel ->
                AgainstTheClock.view
                    { toParentMsg = AgainstTheClockMsg
                    , onClickRestart = ClickAgainstTheClock
                    , onClickHome = ClickHome
                    }
                    againstTheClockModel

            Settings ->
                Element.text "Settings"


tablesView : NonEmpty Int -> Element Msg
tablesView tables =
    Element.row
        [ Element.spacing 10 ]
        (List.map
            (\int ->
                let
                    attributes =
                        [ Element.width (Element.px 60)
                        , Element.height (Element.px 50)
                        , Border.rounded 5
                        , Font.center
                        , Font.size 24
                        , Font.color Element.white
                        ]
                in
                if NonEmpty.member int tables then
                    Input.button
                        (Background.color (Element.hsl 217 1 0.5) :: attributes)
                        { onPress = Just <| RemoveTable int
                        , label = Element.text <| String.fromInt int
                        }

                else
                    Input.button
                        (Background.color Element.gray :: attributes)
                        { onPress = Just <| AddTable int
                        , label = Element.text <| String.fromInt int
                        }
            )
            (List.range 1 10)
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        AgainstTheClock _ ->
            AgainstTheClock.subscriptions |> Sub.map AgainstTheClockMsg

        _ ->
            Sub.none
