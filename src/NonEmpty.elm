module NonEmpty exposing (NonEmpty, append, filter, generator, make, member)

import Random exposing (Generator)


type NonEmpty a
    = NonEmpty a (List a)


make : a -> List a -> NonEmpty a
make x xs =
    NonEmpty x xs


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


generator : NonEmpty a -> Generator a
generator (NonEmpty x xs) =
    Random.uniform x xs
