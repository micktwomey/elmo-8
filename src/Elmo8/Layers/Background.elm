module Elmo8.Layers.Background exposing (..)

{-| Background layer

Used for rendering backgrounds (and maps?)

TODO: Decide if just for backgrounds or for maps/levels too

-}

import Math.Vector2 exposing (Vec2, vec2, fromTuple)
import WebGL


-- From http://blog.tojicode.com/2012/07/sprite-tile-maps-on-gpu.html
-- TODO: make this work :)
tileMapVertextShader : WebGL.Shader { attr | position : Vec2, texture : Vec2} { uniform | viewOffset : Vec2, viewportSize : Vec2, inverseTileTextureSize : Vec2, inverseTileSize : Float} { pixelCoord : Vec2, texCoord : Vec2 }
tileMapVertextShader = [glsl|
    precision mediump float;
    attribute vec2 position;
    attribute vec2 texture;

    varying vec2 pixelCoord;
    varying vec2 texCoord;

    uniform vec2 viewOffset;
    uniform vec2 viewportSize;
    uniform vec2 inverseTileTextureSize;
    uniform float inverseTileSize;

    void main(void) {
        pixelCoord = (texture * viewportSize) + viewOffset;
        texCoord = pixelCoord * inverseTileTextureSize * inverseTileSize;
        gl_Position = vec4(position, 0.0, 1.0);
    }
|]
