import Elmo8.Console as Console
import Elmo8.Palettes.Pico8 as Palette

draw : Console.Console -> List Console.Command
draw console =
    [ Console.putPixel 0 0 Palette.peach
    -- , Console.print "Hello" 10 10 Color.white
    ]

main : Program Never
main =
 Console.boot
    { draw = draw
    }
