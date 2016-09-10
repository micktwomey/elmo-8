import Elmo8.Console as Console
import Color

draw : Console.Console -> List Console.Command
draw console =
    [ Console.putPixel 0 0 Color.white
    , Console.print "Hello" 10 10 Color.white
    ]

main : Program Never
main =
 Console.boot 
    { draw = draw
    }
