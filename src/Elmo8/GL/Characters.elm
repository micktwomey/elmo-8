module Elmo8.GL.Characters exposing (..)

{-| Automatically generated list of characters

Converted from a font builder font.

- https://github.com/andryblack/fontbuilder
- `<Char width="8" offset="0 0" rect="79 12 6 10" code="A"/>`
- `{char="A",width=8,x=79,y=12,w=6,h=10,ox=0,oy=10}`
-}


type alias Character =
    { characterWidth : Int
    , offsetX : Int
    , offsetY : Int
    , x : Int
    , y : Int
    , width : Int
    , height : Int
    }


{-| Characters for the Elmo8 fonts
-}
characterList : List ( Char, Character )
characterList =
    [ ( ' ', Character 8 0 10 1 11 0 0 )
    , ( '!', Character 8 2 0 2 1 2 10 )
    , ( '"', Character 8 0 0 5 1 6 4 )
    , ( '#', Character 8 0 0 12 1 6 10 )
    , ( '$', Character 8 0 0 19 1 6 10 )
    , ( '%', Character 8 0 0 26 1 6 10 )
    , ( '&', Character 8 0 0 33 1 6 10 )
    , ( '\'', Character 8 0 0 40 1 4 4 )
    , ( '(', Character 8 0 0 45 1 4 10 )
    , ( ')', Character 8 2 0 50 1 4 10 )
    , ( '*', Character 8 0 0 55 1 6 10 )
    , ( '+', Character 8 0 2 62 3 6 6 )
    , ( ',', Character 8 0 6 69 7 4 4 )
    , ( '-', Character 8 0 4 74 5 6 2 )
    , ( '.', Character 8 2 8 81 9 2 2 )
    , ( '/', Character 8 0 0 84 1 6 10 )
    , ( '0', Character 8 0 0 91 1 6 10 )
    , ( '1', Character 8 0 0 98 1 6 10 )
    , ( '2', Character 8 0 0 105 1 6 10 )
    , ( '3', Character 8 0 0 112 1 6 10 )
    , ( '4', Character 8 0 0 119 1 6 10 )
    , ( '5', Character 8 0 0 1 12 6 10 )
    , ( '6', Character 8 0 0 8 12 6 10 )
    , ( '7', Character 8 0 0 15 12 6 10 )
    , ( '8', Character 8 0 0 22 12 6 10 )
    , ( '9', Character 8 0 0 29 12 6 10 )
    , ( ':', Character 8 2 2 36 14 2 6 )
    , ( ';', Character 8 0 2 39 14 4 8 )
    , ( '<', Character 8 0 0 44 12 6 10 )
    , ( '=', Character 8 0 2 51 14 6 6 )
    , ( '>', Character 8 0 0 58 12 6 10 )
    , ( '?', Character 8 0 0 65 12 6 10 )
    , ( '@', Character 8 0 0 72 12 6 10 )
    , ( 'A', Character 8 0 0 79 12 6 10 )
    , ( 'B', Character 8 0 0 86 12 6 10 )
    , ( 'C', Character 8 0 0 93 12 6 10 )
    , ( 'D', Character 8 0 0 100 12 6 10 )
    , ( 'E', Character 8 0 0 107 12 6 10 )
    , ( 'F', Character 8 0 0 114 12 6 10 )
    , ( 'G', Character 8 0 0 1 23 6 10 )
    , ( 'H', Character 8 0 0 8 23 6 10 )
    , ( 'I', Character 8 0 0 15 23 6 10 )
    , ( 'J', Character 8 0 0 22 23 6 10 )
    , ( 'K', Character 8 0 0 29 23 6 10 )
    , ( 'L', Character 8 0 0 36 23 6 10 )
    , ( 'M', Character 8 0 0 43 23 6 10 )
    , ( 'N', Character 8 0 0 50 23 6 10 )
    , ( 'O', Character 8 0 0 57 23 6 10 )
    , ( 'P', Character 8 0 0 64 23 6 10 )
    , ( 'Q', Character 8 0 0 71 23 6 10 )
    , ( 'R', Character 8 0 0 78 23 6 10 )
    , ( 'S', Character 8 0 0 85 23 6 10 )
    , ( 'T', Character 8 0 0 92 23 6 10 )
    , ( 'U', Character 8 0 0 99 23 6 10 )
    , ( 'V', Character 8 0 0 106 23 6 10 )
    , ( 'W', Character 8 0 0 113 23 6 10 )
    , ( 'X', Character 8 0 0 120 23 6 10 )
    , ( 'Y', Character 8 0 0 1 34 6 10 )
    , ( 'Z', Character 8 0 0 8 34 6 10 )
    , ( '[', Character 8 0 0 15 34 4 10 )
    , ( '\\', Character 8 0 0 20 34 6 10 )
    , ( ']', Character 8 2 0 27 34 4 10 )
    , ( '^', Character 8 0 0 32 34 6 4 )
    , ( '_', Character 8 0 8 39 42 6 2 )
    , ( '`', Character 8 2 0 46 34 4 4 )
    , ( 'a', Character 8 0 2 51 36 6 8 )
    , ( 'b', Character 8 0 2 58 36 6 8 )
    , ( 'c', Character 8 0 2 65 36 6 8 )
    , ( 'd', Character 8 0 2 72 36 6 8 )
    , ( 'e', Character 8 0 2 79 36 6 8 )
    , ( 'f', Character 8 0 2 86 36 6 8 )
    , ( 'g', Character 8 0 2 93 36 6 8 )
    , ( 'h', Character 8 0 2 100 36 6 8 )
    , ( 'i', Character 8 0 2 107 36 6 8 )
    , ( 'j', Character 8 0 2 114 36 6 8 )
    , ( 'k', Character 8 0 2 1 47 6 8 )
    , ( 'l', Character 8 0 2 8 47 6 8 )
    , ( 'm', Character 8 0 2 15 47 6 8 )
    , ( 'n', Character 8 0 2 22 47 6 8 )
    , ( 'o', Character 8 0 2 29 47 6 8 )
    , ( 'p', Character 8 0 2 36 47 6 8 )
    , ( 'q', Character 8 0 2 43 47 6 8 )
    , ( 'r', Character 8 0 2 50 47 6 8 )
    , ( 's', Character 8 0 2 57 47 6 8 )
    , ( 't', Character 8 0 2 64 47 6 8 )
    , ( 'u', Character 8 0 2 71 47 6 8 )
    , ( 'v', Character 8 0 2 78 47 6 8 )
    , ( 'w', Character 8 0 2 85 47 6 8 )
    , ( 'x', Character 8 0 2 92 47 6 8 )
    , ( 'y', Character 8 0 2 99 47 6 8 )
    , ( 'z', Character 8 0 2 106 47 6 8 )
    , ( '{', Character 8 0 0 113 45 6 10 )
    , ( '|', Character 8 2 0 120 45 2 10 )
    , ( '}', Character 8 0 0 1 56 6 10 )
    , ( '~', Character 8 0 2 8 58 6 6 )
    , ( 'À', Character 16 0 0 15 56 14 10 )
    , ( 'Á', Character 16 0 0 30 56 14 10 )
    , ( 'Â', Character 16 0 0 45 56 14 10 )
    , ( 'Ã', Character 16 0 0 60 56 14 10 )
    , ( 'Ä', Character 16 0 0 75 56 14 10 )
    , ( 'Å', Character 16 2 0 90 56 10 10 )
    , ( 'Æ', Character 16 2 0 101 56 10 10 )
    , ( 'Ç', Character 16 2 0 112 56 10 10 )
    , ( 'È', Character 16 0 0 1 67 14 10 )
    , ( 'É', Character 16 2 0 16 67 10 10 )
    , ( 'Ê', Character 16 0 0 27 67 14 10 )
    , ( 'Ë', Character 16 0 0 42 67 14 10 )
    , ( 'Ì', Character 16 0 0 57 67 14 10 )
    , ( 'Í', Character 16 2 0 72 67 10 10 )
    , ( 'Î', Character 16 0 0 83 67 14 10 )
    , ( 'Ï', Character 16 2 0 98 67 10 10 )
    , ( 'Ð', Character 16 0 4 109 71 14 2 )
    , ( 'Ñ', Character 16 0 0 1 78 14 10 )
    , ( 'Ò', Character 16 0 0 16 78 14 10 )
    , ( 'Ó', Character 16 2 0 31 78 10 10 )
    , ( 'Ô', Character 16 0 0 42 78 14 10 )
    , ( 'Õ', Character 16 0 2 57 80 14 6 )
    , ( 'Ö', Character 16 0 2 72 80 14 6 )
    , ( '×', Character 16 0 0 87 78 14 10 )
    , ( 'Ø', Character 16 0 0 102 78 14 10 )
    , ( 'Ù', Character 16 0 0 1 89 14 10 )
    ]
