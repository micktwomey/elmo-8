module Elmo8.Layers.Text exposing (..)

import Dict
import Math.Vector2 exposing (Vec2, vec2)
import Math.Matrix4 exposing (Mat4, makeOrtho2D)
import String
import Task
import WebGL
import Elmo8.Assets
import Elmo8.GL.Characters
import Elmo8.GL.Font
import Elmo8.GL.Renderers
import Elmo8.Layers.Common exposing (CanvasSize, Vertex, makeProjectionMatrix)


-- TODO: represent more of the metrics for better layout.


type alias Character =
    { x : Int
    , y : Int
    , width : Int
    , height : Int
    }


type alias Message =
    { x : Int
    , y : Int
    , colour : Int
    , characters : String
    }


type alias Model =
    { maybeTexture : Maybe WebGL.Texture
    , textureSize : Vec2
    , maybePaletteTexture : Maybe WebGL.Texture
    , paletteTextureSize : Vec2
    , messages : List Message
    , meshes : Dict.Dict ( Int, Int ) (WebGL.Drawable Vertex)
    , canvasSize : Vec2
    , projectionMatrix : Mat4
    }


type Msg
    = TextureLoad WebGL.Texture
    | TextureError WebGL.Error
    | PaletteTextureLoad WebGL.Texture
    | PaletteTextureError WebGL.Error


clear : Model -> Model
clear model =
    { model | messages = [] }


print : Model -> Int -> Int -> Int -> String -> Model
print model x y colour string =
    { model | messages = (Message x y colour string) :: model.messages }


