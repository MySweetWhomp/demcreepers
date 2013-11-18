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
_createBlock = (x, y) ->
    tileWidth = window.DemCreepers.Config.TileSize[0]
    tileHeight = window.DemCreepers.Config.TileSize[1]
    new jaws.Sprite
        x : x * tileWidth
        y : y * tileHeight
        width : tileWidth
        height : tileHeight

class Map
    constructor : (rows, cols) ->
        tileWidth = window.DemCreepers.Config.TileSize[0]
        tileHeight = window.DemCreepers.Config.TileSize[1]
        @_ground = new jaws.TileMap
            size : [cols, rows]
            cell_size : [tileWidth, tileHeight]
        @_map = new jaws.TileMap
            size : [cols, rows]
            cell_size : [tileWidth, tileHeight]
        @_gobs = new jaws.SpriteSheet
            image : 'assets/img/Gob.gif'
            frame_size : [50, 50]
            orientation : "down"

        ###
        # Fill the ground
        ###
        _.map [0..rows - 1], (y) =>
            _.map [0..cols - 1], (x) =>
                block = _createBlock x, y
                block.setImage 'assets/img/ground.gif'
                @_ground.push block

    add : (mob) =>
        tileWidth = window.DemCreepers.Config.TileSize[0]
        tileHeight = window.DemCreepers.Config.TileSize[1]
        cell = new jaws.Sprite
            x : mob.x
            y : mob.y
            width : 50
            height : 50
            scale : 2
            anchor : 'center'
        if mob instanceof window.DemCreepers.Gob
            cell.type = 'Gob'
            cell.image = @_gobs.frames[9]
        @_map.push cell

    all : =>
        do @_map.all

if window.DemCreepers?
    window.DemCreepers.Map = Map