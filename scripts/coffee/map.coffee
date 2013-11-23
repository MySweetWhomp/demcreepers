#####
##
# Dem Creepers!
# Entry for the GitHub Game Off 2013
# Author : Paul Joannon for H-Bomb
# <paul.joannon@gmail.com>
##
#####

###
## The Map
###

_THEMAP = '''
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
KKKKKKKKKKKKKKKKKKKKKKKKKKKKKKKK
'''


###
# Instanciate a block at a given position
###
_createBlock = (x, y) ->
    tileWidth = window.DemCreepers.Config.TileSize[0] * 2
    tileHeight = window.DemCreepers.Config.TileSize[1] * 2
    new jaws.Sprite
        x : x * tileWidth
        y : y * tileHeight
        scale : 2

class Map
    constructor : (rows, cols) ->
        @_tileset = new jaws.SpriteSheet
            image : 'assets/img/BG---Tiles.gif'
            frame_size : [50, 50]
            orientation : 'right'
        @_gobs = new jaws.SpriteSheet
            image : 'assets/img/GobCorpse.gif'
            frame_size : [50, 20]
            orientation : "down"
        tileWidth = window.DemCreepers.Config.TileSize[0]
        tileHeight = window.DemCreepers.Config.TileSize[1]
        @_ground = new jaws.TileMap
            size : [cols, rows]
            cell_size : [tileWidth * 2, tileHeight * 2]
        @_map = new jaws.TileMap
            size : [cols, rows]
            cell_size : [tileWidth, tileHeight]

        ###
        # Fill the ground
        ###
        map = _THEMAP.split '\n'
        _.map [0..rows - 1], (y) =>
            row = map[y].split ''
            _.map [0..cols - 1], (x) =>
                block = _createBlock x, y
                block.setImage @_tileset.frames[window.DemCreepers.Utils.getTileId row[x]]
                @_ground.push block

    add : (mob) =>
        tileWidth = window.DemCreepers.Config.TileSize[0]
        tileHeight = window.DemCreepers.Config.TileSize[1]
        cell = new jaws.Sprite
            x : mob.x
            y : mob.y
            width : 50
            height : 20
            scale : 2
            anchor : 'center'
        if mob instanceof window.DemCreepers.Gob
            cell.type = 'Gob'
            cell.image = @_gobs.frames[0]
        else
            cell.type = 'Golem'
        @_map.push cell

    all : =>
        do @_map.all

if window.DemCreepers?
    window.DemCreepers.Map = Map