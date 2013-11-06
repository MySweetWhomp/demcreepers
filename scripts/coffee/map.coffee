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
        @_map = new jaws.TileMap
            size : [cols, rows]
            cell_size : [tileWidth, tileHeight]

    all : =>
        do @_map.all

if window.DemCreepers?
    window.DemCreepers.Map = Map