init : CanvasSize -> ( Model, Cmd Msg )
init canvasSize =
    { maybeTexture = Nothing
    , messages = []
    , meshes = meshesFromCharacters
    , canvasSize = vec2 canvasSize.width canvasSize.height
    , textureSize = vec2 128.0 128.0
    , projectionMatrix = makeProjectionMatrix
    , maybePaletteTexture = Nothing
    , paletteTextureSize = vec2 16.0 16.0
    }
        ! [ Elmo8.Assets.loadFontTexture
                |> Task.attempt
                    (\result ->
                        case result of
                            Err err ->
                                TextureError err

                            Ok val ->
                                TextureLoad val
                    )
          , Elmo8.Assets.loadPaletteMapTexture
                |> Task.attempt
                    (\result ->
                        case result of
                            Err err ->
                                PaletteTextureError err

                            Ok val ->
                                PaletteTextureLoad val
                    )
          ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextureError error ->
            model ! []

        TextureLoad texture ->
            { model | maybeTexture = Just texture } ! []

        PaletteTextureError error ->
            model ! []

        PaletteTextureLoad texture ->
            { model | maybePaletteTexture = Just texture } ! []


defaultCharacter : Elmo8.GL.Characters.Character
defaultCharacter =
    Elmo8.GL.Font.defaultCharacter


renderChar : Model -> WebGL.Texture -> WebGL.Texture -> Int -> ( Int, Int ) -> Character -> Maybe WebGL.Renderable
renderChar model texture paletteTexture colour ( x, y ) character =
    Elmo8.GL.Renderers.renderChar
        { screenSize = model.canvasSize
        , projectionMatrix = model.projectionMatrix
        , resolution = vec2 128.0 128.0
        }
        { characterMeshes = model.meshes
        , textures =
            Dict.fromList
                [ ( Elmo8.Assets.fontKey, { texture = texture, textureSize = model.textureSize } )
                , ( Elmo8.Assets.paletteKey, { texture = paletteTexture, textureSize = model.paletteTextureSize } )
                ]
        }
        { x = x
        , y = y
        , colour = colour
        , character =
            { defaultCharacter
                | x = character.x
                , y = character.y
                , width = character.width
                , height = character.height
                , characterWidth = 8
            }
        }


getNextPosition : Character -> ( Int, Int ) -> ( Int, Int )
getNextPosition character ( x, y ) =
    -- Account for double width chars in font texture
    ( x + 1 + (character.width // 2), y )


renderMessage : Model -> WebGL.Texture -> WebGL.Texture -> Message -> List (Maybe WebGL.Renderable)
renderMessage model texture paletteTexture message =
    let
        characters =
            String.toList message.characters
                |> List.map (\c -> Dict.get c fontMap |> Maybe.withDefault (Character 102 78 14 10))

        positions =
            List.scanl getNextPosition ( message.x, message.y ) characters
    in
        List.map2 (renderChar model texture paletteTexture message.colour) positions characters


render : Model -> List WebGL.Renderable
render model =
    case ( model.maybeTexture, model.maybePaletteTexture ) of
        ( Just texture, Just paletteTexture ) ->
            List.concatMap (renderMessage model texture paletteTexture) model.messages
                |> List.filterMap identity

        ( _, _ ) ->
            []


meshWidthHeight : Float -> Float -> WebGL.Drawable Vertex
meshWidthHeight width height =
    WebGL.Triangle
        [ ( Vertex (vec2 0 0), Vertex (vec2 width height), Vertex (vec2 width 0) )
        , ( Vertex (vec2 0 0), Vertex (vec2 0 height), Vertex (vec2 width height) )
        ]


meshesFromCharacters : Dict.Dict ( Int, Int ) (WebGL.Drawable Vertex)
meshesFromCharacters =
    List.map (\( _, char ) -> ( ( char.width, char.height ), meshWidthHeight (toFloat char.width) (toFloat char.height) )) fontList
        |> Dict.fromList



-- https://github.com/andryblack/fontbuilder
-- <Char width="8" offset="0 0" rect="79 12 6 10" code="A"/>
-- {char="A",width=8,x=79,y=12,w=6,h=10,ox=0,oy=10}
-- grep Char fonts/pico-8_regular_8.xml | awk -F'"' '{print ", (\'"$8"\', Character "$6, ")"}' | pbcopy


fontList : List ( Char, Character )
fontList =
    [ ( ' ', Character 1 11 0 0 )
    , ( '!', Character 2 1 2 10 )
    , ( '"', Character 5 1 6 4 )
    , ( '#', Character 12 1 6 10 )
    , ( '$', Character 19 1 6 10 )
    , ( '%', Character 26 1 6 10 )
    , ( '&', Character 33 1 6 10 )
    , ( '\'', Character 40 1 4 4 )
    , ( '(', Character 45 1 4 10 )
    , ( ')', Character 50 1 4 10 )
    , ( '*', Character 55 1 6 10 )
    , ( '+', Character 62 3 6 6 )
    , ( ',', Character 69 7 4 4 )
    , ( '-', Character 74 5 6 2 )
    , ( '.', Character 81 9 2 2 )
    , ( '/', Character 84 1 6 10 )
    , ( '0', Character 91 1 6 10 )
    , ( '1', Character 98 1 6 10 )
    , ( '2', Character 105 1 6 10 )
    , ( '3', Character 112 1 6 10 )
    , ( '4', Character 119 1 6 10 )
    , ( '5', Character 1 12 6 10 )
    , ( '6', Character 8 12 6 10 )
    , ( '7', Character 15 12 6 10 )
    , ( '8', Character 22 12 6 10 )
    , ( '9', Character 29 12 6 10 )
    , ( ':', Character 36 14 2 6 )
    , ( ';', Character 39 14 4 8 )
    , ( '<', Character 44 12 6 10 )
    , ( '=', Character 51 14 6 6 )
    , ( '>', Character 58 12 6 10 )
    , ( '?', Character 65 12 6 10 )
    , ( '@', Character 72 12 6 10 )
    , ( 'A', Character 79 12 6 10 )
    , ( 'B', Character 86 12 6 10 )
    , ( 'C', Character 93 12 6 10 )
    , ( 'D', Character 100 12 6 10 )
    , ( 'E', Character 107 12 6 10 )
    , ( 'F', Character 114 12 6 10 )
    , ( 'G', Character 1 23 6 10 )
    , ( 'H', Character 8 23 6 10 )
    , ( 'I', Character 15 23 6 10 )
    , ( 'J', Character 22 23 6 10 )
    , ( 'K', Character 29 23 6 10 )
    , ( 'L', Character 36 23 6 10 )
    , ( 'M', Character 43 23 6 10 )
    , ( 'N', Character 50 23 6 10 )
    , ( 'O', Character 57 23 6 10 )
    , ( 'P', Character 64 23 6 10 )
    , ( 'Q', Character 71 23 6 10 )
    , ( 'R', Character 78 23 6 10 )
    , ( 'S', Character 85 23 6 10 )
    , ( 'T', Character 92 23 6 10 )
    , ( 'U', Character 99 23 6 10 )
    , ( 'V', Character 106 23 6 10 )
    , ( 'W', Character 113 23 6 10 )
    , ( 'X', Character 120 23 6 10 )
    , ( 'Y', Character 1 34 6 10 )
    , ( 'Z', Character 8 34 6 10 )
    , ( '[', Character 15 34 4 10 )
    , ( '\\', Character 20 34 6 10 )
    , ( ']', Character 27 34 4 10 )
    , ( '^', Character 32 34 6 4 )
    , ( '_', Character 39 42 6 2 )
    , ( '`', Character 46 34 4 4 )
    , ( 'a', Character 51 36 6 8 )
    , ( 'b', Character 58 36 6 8 )
    , ( 'c', Character 65 36 6 8 )
    , ( 'd', Character 72 36 6 8 )
    , ( 'e', Character 79 36 6 8 )
    , ( 'f', Character 86 36 6 8 )
    , ( 'g', Character 93 36 6 8 )
    , ( 'h', Character 100 36 6 8 )
    , ( 'i', Character 107 36 6 8 )
    , ( 'j', Character 114 36 6 8 )
    , ( 'k', Character 1 47 6 8 )
    , ( 'l', Character 8 47 6 8 )
    , ( 'm', Character 15 47 6 8 )
    , ( 'n', Character 22 47 6 8 )
    , ( 'o', Character 29 47 6 8 )
    , ( 'p', Character 36 47 6 8 )
    , ( 'q', Character 43 47 6 8 )
    , ( 'r', Character 50 47 6 8 )
    , ( 's', Character 57 47 6 8 )
    , ( 't', Character 64 47 6 8 )
    , ( 'u', Character 71 47 6 8 )
    , ( 'v', Character 78 47 6 8 )
    , ( 'w', Character 85 47 6 8 )
    , ( 'x', Character 92 47 6 8 )
    , ( 'y', Character 99 47 6 8 )
    , ( 'z', Character 106 47 6 8 )
    , ( '{', Character 113 45 6 10 )
    , ( '|', Character 120 45 2 10 )
    , ( '}', Character 1 56 6 10 )
    , ( '~', Character 8 58 6 6 )
      -- Exciting magical bonus characters :)
    , ( 'À', Character 15 56 14 10 )
    , ( 'Á', Character 30 56 14 10 )
    , ( 'Â', Character 45 56 14 10 )
    , ( 'Ã', Character 60 56 14 10 )
    , ( 'Ä', Character 75 56 14 10 )
    , ( 'Å', Character 90 56 10 10 )
    , ( 'Æ', Character 101 56 10 10 )
    , ( 'Ç', Character 112 56 10 10 )
    , ( 'È', Character 1 67 14 10 )
    , ( 'É', Character 16 67 10 10 )
    , ( 'Ê', Character 27 67 14 10 )
    , ( 'Ë', Character 42 67 14 10 )
    , ( 'Ì', Character 57 67 14 10 )
    , ( 'Í', Character 72 67 10 10 )
    , ( 'Î', Character 83 67 14 10 )
    , ( 'Ï', Character 98 67 10 10 )
    , ( 'Ð', Character 109 71 14 2 )
    , ( 'Ñ', Character 1 78 14 10 )
    , ( 'Ò', Character 16 78 14 10 )
    , ( 'Ó', Character 31 78 10 10 )
    , ( 'Ô', Character 42 78 14 10 )
    , ( 'Õ', Character 57 80 14 6 )
    , ( 'Ö', Character 72 80 14 6 )
    , ( '×', Character 87 78 14 10 )
    , ( 'Ø', Character 102 78 14 10 )
    , ( 'Ù', Character 1 89 14 10 )
    ]


fontMap : Dict.Dict Char Character
fontMap =
    Dict.fromList fontList
