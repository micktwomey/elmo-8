#!/bin/bash

set -ex

grep Char $1 | awk -F'"' '{print ", ('"'"'"$8"'"'"', Character "$2, $4, $6, ")"}' \
    | sed -e '1s/, //' \
    | sed -e 's/&quot;/"/' \
    | sed -e 's/&amp;/\&/' \
    | sed -e 's/&lt;/</' \
    | sed -e "s/'\\\\'/'\\\\\\\\'/" \
    | sed -e "s/'''/'\\\\''/"
