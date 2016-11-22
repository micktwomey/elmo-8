module Elmo8.GL.Shaders exposing (..)

{-| Shaders used to render via WebGL

-}

import Math.Vector2 exposing (Vec2)
import Math.Matrix4 exposing (Mat4)
import WebGL


pixelsVertexShader : WebGL.Shader { attr | position : Vec2 } { unif | canvasSize : Vec2, screenSize : Vec2, projectionMatrix : Mat4, pixelX : Int, pixelY : Int, index : Int, remap : Int } { colourIndex : Float, colourRemap : Float }
pixelsVertexShader =
    [glsl|
    precision mediump float;
    attribute vec2 position;
    uniform vec2 canvasSize;
    uniform vec2 screenSize;
    uniform mat4 projectionMatrix;
    uniform int pixelX;
    uniform int pixelY;
    uniform int index;
    uniform int remap;
    varying float colourIndex;
    varying float colourRemap;
    void main () {
        gl_PointSize = canvasSize.x / screenSize.x;

        gl_Position = projectionMatrix * vec4(position.x + float(pixelX) + 0.5, position.y + float(pixelY) + 0.5, 0.0, 1.0);

        colourIndex = float(index);
        colourRemap = float(remap);
    }
|]


pixelsFragmentShader : WebGL.Shader {} { uniform | paletteTexture : WebGL.Texture, paletteSize : Vec2 } { colourIndex : Float, colourRemap : Float }
pixelsFragmentShader =
    [glsl|
    precision mediump float;
    uniform sampler2D paletteTexture;
    uniform vec2 paletteSize;
    varying float colourIndex;
    varying float colourRemap;
    void main () {
        // Texture origin bottom left
        // Use slightly less than 1.0 to slightly nudge into correct pixel
        float index = colourIndex / paletteSize.x;
        float remap = 0.999 - (colourRemap / paletteSize.y);
        gl_FragColor = texture2D(paletteTexture, vec2(index, remap));
    }
|]


spriteVertexShader : WebGL.Shader { attr | position : Vec2 } { unif | screenSize : Vec2, projectionMatrix : Mat4, spriteX : Int, spriteY : Int } { texturePos : Vec2 }
spriteVertexShader =
    [glsl|
  precision mediump float;
  attribute vec2 position;
  uniform int spriteX;
  uniform int spriteY;
  uniform vec2 screenSize;
  uniform mat4 projectionMatrix;
  varying vec2 texturePos;
  void main () {
    texturePos = position;
    gl_Position = projectionMatrix * vec4(position.x + float(spriteX), position.y + float(spriteY), 0.0, 1.0);
  }
|]


spriteFragmentShader : WebGL.Shader {} { u | texture : WebGL.Texture, textureSize : Vec2, projectionMatrix : Mat4, spriteIndex : Int } { texturePos : Vec2 }
spriteFragmentShader =
    [glsl|
  precision mediump float;
  uniform mat4 projectionMatrix;
  uniform sampler2D texture;
  uniform vec2 textureSize;
  uniform int spriteIndex;
  varying vec2 texturePos;
  void main () {
    vec2 size = vec2(64.0, 64.0) / textureSize;

    int sprites = 16;
    float spriteX = mod((8.0 * float(spriteIndex)), textureSize.x);
    float spriteY = float(spriteIndex / sprites) * 8.0;
    vec2 spriteOffset = vec2(spriteX, spriteY);

    vec2 textureClipSpace = (projectionMatrix * vec4((spriteOffset + texturePos) * size, 0, 1)).xy;
    vec4 temp = texture2D(texture, textureClipSpace);
    gl_FragColor = temp;
  }
|]


textVertexShader : WebGL.Shader { attr | position : Vec2 } { unif | screenSize : Vec2, theMatrix : Mat4, colour : Int } { texturePos : Vec2, colourIndex : Float }
textVertexShader =
    [glsl|
  precision mediump float;
  attribute vec2 position;
  uniform vec2 screenSize;
  uniform mat4 theMatrix;
  uniform int colour;
  varying vec2 texturePos;
  varying float colourIndex;
  void main () {
    texturePos = position;
    colourIndex = float(colour);
    gl_Position = vec4((theMatrix * vec4(position, 0.0, 1.0)).xy, 0, 1);
  }
|]


textFragmentShader : WebGL.Shader {} { u | fontTexture : WebGL.Texture, textureSize : Vec2, projectionMatrix : Mat4, charCoords : Vec2, paletteTexture : WebGL.Texture, paletteTextureSize : Vec2 } { texturePos : Vec2, colourIndex : Float }
textFragmentShader =
    [glsl|
  precision mediump float;
  uniform mat4 projectionMatrix;
  uniform sampler2D fontTexture;
  uniform vec2 textureSize;
  uniform vec2 charCoords;
  uniform sampler2D paletteTexture;
  uniform vec2 paletteTextureSize;
  varying vec2 texturePos;
  varying float colourIndex;
  void main () {
    vec2 size = vec2(64.0, 64.0) / textureSize;

    vec2 textureClipSpace = (projectionMatrix * vec4((charCoords + texturePos) * size, 0, 1)).xy;
    vec4 temp = texture2D(fontTexture, textureClipSpace);

    float index = colourIndex / paletteTextureSize.x;
    // float remap = 0.999 - (colourRemap / paletteSize.y);
    float remap = 0.999 - 0.0;
    vec4 paletteColour = texture2D(paletteTexture, vec2(index, remap));

    gl_FragColor = vec4(paletteColour.rgb, temp.a);
  }
|]
