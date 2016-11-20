module Elmo8.GL.Renderers exposing (..)

{-| WebGL renderers (for rendering stuff)

-}

import Dict
import Math.Vector2 exposing (Vec2, vec2)
import Math.Matrix4 exposing (Mat4, makeOrtho2D)
import WebGL
import Elmo8.Assets
import Elmo8.GL.Shaders as Shaders


type alias Vertex =
    { position : Vec2 }


{-| Resolution of the virtual device

In typical cases this is 128 x 128 pixels.

-}
type alias Resolution =
    Vec2


renderPixel : { a | screenSize : Vec2, resolution : Resolution, projectionMatrix : Mat4 } -> { a | textures : Dict.Dict String Elmo8.Assets.Texture} -> { a | x : Int, y : Int, colour : Int } -> Maybe WebGL.Renderable
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
        Nothing -> Nothing


pixelMesh : WebGL.Drawable Vertex
pixelMesh =
    WebGL.Points [ Vertex (vec2 0 0) ]


renderSprite : { a | screenSize : Vec2, resolution : Resolution, projectionMatrix : Mat4 } -> Elmo8.Assets.Texture -> { a | x : Int, y : Int, sprite : Int } -> WebGL.Renderable
renderSprite { resolution, screenSize, projectionMatrix } texture { x, y, sprite } =
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


spriteMesh : WebGL.Drawable Vertex
spriteMesh =
    WebGL.Triangle
        [ ( Vertex (vec2 0 0), Vertex (vec2 8 8), Vertex (vec2 8 0) )
        , ( Vertex (vec2 0 0), Vertex (vec2 0 8), Vertex (vec2 8 8) )
        ]


renderChar : { a | screenSize : Vec2, resolution : Resolution, projectionMatrix : Mat4, palette : Elmo8.Assets.Texture, font : Elmo8.Assets.Texture, fontMeshes : Dict.Dict ( Int, Int ) (WebGL.Drawable Vertex) } -> { a | x : Int, y : Int, colour : Int, character : Elmo8.Assets.Character } -> WebGL.Renderable
renderChar { resolution, screenSize, projectionMatrix, palette, font, fontMeshes } { x, y, colour, character } =
    WebGL.render
        Shaders.textVertexShader
        Shaders.textFragmentShader
        -- TODO: Remove the dict lookup and ask for the mesh to be passed in
        (Dict.get ( character.width, character.height ) fontMeshes |> Maybe.withDefault defaultFontMesh)
        { screenSize = screenSize
        , fontTexture = font.texture
        , textureSize = font.textureSize
        , projectionMatrix = projectionMatrix
        , charCoords = vec2 (toFloat character.x) (toFloat character.y)
        , colour = colour
        , paletteTexture = palette.texture
        , paletteTextureSize = palette.textureSize
        , theMatrix = Math.Matrix4.translate3 (toFloat x) (toFloat y) 0.0 projectionMatrix |> Math.Matrix4.scale3 0.5 0.5 1.0
        }


defaultFontMesh : WebGL.Drawable Vertex
defaultFontMesh =
    WebGL.Triangle
        [ ( Vertex (vec2 0 0), Vertex (vec2 1 1), Vertex (vec2 1 0) )
        , ( Vertex (vec2 0 0), Vertex (vec2 0 1), Vertex (vec2 1 1) )
        ]
