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
- Be a nice way to write small games

## Using

1. Clone
2. Look in `examples/`
3. elm make examples/Hello.elm
4. open index.html or `python3 -m http.server`
5. Go to http://localhost:8000/

Unfortunately elm reactor has a bug in 0.17.1 which prevents it serving static content properly, hence the use of the python server. When that's fixed just use `elm reactor`.

## Posts

- http://www.twoistoomany.com/blog/2016/10/19/working-on-elmo-8
