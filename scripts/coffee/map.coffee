_createBlock = (x, y, width, height) ->
    new jaws.Sprite
        x : x * width
        y : y * height
        width : width
        height : height

class Map
    constructor : (width, height, rows, cols) ->
        @_blocks = new jaws.SpriteList
        _.map [0..cols - 1], (x) =>
            _.map [0, rows - 1], (y) =>
                @_blocks.push _createBlock x, y, 40, 40
        _.map [1..rows - 2], (y) =>
            _.map [0, cols - 1], (x) =>
                @_blocks.push _createBlock x, y, 40, 40
        @_map = new jaws.TileMap
            size : [cols, rows]
            cell_size : [width, height]
        @_map.push @_blocks

    all : =>
        do @_map.all

if window.DemCreepers?
    window.DemCreepers.Map = Map