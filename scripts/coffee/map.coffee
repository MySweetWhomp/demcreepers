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
036000020006
K99A071BABE0
345008DGOFI0
400001FHGGI4
400000NKKLM7
CO540000256B
HGDE0040BDCG
HGHGO440JHGL
HHGHGE704FI4
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
    constructor : (@rows, @cols) ->
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
            size : [@cols, @rows]
            cell_size : [tileWidth * 2, tileHeight * 2]
        @_map = new jaws.TileMap
            size : [@cols, @rows]
            cell_size : [tileWidth * 2, tileHeight * 2]

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
            cell.state = 0
            try
                @_map.push cell
        else
            if ('S' in mob._orientation)  or ('N' in mob._orientation)
                y = mob.y
                x = mob.x - 64
                while x <= mob.x + 64
                    cell = new jaws.Sprite
                        x : x
                        y : y
                        scale : 2
                        anchor : 'center'
                        image : @_block.frames[0]
                    cell.type = 'Golem'
                    try
                        @_map.push cell
                    x += 64
            else
                y = mob.y - 55
                x = mob.x
                while y <= mob.y + 55
                    cell = new jaws.Sprite
                        x : x
                        y : y
                        scale : 2
                        anchor : 'center'
                        image : @_block.frames[0]
                    cell.type = 'Golem'
                    try
                        @_map.push cell
                    y += 55

    updateForNextWave : =>
        gobs =
            0 :
                next : 1
                all : []
            1 :
                next : 4
                all : []
            4 :
                all : []

        blocks = []

        _.map (do @_map.all), (cell) =>
            if cell.type is 'Gob'
                gobs[cell.state].all.push cell
            else
                blocks.push cell

        _.map [0, 1], (i) =>
            _.map gobs[i].all, (cell) =>
                cell.state = gobs[i].next
                cell.setImage @_gobs.frames[cell.state]

        tileWidth = window.DemCreepers.Config.TileSize[0] * 2
        tileHeight = window.DemCreepers.Config.TileSize[1] * 2
        @_map = new jaws.TileMap
            size : [@cols, @rows]
            cell_size : [tileWidth, tileHeight]
        try
            @_map.push _.uniq gobs[0].all
            @_map.push _.uniq gobs[1].all
            @_map.push _.uniq blocks

    all : =>
        do @_map.all

if window.DemCreepers?
    window.DemCreepers.Map = Map