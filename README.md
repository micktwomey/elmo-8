# ELMO-8

## A Simple Game Library Inspired by the Excellent PICO-8

The goal of the library is to offer a small, simple game development environment which aspires to be as charming as [PICO-8](http://www.lexaloffle.com/pico-8.php).

There are deliberate limitations to keep things simpler and to encourage the 8-bit aesthetic.

Aspirational specs:

- Display: 128x128 16 colours
- Sprites: 128 8x8 sprites
- Map: 128x32 cels
- Controls: 2 6-button joysticks

## Goals

- Be a nice little playground
- Be a simple teaching tool

## Usage

```elm
import elmo8 exposing (..)

update : 

main : Program Never
main =
    elmo8.Game {
        init = init,
        update = update,
        draw = draw
    }
```