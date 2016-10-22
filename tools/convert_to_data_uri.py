import argparse
import base64
import os
import sys

TEMPLATE="""module {module} exposing (..)

-- Generated from {filename}
{function}: String
{function} =
    "data:{mime_type};base64,{data}"

"""

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("module_name", help="Elm module name, e.g. Elmo8.Textures.Pico8")
    parser.add_argument("function_name", help="Elm functio name, e.g. myFontData")
    parser.add_argument("mime_type", help="mime type, e.g. image/png")
    parser.add_argument("input", help="File to read, e.g. foo.png", type=argparse.FileType('rb'))
    parser.add_argument("output", help="File to write, e.g. src/Elmo8/Textures/Pico8.elm", type=argparse.FileType('w'))
    args = parser.parse_args()

    data = base64.b64encode(args.input.read()).decode("ASCII")

    code = TEMPLATE.format(
        module=args.module_name,
        filename=os.path.basename(args.input.name),
        function=args.function_name,
        mime_type=args.mime_type,
        data=data,
    )
    args.output.write(code)

if __name__ == "__main__":
    main()
