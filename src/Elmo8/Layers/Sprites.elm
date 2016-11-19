module Elmo8.Layers.Sprites exposing (..)

import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import Math.Matrix4 exposing (Mat4, makeOrtho2D)
import Task
import WebGL
import Elmo8.GL.Renderers
import Elmo8.Layers.Common exposing (CanvasSize, makeProjectionMatrix, Vertex)


type alias Sprite =
    { sprite : Int
    , x : Int
    , y : Int
    }


type alias Model =
    { maybeTexture : Maybe WebGL.Texture
    , sprites : List Sprite
    , canvasSize : CanvasSize
    , screenSize : Vec2
    , textureSize : Vec2
    , projectionMatrix : Mat4
    }


type Msg
    = TextureLoad WebGL.Texture
    | TextureError WebGL.Error


sprite : Model -> { x : Int, y : Int, index : Int } -> Model
sprite model { x, y, index } =
    -- TODO replace this with something less memory leaky, Set isn't any use, probably use Lazy if possible, or a Dict
    { model | sprites = (Sprite index x y) :: model.sprites }


clear : Model -> Model
clear model =
    { model | sprites = [] }


init : CanvasSize -> String -> ( Model, Cmd Msg )
init canvasSize uri =
    { maybeTexture = Nothing
    , sprites = []
    , canvasSize = canvasSize
    , screenSize = vec2 canvasSize.width canvasSize.height
    , textureSize = vec2 0 0
    , projectionMatrix = makeProjectionMatrix
    }
        ! [ WebGL.loadTexture uri
                |> Task.attempt
                    (\result ->
                        case result of
                            Err err ->
                                TextureError err

                            Ok val ->
                                TextureLoad val
                    )
          ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TextureLoad texture ->
            { model
                | maybeTexture = Just texture
                , textureSize = vec2 (toFloat (Tuple.first (WebGL.textureSize texture))) (toFloat (Tuple.second (WebGL.textureSize texture)))
            }
                ! []

        TextureError _ ->
            model ! []


renderSprite : Model -> WebGL.Texture -> Sprite -> WebGL.Renderable
renderSprite model texture sprite =
    Elmo8.GL.Renderers.renderSprite
        { screenSize = model.screenSize
        , projectionMatrix = model.projectionMatrix
        , resolution = vec2 128.0 128.0
        }
        { texture = texture
        , textureSize = model.textureSize
        }
        { x = sprite.x
        , y = sprite.y
        , sprite = sprite.sprite
        }


render : Model -> List WebGL.Renderable
render model =
    case model.maybeTexture of
        Nothing ->
            []

        Just texture ->
            List.map (renderSprite model texture) model.sprites
