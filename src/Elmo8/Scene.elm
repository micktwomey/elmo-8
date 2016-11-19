module Elmo8.Scene exposing (..)

{-| A scene in your game

Holds all that parts you want to render (sprites and friends).

You can create multiple scenes and swap between them.

-}

import Dict

import Elmo8.Renderable

type alias Layer =
    { renderables : Dict.Dict (Int, Int) Elmo8.Renderable.Renderable }

type alias Model =
    { layers : Dict.Dict Int Layer
    }

type Msg = Nothing

init : (Model, Cmd Msg)
init =
    {} ! []

