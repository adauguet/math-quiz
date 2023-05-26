module Main exposing (main)

import AgainstTheClock
import Browser
import Element exposing (Element)
import Element.Extra as Element
import Element.Font as Font
import Html exposing (Html)
import Lives
import Multiplication exposing (Multiplication(..))
import NonEmpty exposing (NonEmpty)
import UI


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
                    , UI.button []
                        { onPress = ClickLives
                        , label = "3 vies"
                        , backgroundColor = Element.hsl 212 1 0.47
                        , shadowColor = Element.hsl 207 1 0.32
                        }
                    , UI.button []
                        { onPress = ClickAgainstTheClock
                        , label = "Contre la montre"
                        , backgroundColor = Element.hsl 212 1 0.47
                        , shadowColor = Element.hsl 207 1 0.32
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
    Element.wrappedRow
        [ Element.spacing 10 ]
        (List.map
            (\int ->
                if NonEmpty.member int tables then
                    UI.button []
                        { onPress = RemoveTable int
                        , label = String.fromInt int
                        , backgroundColor = Element.hsl 212 1 0.47
                        , shadowColor = Element.hsl 207 1 0.32
                        }

                else
                    UI.button []
                        { onPress = RemoveTable int
                        , label = String.fromInt int
                        , backgroundColor = Element.hsl 0 0 0.5
                        , shadowColor = Element.hsl 0 0 0.3
                        }
            )
            (List.range 1 10)
        )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        AgainstTheClock againstTheClockModel ->
            AgainstTheClock.subscriptions againstTheClockModel
                |> Sub.map AgainstTheClockMsg

        _ ->
            Sub.none
