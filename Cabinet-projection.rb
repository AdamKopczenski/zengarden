require 'nokogiri'

# def to_cc(_sc)
#     { x: 10 + _sc[:x] + (_sc[:y] * 2.0 / 3.0).to_i,
#       y: CANVAS_HEIGHT - 10 - _sc[:z] - (_sc[:y] * 2.0 / 3.0).to_i}
# end



class CabinetProjectedCanvas
    DEFAULT_WIDTH = 500
    DEFAULT_HEIGHT = 500
    # Unless otherwise specified, the (spatial) origin will be this far from the bottom-left corner.
    DEFAULT_ORIGIN_OFFSET = 10
    
    # The inputs are given as strings (or nil) because I have a headache.
    def initialize(_width, _height, _origin_cx, _origin_cy)
        # pp _width, _height, _origin_cx, _origin_cy
        _ = _width ? _width.to_i : DEFAULT_WIDTH # We don't actually need this (yet).
        height = _height ? _height.to_i : DEFAULT_HEIGHT
        @origin_cx = _origin_cx ? _origin_cx.to_i : DEFAULT_ORIGIN_OFFSET
        @origin_cy = _origin_cy ? _origin_cy.to_i : height - DEFAULT_ORIGIN_OFFSET
        # puts "[#{_}, #{height}] (#{@origin_cx}, #{@origin_cy})"
    end

    def to_cc(_sc)
        { x: @origin_cx + (_sc[:x] + (_sc[:y] * 2.0 / 3.0)).round,
          y: @origin_cy - (_sc[:z] + (_sc[:y] * 2.0 / 3.0)).round }
    end
end

def to_cc_token(_sc_token, _canvas)
    /^(?<scx>.*),(?<scy>.*),(?<scz>.*)$/ =~ _sc_token
    cc = _canvas.to_cc( { x: scx.to_i, y: scy.to_i, z: scz.to_i } )
    "#{cc[:x]},#{cc[:y]}"
end

def to_cc_list(_sc_list, _canvas)
    _sc_list.split.map{ |sc_token| to_cc_token(sc_token, _canvas) }.join(' ')
end

def convert_coordinates(_element, _canvas, _x_tag, _y_tag, _z_tag)
    cc = _canvas.to_cc( { x: _element[_x_tag].to_i,
                          y: _element[_y_tag].to_i,
                          z: _element[_z_tag].to_i } )
    _element[_x_tag] = cc[:x]
    _element[_y_tag] = cc[:y]
    _element.delete(_z_tag)
end

def convert_spatial(_element)
    _element.name = 'svg'
    _element['xmlns'] = 'http://www.w3.org/2000/svg'
    _element['width'] ||= CabinetProjectedCanvas::DEFAULT_WIDTH.to_s
    _element['height'] ||= CabinetProjectedCanvas::DEFAULT_HEIGHT.to_s
    canvas = CabinetProjectedCanvas.new(_element['width'], _element['height'],
                                        _element['s_origin_cx'], _element['s_origin_cy'])

    _element.children.each do |c|
        case c.name
        when 'line'
            convert_coordinates(c, canvas, 'x1', 'y1', 'z1')
            convert_coordinates(c, canvas, 'x2', 'y2', 'z2')
        when 'polygon', 'polyline'
            c['points'] = to_cc_list(c['points'], canvas)
        when 'rect'
            convert_coordinates(c, canvas, 'x', 'y', 'z')
        when 'circle'
            convert_coordinates(c, canvas, 'cx', 'cy', 'cz')
        end
    end
end

def convert_file(_filename)
    output_name = _filename.gsub(/(?=\.[^\\\/]*$)/, '_out')
    output_name += (output_name == _filename) ? '_out' : ''

    document = File.open(_filename) { |f| Nokogiri::XML(f) }
    document.xpath('//xmlns:spatial').each { |e| convert_spatial(e) }
    File.write(output_name, document)
end

if(ARGV[0].nil?) then
    puts 'Usage .\Cabinet-projection.rb <input_filename>'
else
    convert_file(ARGV[0])
end


