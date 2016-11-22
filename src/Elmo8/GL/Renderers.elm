module Elmo8.GL.Renderers exposing (..)

{-| WebGL renderers (for rendering stuff)

-}

import Dict
import Math.Vector2 exposing (Vec2, vec2)
import Math.Matrix4 exposing (Mat4, makeOrtho2D)
import WebGL
import Elmo8.Assets
import Elmo8.GL.Characters
import Elmo8.GL.Font
import Elmo8.GL.Shaders as Shaders


type alias Vertex =
    { position : Vec2 }


type alias Display a =
    { a | screenSize : Vec2, resolution : Resolution, projectionMatrix : Mat4 }


type alias TextureAssets a =
    { a | textures : Dict.Dict String Elmo8.Assets.Texture }


type alias FontAssets a =
    { a | characterMeshes : Elmo8.GL.Font.CharacterMeshes }


type alias Assets a =
    TextureAssets (FontAssets a)


{-| Resolution of the virtual device

In typical cases this is 128 x 128 pixels.

-}
type alias Resolution =
    Vec2


renderPixel : Display display -> TextureAssets assets -> { a | x : Int, y : Int, colour : Int } -> Maybe WebGL.Renderable
renderPixel { resolution, screenSize, projectionMatrix } assets { x, y, colour } =
    case Elmo8.Assets.getPalette assets of
        Just palette ->
            WebGL.render
                Shaders.pixelsVertexShader
                Shaders.pixelsFragmentShader
                pixelMesh
                { canvasSize = screenSize
                , screenSize = resolution
                , projectionMatrix = projectionMatrix
                , paletteTexture = palette.texture
                , paletteSize = palette.textureSize
                , pixelX = x
                , pixelY = y
                , index = colour
                , remap =
                    0
                    -- , index = Dict.get colour model.pixelPalette |> Maybe.withDefault colour
                    -- , remap = Dict.get colour model.screenPalette |> Maybe.withDefault 0
                }
                |> Just

        Nothing ->
            Nothing


pixelMesh : WebGL.Drawable Vertex
pixelMesh =
    WebGL.Points [ Vertex (vec2 0 0) ]


renderSprite : Display display -> TextureAssets assets -> { a | x : Int, y : Int, sprite : Int, textureKey : String } -> Maybe WebGL.Renderable
renderSprite { resolution, screenSize, projectionMatrix } assets { x, y, sprite, textureKey } =
    case Elmo8.Assets.getTexture assets textureKey of
        Just texture ->
            WebGL.render
                Shaders.spriteVertexShader
                Shaders.spriteFragmentShader
                spriteMesh
                { screenSize = screenSize
                , texture = texture.texture
                , textureSize = texture.textureSize
                , projectionMatrix = projectionMatrix
                , spriteX = x
                , spriteY = y
                , spriteIndex = sprite
                }
                |> Just

        Nothing ->
            Nothing


spriteMesh : WebGL.Drawable Vertex
spriteMesh =
    WebGL.Triangle
        [ ( Vertex (vec2 0 0), Vertex (vec2 8 8), Vertex (vec2 8 0) )
        , ( Vertex (vec2 0 0), Vertex (vec2 0 8), Vertex (vec2 8 8) )
        ]


renderChar : Display display -> Assets assets -> { a | x : Int, y : Int, colour : Int, character : Elmo8.GL.Characters.Character } -> Maybe WebGL.Renderable
renderChar display assets { x, y, colour, character } =
    let
        maybeFont =
            Elmo8.Assets.getFont assets

        maybePalette =
            Elmo8.Assets.getPalette assets

        maybeMesh =
            Dict.get ( character.width, character.height ) assets.characterMeshes
    in
        case ( maybeFont, maybePalette, maybeMesh ) of
            ( Just font, Just palette, Just mesh ) ->
                WebGL.render
                    Shaders.textVertexShader
                    Shaders.textFragmentShader
                    -- TODO: Remove the dict lookup and ask for the mesh to be passed in
                    mesh
                    { screenSize = display.screenSize
                    , fontTexture = font.texture
                    , textureSize = font.textureSize
                    , projectionMatrix = display.projectionMatrix
                    , charCoords = vec2 (toFloat character.x) (toFloat character.y)
                    , colour = colour
                    , paletteTexture = palette.texture
                    , paletteTextureSize = palette.textureSize
                    , theMatrix = Math.Matrix4.translate3 (toFloat x) (toFloat y) 0.0 display.projectionMatrix |> Math.Matrix4.scale3 0.5 0.5 1.0
                    }
                    |> Just

            _ ->
                Nothing


defaultFontMesh : WebGL.Drawable Vertex
defaultFontMesh =
    WebGL.Triangle
        [ ( Vertex (vec2 0 0), Vertex (vec2 1 1), Vertex (vec2 1 0) )
        , ( Vertex (vec2 0 0), Vertex (vec2 0 1), Vertex (vec2 1 1) )
        ]


renderText : Display a -> Assets a -> { a | x : Int, y : Int, colour : Int, text : String } -> List (Maybe WebGL.Renderable)
renderText display assets text =
    Elmo8.GL.Font.textToCharacters text
        |> List.map (renderChar display assets)
