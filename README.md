# zengarden
Where I'm keeping my work on the Zen Garden puzzle. "Includes" the first "version" of the 3dSVG library. (That is, one day I'll try to extract that portion of the proceedings into a more generalized offering.)

I must, legally, thank freepik.com for the marble texture graphics.

Zendo rectangles are 1 3/8" tall and 3/4" wide. Wedges and pyramids, when upright, have the same footprint and height as rectangles.

According to the math I've done and the measurements above, a square should therefore have an edge length of 1.03125 - 1.14583 inches "ideally." I'd gone with 1 1/4 in the past with some success. But 1.2 or 1.15 would help two pyramids overcrowd each other "correctly."

Some terms:
    - Logical coordinates (lc): locations on the board grid. In a full-size board, this'll be a1-g7 (r, c)
    - Spatial coordinates (sc): locations in space that represent (mostly) the corners of the various pieces. (x increases to the east, y increases to the north, z increases upwards)
    - Canvas coordinates (cc): locations on the canvas. (x increases to the right, y increases downward)

The cabinet projection functions will translate Spatial coordinates into Canvas coordinates.

At the moment, run Cabinet-projection.rb with an (XML) file name, and it'll convert the <spatial> elements in that file into <svg> elements.
