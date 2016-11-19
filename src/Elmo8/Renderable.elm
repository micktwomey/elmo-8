module Elmo8.Renderable exposing (..)

{-| A renderable item in a scene (sprite, pixel, etc)

-}

-- import Elmo8.Assets

{-| Selects the renderer to use

-}
type RenderType
    = Pixel
    | Sprite
    | Text


-- Compose records, see https://github.com/elm-lang/elm-compiler/issues/1308#issuecomment-194916448

-- type Renderable attributes =
--     Renderable

-- type alias Position a =
--     { a | x : Int, y : Int }


-- type alias Colour a =
--     { a | colour : Int }


-- type alias Texture a =
--     { a | texture : Elmo8.Assets.Texture }


-- type alias Text a =
--     { a | text : String }


-- type alias Sprite a =
--     { a | sprite : Int }

-- type alias RenderableSprite a =
--     Position (Colour (Texture (Sprite a)))


-- -- TODO: Decide if better to compose propertes instead of explicit type?
-- type Renderable
--     = Sprite
--     | Pixel
--     | Text
