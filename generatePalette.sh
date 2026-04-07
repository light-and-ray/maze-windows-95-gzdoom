#!/bin/bash -ex
cd "$(dirname "$0")"
palettePath="maze95/playpal.lmp"
colormapPath="maze95/colormap.lmp"
find maze95/ -iname "*.png" | xargs python3 _generatePalette/optimal_palette.py "$palettePath"
python3 _generatePalette/colormap.py "$palettePath" > "$colormapPath"
cd ..
