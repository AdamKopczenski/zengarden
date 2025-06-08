
require 'nokogiri'
require_relative 'Cabinet-projection'

class ZenGardenBoard
  # The height of an upright piece (all three are the same). Chosen somewhat arbitrarily.
  UPRIGHT_HEIGHT = 110.0
  # The width of the square base of an upright piece.
  #  - The same across all three pieces.
  #  - Calculated to maintain proportions of a physical Zendo set.
  UPRIGHT_WIDTH = UPRIGHT_HEIGHT / 11.0 * 6.0

  # The width of a square. Chosen (somewhat) arbitrarily.
  # - Should be small enough to make it clear that two halves of flat pieces cannot share a square.
  # - Should be large enough to comfortably hold an upright piece.
  # - Defined relative to UPRIGHT_HEIGHT for ease of scaling.
  SQUARE_WIDTH = UPRIGHT_HEIGHT / 1.2 * 1.375 

  # A "flat" piece that has a flat top (block or cheesecake) has a reversed height/width from its
  # upright version.
  FLATTOP_HEIGHT = UPRIGHT_WIDTH
  FLATTOP_WIDTH = UPRIGHT_HEIGHT

  # A "flat" piece that has a sloped top (doorstop or pyramid) calls for some math to determine its
  # exact dimensions.
  LINETOP_LENGTH = Math.sqrt( (UPRIGHT_WIDTH / 2.0)**2 + UPRIGHT_HEIGHT**2 )
  LINETOP_HEIGHT = UPRIGHT_HEIGHT * UPRIGHT_WIDTH / LINETOP_LENGTH

  # Let's make the actual game board the default.
  # - Width is the number of columns of squares, which have numeric coordinates.
  # - Height is the number of rows of squares, which have letter coordinates.
  # - But we'll always process all coordinates as strings, because XML.
  # - Note that a 4×4 board actually has 7×7 valid coordinates, because pieces can "straddle"
  #   edges of squares.
  DEFAULT_WIDTH = DEFAULT_HEIGHT = 4

  # How much empty space (minimum) between a part of our drawings and the edge of the canvas.
  CANVAS_MARGIN = 10

  # The inputs are given as strings.
  def initialize(_width, _height)
    @logical_width = _width ? _width.to_i : DEFAULT_WIDTH
    @columns = (1...@logical_width * 2).to_a.map{|i| i.to_s}
    @logical_height = _height ? _height.to_i : DEFAULT_HEIGHT
    @rows = (1...@logical_height * 2).to_a.map{|i| (i + 96).chr}

    # Let's use a "scrap" canvas to calculate the exact dimensions (in canvas coordinates) we
    # need the real canvas to be. The lowest and leftmost point we'll use on the scrap canvas has
    # spatial coordinates (0,0,0) and canvas coordinates (0,0).
    scrap_canvas = CabinetProjectedCanvas.new('0', '0', '0', '0')
    @canvas = Hash.new

    # The rightmost canvas coordinate we'll need is used on the opposite corner of the board.
    drawing_width = scrap_canvas.to_cc(
      {x:@logical_width * SQUARE_WIDTH, y:@logical_height * SQUARE_WIDTH, z:0}
    )[:x]
    @canvas[:width] = (drawing_width + 2 * CANVAS_MARGIN).round

    # The topmost canvas coordinate will be used when drawing (for example) an upright block on
    # the northernmost rank. (It'll be negative due to the layout of a canvas.)
    sc_topmost = {
      x: (SQUARE_WIDTH / 2.0) + (UPRIGHT_WIDTH / 2.0),
      y: (@logical_height - 0.5) * SQUARE_WIDTH + UPRIGHT_WIDTH / 2.0,
      z: UPRIGHT_HEIGHT
    }
    drawing_height = -scrap_canvas.to_cc(sc_topmost)[:y]
    @canvas[:height] = (drawing_height + 2 * CANVAS_MARGIN).round

    @canvas[:spatial_origin_cx] = CANVAS_MARGIN
    @canvas[:spatial_origin_cy] = @canvas[:height] - CANVAS_MARGIN
  end
end

board = ZenGardenBoard.new(4, 4)
pp board