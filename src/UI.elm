module UI exposing
    ( blue
    , blueButton
    , darkBlue
    , gray
    , grayButton
    , green
    , greenButton
    , lightGray
    , red
    , redButton
    , tile
    )

import Element exposing (Attribute, Color, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Extra as Element
import Element.Font as Font
import Element.Input as Input


red : Color
red =
    Element.hsl 345 1 0.47


darkRed : Color
darkRed =
    Element.hsl 340 1 0.32


green : Color
green =
    Element.hsl 130 1 0.38


darkGreen : Color
darkGreen =
    Element.hsl 130 1 0.28


blue : Color
blue =
    Element.hsl 212 1 0.47


darkBlue : Color
darkBlue =
    Element.hsl 207 1 0.32


lightGray : Color
lightGray =
    Element.hsl 0 0 0.7


gray : Color
gray =
    Element.hsl 0 0 0.5


darkGray : Color
darkGray =
    Element.hsl 0 0 0.3


greenButton : List (Attribute msg) -> { onPress : msg, label : Element msg } -> Element msg
greenButton attributes { onPress, label } =
    button attributes
        { onPress = onPress
        , label = label
        , backgroundColor = green
        , shadowColor = darkGreen
        }


blueButton : List (Attribute msg) -> { onPress : msg, label : Element msg } -> Element msg
blueButton attributes { onPress, label } =
    button attributes
        { onPress = onPress
        , label = label
        , backgroundColor = blue
        , shadowColor = darkBlue
        }


redButton : List (Attribute msg) -> { onPress : msg, label : Element msg } -> Element msg
redButton attributes { onPress, label } =
    button attributes
        { onPress = onPress
        , label = label
        , backgroundColor = red
        , shadowColor = darkRed
        }


grayButton : List (Attribute msg) -> { onPress : msg, label : Element msg } -> Element msg
grayButton attributes { onPress, label } =
    button attributes
        { onPress = onPress
        , label = label
        , backgroundColor = gray
        , shadowColor = darkGray
        }


button :
    List (Attribute msg)
    ->
        { onPress : msg
        , label : Element msg
        , backgroundColor : Color
        , shadowColor : Color
        }
    -> Element msg
button attributes { onPress, label, backgroundColor, shadowColor } =
    Input.button
        ([ Font.size 32
         , Font.center
         , Border.rounded 12
         , Element.paddingXY 24 12
         , Background.color backgroundColor
         , Font.color <| Element.white
         , Element.mouseDown
            [ Element.moveDown 4
            , Border.shadow
                { offset = ( 0, 2 )
                , size = 0
                , blur = 0
                , color = shadowColor
                }
            ]
         , Border.shadow
            { offset = ( 0, 6 )
            , size = 0
            , blur = 0
            , color = shadowColor
            }
         ]
            ++ attributes
        )
        { onPress = Just onPress
        , label = label
        }


tile :
    { label : String
    , backgroundColor : Color
    }
    -> Element msg
tile { label, backgroundColor } =
    Element.el
        [ Background.color backgroundColor
        , Border.rounded 12
        , Element.height (Element.px 80)
        , Element.width (Element.px 100)
        , Font.center
        , Font.color <| Element.white
        , Font.size 32
        ]
        (Element.el
            [ Element.centerX
            , Element.centerY
            ]
            (Element.text label)
        )
