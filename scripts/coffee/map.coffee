class Map
    constructor : (fillFunc, width, height, rows, cols) ->
        @_blocks = new jaws.SpriteList
        fillFunc @_blocks
        @_map = new jaws.TileMap
            size : [rows, cols]
            cell_size : [width, height]
        @_map.push @_blocks

    all : =>
        do @_map.all

if window.DemCreepers?
    window.DemCreepers.Map = Map