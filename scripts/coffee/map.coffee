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
        @_block = new jaws.SpriteSheet
            image : 'assets/img/Block.gif'
            frame_size : [32, 32]
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
        if mob instanceof window.DemCreepers.Gob
            cell = new jaws.Sprite
                x : mob.x
                y : mob.y
                scale : 2
                anchor : 'center'
                image : @_gobs.frames[0]
            cell.type = 'Gob'
            @_map.push cell
        else
            y = mob.y - 32
            while y <= mob.y + 32
                x = mob.x - 64
                while x <= mob.x + 64
                    theX = x
                    if y < mob.y
                        theX += 10
                    else if y > mob.y
                        theX -= 10
                    cell = new jaws.Sprite
                        x : theX
                        y : y
                        scale : 2
                        anchor : 'center'
                        image : @_block.frames[0]
                    cell.type = 'Golem'
                    @_map.push cell
                    x += 64
                y += 32

    all : =>
        do @_map.all

if window.DemCreepers?
    window.DemCreepers.Map = Map