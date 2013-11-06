#####
##
# Dem Creepers!
# Entry for the GitHub Game Off 2013
# Author : Paul Joannon for H-Bomb
# <paul.joannon@gmail.com>
##
#####

###
# Instanciate a block at a given position
###
_createBlock = (x, y, width, height) ->
    new jaws.Sprite
        x : x * width
        y : y * height
        width : width
        height : height

class Map
    constructor : (rows, cols) ->
        tileWidth = window.DemCreepers.Config.TileSize[0]
        tileHeight = window.DemCreepers.Config.TileSize[1]
        @_blocks = new jaws.SpriteList
        _.map [0..cols - 1], (x) =>
            _.map [0, rows - 1], (y) =>
                @_blocks.push _createBlock x, y, tileWidth, tileHeight
        _.map [1..rows - 2], (y) =>
            _.map [0, cols - 1], (x) =>
                @_blocks.push _createBlock x, y, tileWidth, tileHeight
        @_map = new jaws.TileMap
            size : [cols, rows]
            cell_size : [tileWidth, tileHeight]
        @_map.push @_blocks

    all : =>
        do @_map.all

if window.DemCreepers?
    window.DemCreepers.Map = Map