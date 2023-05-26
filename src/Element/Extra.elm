module Element.Extra exposing
    ( gray
    , hsl
    , white
    )

import Element exposing (Color)


hsl : Float -> Float -> Float -> Color
hsl hue saturation lightness =
    let
        c =
            (1 - abs (2 * lightness - 1)) * saturation

        x =
            c * (1 - abs (fractionalModBy2 (hue / 60) - 1))

        m =
            lightness - c / 2

        ( r, g, b ) =
            if hue < 60 then
                ( c, x, 0 )

            else if hue < 120 then
                ( x, c, 0 )

            else if hue < 180 then
                ( 0, c, x )

            else if hue < 240 then
                ( 0, x, c )

            else if hue < 300 then
                ( x, 0, c )

            else
                ( c, 0, x )
    in
    Element.rgb (r + m) (g + m) (b + m)


fractionalModBy2 : Float -> Float
fractionalModBy2 x =
    x - 2 * toFloat (floor (x / 2))


white : Color
white =
    Element.rgb255 255 255 255


gray : Color
gray =
    hsl 0 0 0.5
